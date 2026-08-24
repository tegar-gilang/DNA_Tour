import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../auth/presentation/auth_provider.dart';

class TourLeaderProfileScreen extends ConsumerWidget {
  const TourLeaderProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
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
                          'Profil Pembimbing & Mutawif',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Akun Resmi, Alokasi Kloter & Laporan',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(LucideIcons.shieldCheck, size: 20, color: AppColors.successGreen),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

              // Brief Hero Profile Summary Card (Same as Home Page without Prayer Reminder)
              RoleProfileSummaryCard(
                name: user?.name ?? 'Ust. Muhammad Ridwan, Lc.',
                roleSubtitle: 'Kloter 4 Al-Barakah',
                avatarUrl: user?.avatarUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                isVerified: false,
                statusChips: const [],
                currentLocation: 'Masjidil Haram, Makkah',
              ),
              const SizedBox(height: 24),

              // Assigned Groups & Logistics Section
              SectionHeader(title: 'Alokasi Tugas & Logistik Kloter'),
              AppleCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _buildGroupRow('Kloter 4 Al-Barakah', '45 Jamaah Terdaftar • Fase Aktif Makkah', AppColors.primary),
                    const Divider(height: 24),
                    _buildGroupRow('Hotel Swissôtel Al Maqam Makkah', '23 Kamar Dialokasikan • Lantai 14 Check-In', AppColors.secondaryDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Operations & Reports Export Section
              SectionHeader(title: 'Ekspor Laporan & Dokumen Resmi'),
              AppleCard(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.fileSpreadsheet, color: AppColors.primary, size: 20),
                      ),
                      title: Text('Unduh Rekap Absensi Harian', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      subtitle: Text('Format PDF / Excel lengkap seluruh check-in', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                      trailing: const Icon(LucideIcons.download, size: 18, color: AppColors.primary),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📄 Rekap absensi harian berhasil diunduh & disimpan ke folder Dokumen!'),
                            backgroundColor: AppColors.successGreen,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.infoBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.fileText, color: AppColors.infoBlue, size: 20),
                      ),
                      title: Text('Unduh Log Kesehatan & Insiden', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      subtitle: Text('Dokumen resmi pemeriksaan Kementerian Agama & Kemenhaj', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                      trailing: const Icon(LucideIcons.download, size: 18, color: AppColors.infoBlue),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📑 Dokumen log kesehatan & insiden berhasil diekspor ke PDF!'),
                            backgroundColor: AppColors.infoBlue,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),



              // Settings & Logout Card
              SectionHeader(title: 'Pengaturan & Sesi'),
              AppleCard(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryDark.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.globe, color: AppColors.secondaryDark, size: 20),
                      ),
                      title: Text('Bahasa Aplikasi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Bahasa Indonesia', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                          const SizedBox(width: 6),
                          const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textTertiaryLight),
                        ],
                      ),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.moon, color: AppColors.primary, size: 20),
                      ),
                      title: const Text('Mode Gelap (Dark Mode)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      subtitle: const Text('Sesuaikan tema warna tampilan aplikasi', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                      value: currentThemeMode == ThemeMode.dark,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) {
                        ref.read(themeModeProvider.notifier).setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.emergencyRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.logOut, color: AppColors.emergencyRed, size: 20),
                      ),
                      title: Text(
                        'Keluar dari Akun Pembimbing',
                        style: TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      onTap: () {
                        ref.read(authProvider.notifier).logout();
                        context.go('/role_selection');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupRow(String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(LucideIcons.users, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
