import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../auth/presentation/auth_provider.dart';

class TourLeaderProfileScreen extends ConsumerWidget {
  const TourLeaderProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
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
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Akun Resmi, Alokasi Kloter & Laporan',
                          style: GoogleFonts.outfit(
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
                roleSubtitle: 'ID: ${user?.id ?? 'TL-55012'} • Kloter 4 Al-Barakah',
                avatarUrl: user?.avatarUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                isVerified: false,
                statusChips: const [
                  RoleStatusChip(label: 'Mutawif Resmi Kemenag', iconColor: AppColors.successGreen, icon: LucideIcons.badgeCheck),
                  RoleStatusChip(label: 'Memimpin', iconColor: AppColors.secondaryLight, icon: LucideIcons.flag),
                  RoleStatusChip(label: '42 Jamaah Aktif', iconColor: AppColors.secondaryLight, icon: LucideIcons.users),
                ],
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
                    const Divider(height: 24),
                    _buildGroupRow('Bus VIP #08 Al-Safwa', 'Sopir: Ahmad Al-Ghamdi (+966 55 998 812)', AppColors.infoBlue),
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
                      title: Text('Unduh Rekap Absensi Harian', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15)),
                      subtitle: Text('Format PDF / Excel lengkap seluruh check-in', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondaryLight)),
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
                      title: Text('Unduh Log Kesehatan & Insiden', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 15)),
                      subtitle: Text('Dokumen resmi pemeriksaan Kementerian Agama & Kemenhaj', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondaryLight)),
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

              // Emergency Hotline Numbers
              SectionHeader(title: 'Pusat Layanan Darurat Resmi'),
              AppleCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _buildHotline(context, 'RS King Abdulaziz Makkah', '+966 12 555 1111', LucideIcons.heartPulse),
                    const Divider(height: 22),
                    _buildHotline(context, 'Polisi & Keamanan Masjidil Haram', '999 / 911', LucideIcons.shieldAlert),
                    const Divider(height: 22),
                    _buildHotline(context, 'Konsulat Jenderal RI (KJRI Jeddah)', '+966 12 671 1271', LucideIcons.landmark),
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
                      title: Text('Bahasa Aplikasi', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Bahasa Indonesia', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.primary)),
                          const SizedBox(width: 6),
                          const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textTertiaryLight),
                        ],
                      ),
                      onTap: () {},
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
                        style: GoogleFonts.outfit(color: AppColors.emergencyRed, fontWeight: FontWeight.w700, fontSize: 15),
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
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondaryLight),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHotline(BuildContext context, String name, String number, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.emergencyRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.emergencyRed, size: 18),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(
                  number,
                  style: GoogleFonts.outfit(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Menghubungi hotline $name ($number)...')),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.phoneCall, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text('Panggil', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
