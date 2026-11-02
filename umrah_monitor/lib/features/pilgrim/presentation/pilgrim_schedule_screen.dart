import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../tour_leader/domain/schedule_model.dart';
import 'schedule_detail_screen.dart';
import 'timeline_provider.dart';

class PilgrimScheduleScreen extends ConsumerStatefulWidget {
  final bool isFamilyView;
  const PilgrimScheduleScreen({super.key, this.isFamilyView = false});

  @override
  ConsumerState<PilgrimScheduleScreen> createState() =>
      _PilgrimScheduleScreenState();
}

class _PilgrimScheduleScreenState extends ConsumerState<PilgrimScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(timelineProvider.notifier).fetchSchedules();
    });
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy • HH:mm', 'id').format(dt);
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

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return LucideIcons.checkCircle2;
      case 'in_progress':
        return LucideIcons.clock;
      default:
        return LucideIcons.circle;
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
    final timelineState = ref.watch(timelineProvider);
    final schedules = timelineState.schedules;

    // Listen untuk penanganan sesi daluwarsa 401
    ref.listen<TimelineState>(timelineProvider, (prev, next) {
      if (next.statusCode == 401) {
        ref.read(authProvider.notifier).logout();
      }
    });

    final authState = ref.watch(authProvider);
    final kloterCode = authState.jamaah?.journey.kloter?.code ??
        'Kloter Rombongan';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jadwal Perjalanan',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.isFamilyView
                              ? '$kloterCode • Dipantau Keluarga'
                              : '$kloterCode • Rangkaian Ibadah',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () {
                            ref
                                .read(timelineProvider.notifier)
                                .fetchSchedules();
                          },
                          icon: Icon(
                            LucideIcons.refreshCw,
                            size: 18,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimaryLight,
                          ),
                          tooltip: 'Muat Ulang',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Error Banner jika ada error dan list tidak kosong
            if (timelineState.errorMessage != null && schedules.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Container(
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
                          timelineState.errorMessage!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.emergencyRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Main Body: Loading / Error / Empty / List
            Expanded(
              child: _buildBody(isDark, timelineState, schedules),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    bool isDark,
    TimelineState timelineState,
    List<ScheduleModel> schedules,
  ) {
    if (timelineState.isLoading && schedules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Memuat jadwal perjalanan...',
              style: TextStyle(color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      );
    }

    if (schedules.isEmpty && timelineState.errorMessage != null) {
      final isAccessDenied = timelineState.statusCode == 403;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isAccessDenied
                    ? LucideIcons.shieldAlert
                    : LucideIcons.wifiOff,
                size: 48,
                color: AppColors.textTertiaryLight,
              ),
              const SizedBox(height: 12),
              Text(
                isAccessDenied
                    ? 'Akses Ditolak'
                    : 'Gagal Memuat Jadwal',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                timelineState.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiaryLight,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(timelineProvider.notifier).fetchSchedules(),
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (schedules.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(timelineProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.calendarX,
                      size: 48, color: AppColors.textTertiaryLight),
                  SizedBox(height: 12),
                  Text(
                    'Belum Ada Jadwal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Jadwal kegiatan rombongan akan muncul di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(timelineProvider.notifier).refresh(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final item = schedules[index];
          final isLast = index == schedules.length - 1;
          return _buildTimelineItem(item, isLast, isDark);
        },
      ),
    );
  }

  Widget _buildTimelineItem(
    ScheduleModel item,
    bool isLast,
    bool isDark,
  ) {
    final statusColor = _statusColor(item.status);
    final statusLabel = _statusLabel(item.status);
    final statusIcon = _statusIcon(item.status);

    final reminderColor = _reminderColor(item.reminderStatus);
    final reminderLabel = _reminderLabel(item.reminderStatus);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator line & dot
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: statusColor.withValues(
                      alpha: item.status == 'upcoming' ? 0.12 : 1.0),
                  shape: BoxShape.circle,
                  border: Border.all(color: statusColor, width: 2),
                ),
                child: Icon(
                  statusIcon,
                  size: 13,
                  color: item.status == 'upcoming' ? statusColor : Colors.white,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: item.status == 'completed'
                        ? AppColors.successGreen.withValues(alpha: 0.6)
                        : AppColors.borderLight,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Checkpoint Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => ScheduleDetailScreen(
                        scheduleId: item.id,
                        initialSchedule: item,
                      ),
                    ),
                  );
                },
                child: AppleCard(
                  padding: const EdgeInsets.all(16),
                  border: item.status == 'in_progress'
                      ? Border.all(color: AppColors.infoBlue, width: 1.5)
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Status Pelaksanaan & Status Reminder terpisah
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatusBadge(label: statusLabel, color: statusColor),
                          StatusBadge(label: reminderLabel, color: reminderColor),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Judul
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Kategori & Lokasi
                      if (item.location != null && item.location!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.mapPin,
                                  size: 13, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.location!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Waktu Mulai
                      Row(
                        children: [
                          const Icon(LucideIcons.calendar,
                              size: 13, color: AppColors.textTertiaryLight),
                          const SizedBox(width: 6),
                          Text(
                            _formatDateTime(item.startTime),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),

                      // Target Selesai
                      if (item.effectiveEndTime != null &&
                          item.effectiveEndTime!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.clock,
                                  size: 13, color: AppColors.textTertiaryLight),
                              const SizedBox(width: 6),
                              Text(
                                'Selesai: ${_formatDateTime(item.effectiveEndTime)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // PIC jika ada
                      if (item.pic != null && item.pic!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.user,
                                  size: 13, color: AppColors.textTertiaryLight),
                              const SizedBox(width: 6),
                              Text(
                                'PIC: ${item.pic}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Deskripsi singkat
                      if (item.description != null &&
                          item.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),
                      // Hint klik detail
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Lihat Detail',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.chevronRight,
                              size: 14, color: AppColors.primary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
