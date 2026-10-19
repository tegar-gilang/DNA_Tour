import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../tracking/presentation/journey_provider.dart';
import '../../tracking/data/sos_repository.dart';
import '../../../../core/services/location_service.dart';

class SosEmergencyScreen extends ConsumerStatefulWidget {
  const SosEmergencyScreen({super.key});

  @override
  ConsumerState<SosEmergencyScreen> createState() => _SosEmergencyScreenState();
}

class _SosEmergencyScreenState extends ConsumerState<SosEmergencyScreen> {
  String? _selectedDistressType;
  bool _isCountdownActive = false;
  int _countdownSeconds = 5;
  Timer? _timer;
  bool _isEmergencySent = false;
  bool _isSending = false;
  String? _sendError;
  double? _sentLatitude;
  double? _sentLongitude;
  String? _incidentId;

  final List<Map<String, dynamic>> _distressOptions = [
    {
      'type': 'Darurat Medis / Kesehatan',
      'icon': LucideIcons.heartPulse,
      'color': AppColors.emergencyRed,
      'desc':
          'Nyeri hebat, pingsan, sesak napas, pusing tajam, atau gangguan jantung.',
    },
    {
      'type': 'Tersesat / Terpisah dari Rombongan',
      'icon': LucideIcons.helpCircle,
      'color': AppColors.warningAmber,
      'desc':
          'Terpisah dari rombongan/bus dan tidak dapat menemukan titik kumpul.',
    },
    {
      'type': 'Kecelakaan / Terjatuh',
      'icon': LucideIcons.alertOctagon,
      'color': const Color(0xFFD9480F),
      'desc':
          'Cedera fisik, terkilir, atau jatuh yang memerlukan kursi roda / tandu.',
    },
    {
      'type': 'Butuh Bantuan Umum',
      'icon': LucideIcons.lifeBuoy,
      'color': AppColors.infoBlue,
      'desc':
          'Kendala bahasa, dokumen hilang, atau membutuhkan panduan mendesak.',
    },
  ];

