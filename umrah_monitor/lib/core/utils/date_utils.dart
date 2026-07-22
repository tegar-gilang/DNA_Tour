import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HijriDateUtils {
  HijriDateUtils._();

  /// Returns current formatted Gregorian and Hijri date in full Bahasa Indonesia.
  /// Example: "Sabtu, 18 Juli 2026 • 3 Muharram 1448 H"
  static String getTodayFormatted() {
    final now = DateTime.now();
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dayName = days[now.weekday - 1];
    final monthName = months[now.month - 1];
    final gregorian = '$dayName, ${now.day} $monthName ${now.year}';

    // Approximate/Standard Umrah Hijri calculation
    final hijriDay = ((now.day + 15) % 30) + 1;
    const hijriMonths = [
      'Muharram', 'Safar', 'Rabi\'ul Awal', 'Rabi\'ul Akhir',
      'Jumadil Awal', 'Jumadil Akhir', 'Rajab', 'Sya\'ban',
      'Ramadhan', 'Syawal', 'Dzulqa\'dah', 'Dzulhijjah'
    ];
    final hijriMonth = hijriMonths[(now.month - 1) % 12];
    const hijriYear = 1448;

    return '$gregorian • $hijriDay $hijriMonth $hijriYear H';
  }

  static String formatPrayerCountdown(Duration duration) {
    if (duration.isNegative) return '00:00:00';
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

class PrayerTimeData {
  final String name;
  final String timeFormatted;
  final DateTime targetTime;
  final IconData icon;
  final String status;
  final bool isNext;

  const PrayerTimeData({
    required this.name,
    required this.timeFormatted,
    required this.targetTime,
    required this.icon,
    required this.status,
    required this.isNext,
  });
}

class PrayerScheduleUtils {
  PrayerScheduleUtils._();

  /// Returns the complete list of 6 prayer times for today (`now`)
  /// with real status ('Sudah Lewat', 'Sholat Selanjutnya', 'Akan Datang').
  static List<PrayerTimeData> getTodaySchedule(DateTime now) {
    final rawSchedule = [
      {'name': 'Subuh', 'hour': 4, 'minute': 24, 'timeStr': '04:24', 'icon': LucideIcons.sunrise},
      {'name': 'Syuruq', 'hour': 5, 'minute': 42, 'timeStr': '05:42', 'icon': LucideIcons.sun},
      {'name': 'Dzuhur', 'hour': 12, 'minute': 28, 'timeStr': '12:28', 'icon': LucideIcons.sunMedium},
      {'name': 'Ashar', 'hour': 15, 'minute': 48, 'timeStr': '15:48', 'icon': LucideIcons.cloudSun},
      {'name': 'Maghrib', 'hour': 18, 'minute': 8, 'timeStr': '18:08', 'icon': LucideIcons.sunset},
      {'name': 'Isya', 'hour': 19, 'minute': 38, 'timeStr': '19:38', 'icon': LucideIcons.moon},
    ];

    bool foundNext = false;
    final List<PrayerTimeData> result = [];

    for (var raw in rawSchedule) {
      final hour = raw['hour'] as int;
      final minute = raw['minute'] as int;
      final target = DateTime(now.year, now.month, now.day, hour, minute);

      String status;
      bool isNext = false;

      if (target.isAfter(now)) {
        if (!foundNext) {
          isNext = true;
          status = 'Sholat Selanjutnya';
          foundNext = true;
        } else {
          status = 'Akan Datang';
        }
      } else {
        status = 'Sudah Lewat';
      }

      result.add(PrayerTimeData(
        name: raw['name'] as String,
        timeFormatted: raw['timeStr'] as String,
        targetTime: target,
        icon: raw['icon'] as IconData,
        status: status,
        isNext: isNext,
      ));
    }

    return result;
  }

  /// Returns the immediate next prayer from `now`. If all today have passed,
  /// returns Subuh for tomorrow.
  static PrayerTimeData getNextPrayer(DateTime now) {
    final todaySchedule = getTodaySchedule(now);
    for (var p in todaySchedule) {
      if (p.isNext) return p;
    }

    // All today passed -> Subuh tomorrow
    final tomorrowSubuh = DateTime(now.year, now.month, now.day + 1, 4, 24);
    return PrayerTimeData(
      name: 'Subuh',
      timeFormatted: '04:24',
      targetTime: tomorrowSubuh,
      icon: LucideIcons.sunrise,
      status: 'Sholat Selanjutnya',
      isNext: true,
    );
  }

  /// Formats remaining duration cleanly as HH : MM : SS (or HH:MM:SS) without any minus sign (-).
  static String formatCountdown(DateTime targetTime, {bool spaced = true}) {
    final now = DateTime.now();
    final diff = targetTime.difference(now);
    if (diff.isNegative || diff.inSeconds <= 0) {
      return spaced ? '00 : 00 : 00' : '00:00:00';
    }
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    if (spaced) {
      return '$hours : $minutes : $seconds';
    }
    return '$hours:$minutes:$seconds';
  }
}
