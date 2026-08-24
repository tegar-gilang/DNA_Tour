import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../../../core/utils/date_utils.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../tracking/presentation/journey_provider.dart';
import '../../tracking/presentation/pilgrim_attendance_provider.dart';

class PilgrimHomeScreen extends ConsumerStatefulWidget {
  const PilgrimHomeScreen({super.key});

  @override
  ConsumerState<PilgrimHomeScreen> createState() => _PilgrimHomeScreenState();
}

class _PilgrimHomeScreenState extends ConsumerState<PilgrimHomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
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
    final journeyState = ref.watch(journeyProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final nextPrayer = PrayerScheduleUtils.getNextPrayer(now);
    final countdownText = PrayerScheduleUtils.formatCountdown(nextPrayer.targetTime, spaced: true);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 800));
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brief Profile Hero Summary Card combined with Prayer Reminder
                RoleProfileSummaryCard(
                  name: user?.name ?? 'H. Ahmad Zaki Al-Farizi',
                  roleSubtitle: 'Kloter 4 Al-Barakah',
                  avatarUrl: user?.avatarUrl ?? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
                  isVerified: false,
                  statusChips: const [],
                  currentLocation: journeyState.currentLocation.isNotEmpty ? journeyState.currentLocation : 'Masjidil Haram, Makkah',
                  unreadCount: 3,
                  customContent: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(nextPrayer.icon, color: AppColors.secondaryLight, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Sholat: ${nextPrayer.name}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryLight.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${nextPrayer.timeFormatted} WIB',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sisa Waktu Menjelang Adzan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    countdownText,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => context.push('/prayer_time'),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.clock, size: 15, color: AppColors.primaryDark),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Semua Jadwal',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 26),

                // 3. Apple Wallet / Flighty Structured Information List Card
                // 3. Apple Wallet / Flighty Structured Information List Card
                SectionHeader(title: 'Aktivitas Perjalanan Saat Ini'),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1,
                    ),
                    boxShadow: isDark ? AppColors.softShadowDark : AppColors.softShadowLight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              '${journeyState.currentActivity}:',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(2/36)',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: 2 / 36,
                          minHeight: 8,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(LucideIcons.mapPin, size: 16, color: AppColors.textSecondaryLight),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              journeyState.currentLocation,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondaryLight,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // INFORMATION LIST (Vertical rows with subtle dividers)
                      _buildInfoRow(
                        icon: LucideIcons.user,
                        label: 'Diperbarui Oleh',
                        value: journeyState.updatedBy,
                        isDark: isDark,
                      ),
                      _buildInfoRow(
                        icon: LucideIcons.clock,
                        label: 'Terakhir Diperbarui',
                        value: journeyState.lastUpdated,
                        isDark: isDark,
                      ),
                      _buildInfoRow(
                        icon: LucideIcons.arrowRightCircle,
                        label: 'Aktivitas Berikutnya',
                        value: journeyState.nextActivity,
                        isDark: isDark,
                      ),
                      _buildInfoRow(
                        icon: LucideIcons.timer,
                        label: 'Estimasi Waktu (ETA)',
                        value: journeyState.eta,
                        isDark: isDark,
                      ),
                      _buildInfoRow(
                        icon: LucideIcons.mapPin,
                        label: 'Tahapan Saat Ini',
                        value: journeyState.progressPercentage < 0.6 ? 'Fase Makkah' : 'Fase Madinah',
                        isDark: isDark,
                      ),
                      _buildInfoRow(
                        icon: LucideIcons.calendar,
                        label: 'Estimasi Selesai',
                        value: journeyState.estimatedDuration,
                        isDark: isDark,
                        showDivider: false,
                      ),
                      const SizedBox(height: 24),

                      // ACTION SECTION (One horizontal button row, equal width, harmonious Outlined buttons)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.go('/pilgrim/schedule'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                                side: BorderSide(
                                  color: isDark ? AppColors.borderDark : AppColors.primary.withValues(alpha: 0.45),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text(
                                'Lihat Jadwal',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.go('/pilgrim/map'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                                side: BorderSide(
                                  color: isDark ? AppColors.borderDark : AppColors.primary.withValues(alpha: 0.45),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text(
                                'Lihat Peta',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.go('/pilgrim/profile'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                                side: BorderSide(
                                  color: isDark ? AppColors.borderDark : AppColors.primary.withValues(alpha: 0.45),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text(
                                'Detail Info',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // 4. Quick Actions (Super Clean Rounded Squircle Icons)
                SectionHeader(title: 'Aksi Cepat'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickActionItem(
                      context: context,
                      label: 'Sinyal Darurat',
                      icon: LucideIcons.alertTriangle,
                      color: AppColors.emergencyRed,
                      onTap: () => context.push('/sos'),
                    ),
                    _buildQuickActionItem(
                      context: context,
                      label: 'Absensi Otomatis',
                      icon: LucideIcons.checkSquare,
                      color: AppColors.successGreen,
                      onTap: () {
                        final journeyState = ref.read(journeyProvider);
                        final user = ref.read(authProvider).user;
                        ref.read(pilgrimAttendanceProvider.notifier).recordCheckIn(
                              pilgrimId: user?.id ?? 'PL-88210',
                              pilgrimName: user?.name ?? 'H. Ahmad Zaki Al-Farizi',
                              location: journeyState.currentLocation,
                              battery: user?.batteryLevel ?? 86,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '✅ Absen kehadiran berhasil dikirim! Status Anda tercatat "HADIR" di daftar absen Tour Leader.',
                            ),
                            backgroundColor: AppColors.successGreen,
                          ),
                        );
                      },
                    ),
                    _buildQuickActionItem(
                      context: context,
                      label: 'ID Digital',
                      icon: LucideIcons.creditCard,
                      color: AppColors.secondaryDark,
                      onTap: () => context.go('/pilgrim/profile'),
                    ),
                    _buildQuickActionItem(
                      context: context,
                      label: 'Hubungi Ketua',
                      icon: LucideIcons.phoneCall,
                      color: AppColors.primary,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Memanggil Ketua Rombongan Ust. Muhammad Ridwan...'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 26),

                // 5. Worship Companion
                SectionHeader(title: 'Panduan & Ibadah'),
                Row(
                  children: [
                    Expanded(
                      child: _buildWorshipCard(
                        context: context,
                        title: 'Kumpulan Doa',
                        subtitle: 'Doa & Dzikir Umrah',
                        icon: Icons.menu_book_rounded,
                        color: AppColors.primary,
                        onTap: () => context.push('/prayer_collection'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildWorshipCard(
                        context: context,
                        title: 'Tasbih Digital',
                        subtitle: 'Penghitung & Target Dzikir',
                        icon: LucideIcons.repeat,
                        color: AppColors.secondaryDark,
                        onTap: () => context.push('/digital_tasbih'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildWorshipCard(
                  context: context,
                  title: 'Panduan Manasik Umrah',
                  subtitle: 'Tata cara ibadah lengkap dari Ihram hingga Tahallul',
                  icon: LucideIcons.compass,
                  color: AppColors.infoBlue,
                  onTap: () => context.push('/umrah_guide'),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondaryLight),
              const SizedBox(width: 14),
              Expanded(
                flex: 4,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
      ],
    );
  }

  Widget _buildQuickActionItem({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : color.withValues(alpha: 0.45),
                  width: 1.8, // High contrast border for clear clickable boundary
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorshipCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppleCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
        ],
      ),
    );
  }
}
