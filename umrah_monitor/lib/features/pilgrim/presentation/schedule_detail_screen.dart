import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/design_system/app_colors.dart';
import '../../../core/design_system/custom_widgets.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../tour_leader/domain/schedule_model.dart';
import 'timeline_provider.dart';

class ScheduleDetailScreen extends ConsumerStatefulWidget {
  final String scheduleId;
  final ScheduleModel? initialSchedule;

  const ScheduleDetailScreen({
    super.key,
    required this.scheduleId,
    this.initialSchedule,
  });

  @override
  ConsumerState<ScheduleDetailScreen> createState() =>
      _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends ConsumerState<ScheduleDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scheduleDetailProvider.notifier).fetchDetail(
            widget.scheduleId,
            cached: widget.initialSchedule,
          );
    });
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('EEEE, dd MMMM yyyy • HH:mm', 'id').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Selesai';
      case 'in_progress':
        return 'Sedang Berlangsung';
      default:
        return 'Akan Datang';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.successGreen;
      case 'in_progress':
        return AppColors.infoBlue;
      default:
        return AppColors.textTertiaryLight;
    }
  }

  String _reminderLabel(String reminderStatus) {
    return reminderStatus == 'published' ? 'Telah Disiarkan' : 'Belum Disiarkan';
  }

  Color _reminderColor(String reminderStatus) {
    return reminderStatus == 'published'
        ? AppColors.successGreen
        : AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailState = ref.watch(scheduleDetailProvider);

    // Auto logout jika token daluwarsa (401)
    ref.listen<ScheduleDetailState>(scheduleDetailProvider, (prev, next) {
      if (next.statusCode == 401) {
        ref.read(authProvider.notifier).logout();
      }
    });

    final item = detailState.schedule ?? widget.initialSchedule;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Detail Jadwal',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => ref
                .read(scheduleDetailProvider.notifier)
                .fetchDetail(widget.scheduleId),
            tooltip: 'Perbarui',
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(isDark, detailState, item),
      ),
    );
  }

  Widget _buildBody(
    bool isDark,
    ScheduleDetailState detailState,
    ScheduleModel? item,
  ) {
    if (detailState.isLoading && item == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Memuat detail kegiatan...',
              style: TextStyle(color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      );
    }

    if (item == null && detailState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                detailState.statusCode == 403
                    ? LucideIcons.shieldAlert
                    : LucideIcons.alertTriangle,
                size: 54,
                color: AppColors.emergencyRed,
              ),
              const SizedBox(height: 16),
              Text(
                detailState.statusCode == 403
                    ? 'Akses Ditolak'
                    : 'Gagal Memuat Detail',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                detailState.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => ref
                    .read(scheduleDetailProvider.notifier)
                    .fetchDetail(widget.scheduleId),
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (item == null) {
      return const Center(child: Text('Data jadwal tidak tersedia.'));
    }

    final statusColor = _statusColor(item.status);
    final statusLabel = _statusLabel(item.status);
    final reminderColor = _reminderColor(item.reminderStatus);
    final reminderLabel = _reminderLabel(item.reminderStatus);

    return RefreshIndicator(
      onRefresh: () => ref
          .read(scheduleDetailProvider.notifier)
          .fetchDetail(widget.scheduleId),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error banner jika refresh background gagal tapi data cache ada
            if (detailState.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.emergencyRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.emergencyRed.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertCircle,
                        size: 16, color: AppColors.emergencyRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        detailState.errorMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.emergencyRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Card Utama Detail
            AppleCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges: Status Pelaksanaan & Status Reminder terpisah
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusBadge(label: statusLabel, color: statusColor),
                      StatusBadge(label: reminderLabel, color: reminderColor),
                      if (item.category != null && item.category!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.category!.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Judul Kegiatan
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 20),

                  // Waktu Mulai
                  _buildInfoRow(
                    icon: LucideIcons.calendar,
                    label: 'Waktu Mulai',
                    value: _formatDateTime(item.startTime),
                  ),
                  const SizedBox(height: 14),

                  // Waktu Selesai (jika ada)
                  if (item.effectiveEndTime != null &&
                      item.effectiveEndTime!.isNotEmpty) ...[
                    _buildInfoRow(
                      icon: LucideIcons.clock,
                      label: 'Target Selesai',
                      value: _formatDateTime(item.effectiveEndTime),
                    ),
                    const SizedBox(height: 14),
                  ] else if (item.endTime != null &&
                      item.endTime!.isNotEmpty) ...[
                    _buildInfoRow(
                      icon: LucideIcons.clock,
                      label: 'Waktu Selesai',
                      value: item.endTime!,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Lokasi
                  if (item.location != null && item.location!.isNotEmpty) ...[
                    _buildInfoRow(
                      icon: LucideIcons.mapPin,
                      label: 'Lokasi',
                      value: item.location!,
                      iconColor: AppColors.primary,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // PIC
                  if (item.pic != null && item.pic!.isNotEmpty) ...[
                    _buildInfoRow(
                      icon: LucideIcons.userCheck,
                      label: 'Penanggung Jawab (PIC)',
                      value: item.pic!,
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Mode Status
                  _buildInfoRow(
                    icon: LucideIcons.sliders,
                    label: 'Mode Pelaksanaan',
                    value: item.statusMode == 'manual'
                        ? 'Ditetapkan Manual oleh Petugas'
                        : 'Otomatis Sesuai Waktu',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Card Deskripsi / Keterangan
            if (item.description != null && item.description!.isNotEmpty)
              AppleCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.fileText,
                            size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Keterangan & Petunjuk',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.description!,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Read-only indicator notice
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.shieldCheck,
                      size: 14, color: AppColors.textTertiaryLight),
                  const SizedBox(width: 6),
                  const Text(
                    'Informasi resmi dari Sistem DNA Tour',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.textTertiaryLight)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              size: 18, color: iconColor ?? AppColors.textTertiaryLight),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
