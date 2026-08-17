import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../../../core/utils/date_utils.dart';

class PrayerTimeScreen extends StatefulWidget {
  const PrayerTimeScreen({super.key});

  @override
  State<PrayerTimeScreen> createState() => _PrayerTimeScreenState();
}

class _PrayerTimeScreenState extends State<PrayerTimeScreen> {
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
    final now = DateTime.now();
    final schedule = PrayerScheduleUtils.getTodaySchedule(now);
    final nextPrayer = PrayerScheduleUtils.getNextPrayer(now);
    final countdownText = PrayerScheduleUtils.formatCountdown(nextPrayer.targetTime, spaced: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Jadwal Sholat Makkah', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
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
            ),
            const SizedBox(height: 24),

            // Full Schedule Table
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