  void _triggerCountdown(String type) {
    setState(() {
      _selectedDistressType = type;
      _isCountdownActive = true;
      _countdownSeconds = 5;
      _isEmergencySent = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 1) {
        setState(() => _countdownSeconds--);
      } else {
        timer.cancel();
        _transmitEmergencyPacket();
      }
    });
  }

  void _cancelCountdown() {
    _timer?.cancel();
    setState(() {
      _isCountdownActive = false;
      _selectedDistressType = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Peringatan darurat SOS telah dibatalkan oleh Anda.'),
      ),
    );
  }

  Future<void> _transmitEmergencyPacket() async {
    if (_isSending || _isEmergencySent) return;

    final jamaah = ref.read(authProvider).jamaah;

    if (jamaah == null) {
      _showSendError('Data jamaah tidak ditemukan. Silakan login kembali.');
      return;
    }

    setState(() {
      _isCountdownActive = false;
      _isSending = true;
      _sendError = null;
    });

    try {
      final position = await LocationService().getCurrentPosition();

      final type = switch (_selectedDistressType) {
        'Darurat Medis / Kesehatan' => 'health',
        'Tersesat / Terpisah dari Rombongan' => 'lost',
        'Kecelakaan / Terjatuh' => 'accident',
        'Butuh Bantuan Umum' => 'critical',
        _ => throw Exception('Kategori darurat tidak valid.'),
      };

      final repository = SosRepository(
        apiClient: ApiClient(),
        secureStorage: SecureStorage(),
      );

      final result = await repository.createIncident(
        type: type,
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: ref.read(journeyProvider).currentLocation,
        description: _selectedDistressType,
      );

      final data = result['data'];

      if (data is! Map || data['id'] == null) {
        throw Exception(
          'Respons server tidak sesuai. Periksa status SOS di backend sebelum mencoba lagi.',
        );
      }

      if (!mounted) return;

      setState(() {
        _isSending = false;
        _isEmergencySent = true;
        _sentLatitude = position.latitude;
        _sentLongitude = position.longitude;
        _incidentId = data['id'].toString();
      });
    } on DioException catch (error) {
      if (!mounted) return;

      final statusCode = error.response?.statusCode;

      final message = switch (statusCode) {
        401 || 403 =>
          'Sesi login tidak valid atau tidak memiliki akses. Silakan login kembali.',
        409 =>
          'Masih ada SOS aktif untuk akun ini. Hubungi petugas jika membutuhkan bantuan.',
        422 => 'Data SOS ditolak oleh server. Periksa kategori dan koordinat.',
        _ =>
          'Pengiriman SOS belum terkonfirmasi. Periksa koneksi dan status incident di backend.',
      };

      _showSendError(message);
    } catch (error) {
      if (!mounted) return;

      _showSendError(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showSendError(String message) {
    if (!mounted) return;

    setState(() {
      _isSending = false;
      _isCountdownActive = false;
      _isEmergencySent = false;
      _sendError = message;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final jamaah = authState.jamaah;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Darurat SOS'),
        backgroundColor: _isCountdownActive || _isEmergencySent
            ? AppColors.emergencyRed
            : null,
        foregroundColor: _isCountdownActive || _isEmergencySent
            ? Colors.white
            : null,
      ),
      body: SafeArea(
        child: _isEmergencySent
            ? _buildSentState(context, jamaah)
            : _buildSelectionState(context, jamaah),
      ),
    );
  }

  Widget _buildSelectionState(BuildContext context, jamaah) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.emergencyContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.emergencyRed.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Icon(
                  LucideIcons.alertTriangle,
                  size: 48,
                  color: AppColors.emergencyRed,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.08, 1.08),
                duration: 800.ms,
              ),
          const SizedBox(height: 20),
          Text(
            'Pemancar Darurat SOS',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih jenis kondisi darurat. Paket darurat otomatis berisi koordinat GPS akurat, baterai, waktu, serta identitas Anda akan langsung dikirim ke Tour Leader, Keluarga, dan Pusat Operasional.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          if (_sendError != null && !_isSending)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _sendError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),

          if (_isSending)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Mengambil koordinat GPS dan mengirim SOS...',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else if (_isCountdownActive)
            _buildCountdownBanner()
          else ...[
            Text(
              'PILIH KATEGORI KONDISI DARURAT UNTUK DIKIRIM:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 16),
            ..._distressOptions.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: AppleCard(
                  onTap: () => _triggerCountdown(option['type']),
                  padding: const EdgeInsets.all(18),
                  border: Border.all(
                    color: option['color'].withOpacity(0.6),
                    width: 1.5,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: option['color'].withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          option['icon'],
                          color: option['color'],
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option['type'],
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: option['color'],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option['desc'],
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: option['color'],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildCountdownBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.emergencyRed,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.emergencyRed.withValues(alpha: 0.5),
            blurRadius: 4,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'MENGIRIM SINYAL SOS DALAM',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white70,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
                '$_countdownSeconds',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              )
              .animate(key: ValueKey(_countdownSeconds))
              .scale(
                begin: const Offset(1.4, 1.4),
                end: const Offset(1, 1),
                duration: 300.ms,
              ),
          const SizedBox(height: 12),
          Text(
            'Jenis Darurat: $_selectedDistressType',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _cancelCountdown,
              icon: const Icon(
                Icons.cancel_rounded,
                color: AppColors.emergencyRed,
              ),
              label: const Text('BATALKAN PENGIRIMAN SOS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.emergencyRed,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentState(BuildContext context, jamaah) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.successGreen, width: 3),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 64,
              color: AppColors.successGreen,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Incident SOS berhasil dibuat di server. Status ini belum memastikan notifikasi telah diterima oleh Tour Leader.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.successGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sinyal darurat Anda ($_selectedDistressType) telah diterima oleh Tour Leader Ust. Muhammad Ridwan dan Pusat Operasional Al-Barakah.',
            style: TextStyle(fontSize: 15, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          AppleCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _buildPacketRow('ID Jamaah', jamaah?.loginId ?? '-'),
                const Divider(height: 20),
                _buildPacketRow('ID Incident', _incidentId ?? '-'),
                const Divider(height: 20),
                _buildPacketRow(
                  'Latitude',
                  _sentLatitude?.toStringAsFixed(6) ?? '-',
                ),
                const Divider(height: 20),
                _buildPacketRow(
                  'Longitude',
                  _sentLongitude?.toStringAsFixed(6) ?? '-',
                ),
                const Divider(height: 20),
                _buildPacketRow('Jenis Darurat', _selectedDistressType ?? '-'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Membuka panggilan telepon darurat ke Tour Leader...',
                    ),
                  ),
                );
              },
              icon: const Icon(LucideIcons.phoneCall),
              label: const Text('Hubungi Tour Leader Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Kembali ke Beranda Utama'),
          ),
        ],
      ),
    );
  }

  Widget _buildPacketRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            softWrap: true,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
