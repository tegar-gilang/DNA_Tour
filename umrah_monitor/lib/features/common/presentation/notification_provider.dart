import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../domain/notification_model.dart';

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationNotifier()
      : super(const [
          NotificationModel(
            id: 'n1',
            title: 'Peringatan Cuaca Darurat: Gelombang Panas Ekstrem',
            subtitle: 'Suhu siang hari di Makkah diperkirakan mencapai 44°C. Harap tetap berada di area teduh atau lobi hotel antara pukul 12:00 dan 15:00 Waktu Arab Saudi.',
            time: '10:15 AST',
            dateGroup: 'Hari Ini',
            category: 'Darurat',
            priorityLabel: 'URGEN',
            icon: LucideIcons.alertTriangle,
            color: AppColors.emergencyRed,
            isRead: false,
          ),
          NotificationModel(
            id: 'n_fam_1',
            title: 'Perpindahan Aktivitas: Menuju Sa\'i di Bukit Shafa',
            subtitle: 'Jamaah H. Ahmad Zaki Al-Farizi telah selesai melontar Thawaf dan kini berpindah ke kegiatan selanjutnya: Sa\'i 7 putaran.',
            time: '09:10 AST',
            dateGroup: 'Hari Ini',
            category: 'Aktivitas',
            priorityLabel: 'PENTING',
            icon: LucideIcons.arrowRightCircle,
            color: AppColors.primary,
            isRead: false,
          ),
          NotificationModel(
            id: 'n_fam_2',
            title: 'Aktivitas Selesai: Ibadah Thawaf Selesai',
            subtitle: 'Alhamdulillah, jamaah H. Ahmad Zaki Al-Farizi telah selesai melakukan aktivitas Thawaf mengelilingi Ka\'bah dengan selamat.',
            time: '08:55 AST',
            dateGroup: 'Hari Ini',
            category: 'Aktivitas',
            priorityLabel: 'PENTING',
            icon: LucideIcons.checkCircle2,
            color: AppColors.successGreen,
            isRead: true,
          ),
          NotificationModel(
            id: 'n2',
            title: 'Pengingat Sholat: Adzan Dzuhur Segera Tiba',
            subtitle: 'Adzan Dzuhur akan berkumandang dalam 25 menit. Siapkan wudhu Anda dan segera menuju Gerbang 1 King Abdulaziz.',
            time: '11:45 AST',
            dateGroup: 'Hari Ini',
            category: 'Sholat',
            priorityLabel: 'PRIORITAS TINGGI',
            icon: Icons.mosque_rounded,
            color: AppColors.secondaryDark,
            isRead: false,
          ),
          NotificationModel(
            id: 'n3',
            title: 'Kabar Perjalanan: Memulai Fase Thawaf & Sa\'i',
            subtitle: 'Pembimbing Ust. Ridwan memperbarui status kloter menjadi "Menuju Masjidil Haram". Status absensi: Hadir.',
            time: '08:20 AST',
            dateGroup: 'Hari Ini',
            category: 'Perjalanan',
            priorityLabel: 'PENTING',
            icon: LucideIcons.compass,
            color: AppColors.primary,
            isRead: false,
          ),
          NotificationModel(
            id: 'n5',
            title: 'Siaran Kloter: Pengarahan Malam Mutawif',
            subtitle: 'Bergabunglah dengan Ust. Ibrahim di Musholla Lantai 3 setelah sholat Maghrib untuk pengarahan jadwal Ziyarah Jabal Rahmah.',
            time: 'Kemarin, 19:30',
            dateGroup: 'Kemarin',
            category: 'Siaran',
            priorityLabel: 'RUTIN',
            icon: LucideIcons.radio,
            color: AppColors.primaryDark,
            isRead: true,
          ),
          NotificationModel(
            id: 'n6',
            title: 'Pengingat Pertemuan: Kumpul Rombongan',
            subtitle: 'Kumpul di pintu masuk Menara Jam Zamzam untuk foto bersama dan pembagian alat bantu dengar (receiver) ibadah.',
            time: 'Kemarin, 16:00',
            dateGroup: 'Kemarin',
            category: 'Pertemuan',
            priorityLabel: 'RUTIN',
            icon: LucideIcons.users,
            color: AppColors.secondaryDark,
            isRead: true,
          ),
          NotificationModel(
            id: 'n7',
            title: 'Informasi Hotel: Pembaruan Kartu Kamar',
            subtitle: 'Manajemen Swissôtel menginformasikan kunci elektronik lantai 14 telah diperbarui. Kartu kamar Anda tetap dapat digunakan secara normal.',
            time: '2 hari lalu',
            dateGroup: 'Minggu Ini',
            category: 'Hotel',
            priorityLabel: 'RUTIN',
            icon: LucideIcons.building,
            color: AppColors.primaryLight,
            isRead: true,
          ),
          NotificationModel(
            id: 'n8',
            title: 'Pemeriksaan Kesehatan & Hidrasi Tubuh',
            subtitle: 'Ingat untuk rutin mengonsumsi Vitamin C setiap hari dan minum setidaknya 2,5 liter air Zamzam selama menjalankan aktivitas fisik ibadah.',
            time: '3 hari lalu',
            dateGroup: 'Minggu Ini',
            category: 'Kesehatan',
            priorityLabel: 'PENTING',
            icon: LucideIcons.heartPulse,
            color: AppColors.successGreen,
            isRead: true,
          ),
          NotificationModel(
            id: 'n9',
            title: 'Kabar Insiden: Koper Tertukar Telah Diselesaikan',
            subtitle: 'Koper milik jamaah H. Sulaiman yang tertunda dari bandara Jeddah telah tiba dan diamankan di meja layanan Pembimbing kamar 1402.',
            time: '3 hari lalu',
            dateGroup: 'Minggu Ini',
            category: 'Insiden',
            priorityLabel: 'RUTIN',
            icon: LucideIcons.checkCircle2,
            color: AppColors.infoBlue,
            isRead: true,
          ),
        ]);

  void toggleReadStatus(String id) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isRead: !item.isRead);
      }
      return item;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((item) => item.copyWith(isRead: true)).toList();
  }

  void addNotification(NotificationModel item) {
    state = [item, ...state];
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationModel>>((ref) {
  return NotificationNotifier();
});
