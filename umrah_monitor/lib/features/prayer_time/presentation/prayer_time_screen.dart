import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../../../core/utils/date_utils.dart';

class PrayerTimeScreen extends StatefulWidget {
  const PrayerTimeScreen({super.key});

  @override
  State<PrayerTimeScreen> createState() => _PrayerTimeScreenState();
}

class _PrayerTimeScreenState extends State<PrayerTimeScreen> with SingleTickerProviderStateMixin {
  bool _isSilentReminder = true;
  Timer? _timer;
  late AnimationController _compassController;

  @override
  void initState() {
    super.initState();
    _compassController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _compassController.dispose();
    super.dispose();
  }

  void _toggleSilentLock() {
    setState(() => _isSilentReminder = !_isSilentReminder);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: _isSilentReminder ? AppColors.primaryDark : AppColors.secondaryDark,
        content: Row(
          children: [
            Icon(_isSilentReminder ? LucideIcons.volumeX : LucideIcons.volume2, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isSilentReminder
                    ? 'Mode Senyap Terkunci (Lock): Ponsel otomatis senyap saat waktu sholat'
                    : 'Mode Senyap Terbuka (Unlock): Suara & notifikasi sholat aktif',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQiblaCompass(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildQiblaCompassSheet(ctx),
    );
  }

  Widget _buildQiblaCompassSheet(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.borderLight.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.compass, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kompas Arah Kiblat', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimaryLight)),
                        Text('Menuju Ka\'bah • Masjidil Haram', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondaryLight)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(LucideIcons.x, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Compass Dial Box
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring glow
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.05),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 36,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),

                // Cardinal Directions on Outer Dial
                Positioned(top: 12, child: Text('U (N)', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary))),
                Positioned(bottom: 12, child: Text('S (S)', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight))),
                Positioned(left: 14, child: Text('B (W)', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight))),
                Positioned(right: 14, child: Text('T (E)', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight))),

                // Rotating Needle & Qibla Indicator
                AnimatedBuilder(
                  animation: _compassController,
                  builder: (context, child) {
                    // Smooth subtle simulation rotation or exact pointer
                    return Transform.rotate(
                      angle: -0.45 + (0.05 * _compassController.value), // Pointing roughly NW (295 deg) towards Makkah from ID
                      child: child,
                    );
                  },
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Compass needle
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // North/Qibla Pointer with Kaaba symbol
                            Container(
                              width: 32,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryDark],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                boxShadow: [
                                  BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, -2)),
                                ],
                              ),
                              alignment: Alignment.topCenter,
                              padding: const EdgeInsets.only(top: 6),
                              child: const Icon(Icons.navigation_rounded, color: AppColors.secondaryLight, size: 20),
                            ),
                            // South tail
                            Container(
                              width: 14,
                              height: 70,
                              decoration: BoxDecoration(
                                color: AppColors.borderLight.withValues(alpha: 0.7),
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                              ),
                            ),
                          ],
                        ),

                        // Kaaba Icon Floating at Tip of Needle
                        Positioned(
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.secondaryLight, width: 2),
                            ),
                            child: Text('🕋', style: GoogleFonts.poppins(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Center pivot cap
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.secondaryLight, width: 3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Degree Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryDark.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.compass, color: AppColors.primaryDark, size: 18),
                  const SizedBox(width: 8),
                  Text('Sudut Kiblat: 295° (Barat Laut)', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final schedule = PrayerScheduleUtils.getTodaySchedule(now);
    final nextPrayer = PrayerScheduleUtils.getNextPrayer(now);
    final countdownText = PrayerScheduleUtils.formatCountdown(nextPrayer.targetTime, spaced: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal Sholat & Arah Kiblat Makkah', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        // Sound button removed from top right per user request
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Next Prayer Hero Countdown Banner
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'MASJIDIL HARAM, MAKKAH',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          HijriDateUtils.getTodayFormatted(),
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sholat Selanjutnya (${nextPrayer.name})',
                              style: GoogleFonts.poppins(fontSize: 15, color: Colors.white70),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${nextPrayer.timeFormatted} WIB',
                              style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text('HITUNG MUNDUR', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white70)),
                            const SizedBox(height: 2),
                            Text(countdownText, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.secondaryLight)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().scale(duration: 400.ms),
            const SizedBox(height: 24),

            // Interactive Qibla Indicator & Silent Mode Card (Lock / Unlock)
            Row(
              children: [
                // Clickable Arah Kiblat -> Opens Compass Sheet
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showQiblaCompass(context),
                      borderRadius: BorderRadius.circular(20),
                      child: AppleCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.compass, color: AppColors.primaryDark, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Arah Kiblat', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondaryLight)),
                                  Text('Buka Kompas', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Clickable Senyap Otomatis -> Lock & Unlock Silent Mode
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggleSilentLock,
                      borderRadius: BorderRadius.circular(20),
                      child: AppleCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _isSilentReminder ? AppColors.primaryDark.withValues(alpha: 0.15) : AppColors.secondaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isSilentReminder ? LucideIcons.volumeX : LucideIcons.volume2,
                                color: _isSilentReminder ? AppColors.primaryDark : AppColors.secondaryDark,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Senyap Otomatis', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondaryLight)),
                                  Text(
                                    _isSilentReminder ? 'Terkunci (Lock)' : 'Terbuka (Unlock)',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _isSilentReminder ? AppColors.primaryDark : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Full Schedule Table
            SectionHeader(title: 'Jadwal Sholat Hari Ini (Umm al-Qura)'),
            AppleCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: schedule.map((s) {
                  final isNext = s.isNext;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isNext ? AppColors.primary.withValues(alpha: 0.12) : null,
                      borderRadius: BorderRadius.circular(16),
                      border: isNext ? Border.all(color: AppColors.primary, width: 1.5) : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(s.icon, color: isNext ? AppColors.primaryDark : AppColors.primary, size: 22),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: isNext ? FontWeight.w800 : FontWeight.w600,
                                    color: isNext ? AppColors.primaryDark : null,
                                  ),
                                ),
                                Text(s.status, style: GoogleFonts.poppins(fontSize: 12, color: isNext ? AppColors.primaryDark : AppColors.textSecondaryLight)),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '${s.timeFormatted} WIB',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: isNext ? FontWeight.w800 : FontWeight.w700,
                                color: isNext ? AppColors.primaryDark : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isNext)
                              const Icon(Icons.notifications_active_rounded, color: AppColors.primaryDark, size: 18),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
