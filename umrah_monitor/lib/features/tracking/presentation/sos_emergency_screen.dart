import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../tracking/presentation/incident_provider.dart';
import '../../tracking/presentation/journey_provider.dart';

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

  final List<Map<String, dynamic>> _distressOptions = [
    {
      'type': 'Darurat Medis / Kesehatan',
      'icon': LucideIcons.heartPulse,
      'color': AppColors.emergencyRed,
      'desc': 'Nyeri hebat, pingsan, sesak napas, pusing tajam, atau gangguan jantung.',
    },
    {
      'type': 'Tersesat / Terpisah dari Rombongan',
      'icon': LucideIcons.helpCircle,
      'color': AppColors.warningAmber,
      'desc': 'Terpisah dari rombongan/bus dan tidak dapat menemukan titik kumpul.',
    },
    {
      'type': 'Kecelakaan / Terjatuh',
      'icon': LucideIcons.alertOctagon,
      'color': const Color(0xFFD9480F),
      'desc': 'Cedera fisik, terkilir, atau jatuh yang memerlukan kursi roda / tandu.',
    },
    {
      'type': 'Butuh Bantuan Umum',
      'icon': LucideIcons.lifeBuoy,
      'color': AppColors.infoBlue,
      'desc': 'Kendala bahasa, dokumen hilang, atau membutuhkan panduan mendesak.',
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
      const SnackBar(content: Text('Peringatan darurat SOS telah dibatalkan oleh Anda.')),
    );
  }

  void _transmitEmergencyPacket() {
    final user = ref.read(authProvider).user;
    final location = ref.read(journeyProvider).currentLocation;
    
    ref.read(incidentProvider.notifier).addIncident(
      IncidentModel(
        id: 'SOS-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        title: 'Darurat: $_selectedDistressType',
        pilgrimName: user?.name ?? 'Jamaah (PL-88210)',
        type: 'sos',
        priority: 'critical',
        time: 'Baru Saja',
        location: location,
        status: 'open',
      ),
    );

    setState(() {
      _isCountdownActive = false;
      _isEmergencySent = true;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

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
        child: _isEmergencySent ? _buildSentState(context, user) : _buildSelectionState(context, user),
      ),
    );
  }

  Widget _buildSelectionState(BuildContext context, user) {
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
              border: Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.5), width: 2),
            ),
            child: Icon(LucideIcons.alertTriangle, size: 48, color: AppColors.emergencyRed),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08), duration: 800.ms),
          const SizedBox(height: 20),
          Text(
            'Pemancar Darurat SOS',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih jenis kondisi darurat. Paket darurat otomatis berisi koordinat GPS akurat, baterai, waktu, serta identitas Anda akan langsung dikirim ke Tour Leader, Keluarga, dan Pusat Operasional.',
            style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.textSecondaryLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          if (_isCountdownActive)
            _buildCountdownBanner()
          else ...[
            Text('PILIH KATEGORI KONDISI DARURAT UNTUK DIKIRIM:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight)),
            const SizedBox(height: 16),
            ..._distressOptions.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: AppleCard(
                  onTap: () => _triggerCountdown(option['type']),
                  padding: const EdgeInsets.all(18),
                  border: Border.all(color: option['color'].withOpacity(0.6), width: 1.5),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: option['color'].withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(option['icon'], color: option['color'], size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(option['type'], style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: option['color'])),
                            const SizedBox(height: 4),
                            Text(option['desc'], style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 18, color: option['color']),
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
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white70, letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          Text(
            '$_countdownSeconds',
            style: TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: Colors.white),
          ).animate(key: ValueKey(_countdownSeconds)).scale(begin: const Offset(1.4, 1.4), end: const Offset(1, 1), duration: 300.ms),
          const SizedBox(height: 12),
          Text(
            'Jenis Darurat: $_selectedDistressType',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _cancelCountdown,
              icon: const Icon(Icons.cancel_rounded, color: AppColors.emergencyRed),
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

  Widget _buildSentState(BuildContext context, user) {
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
            child: const Icon(Icons.check_circle_rounded, size: 64, color: AppColors.successGreen),
          ),
          const SizedBox(height: 24),
          Text(
            'PAKET SOS TERKIRIM',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.successGreen),
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
                _buildPacketRow('ID Pengirim', user?.id ?? 'PL-88210'),
                const Divider(height: 20),
                _buildPacketRow('Koordinat GPS', '21.4225° N, 39.8262° E (Pintu Safa)'),
                const Divider(height: 20),
                _buildPacketRow('Baterai & Waktu', '${user?.batteryLevel ?? 86}% • Baru Saja'),
                const Divider(height: 20),
                _buildPacketRow('Posisi & Tahapan Saat Ini', 'Tahap 5: Area Makkah'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Membuka panggilan telepon darurat ke Tour Leader...')),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
