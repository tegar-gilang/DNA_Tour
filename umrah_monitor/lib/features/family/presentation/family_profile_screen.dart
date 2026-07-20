import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../auth/presentation/auth_provider.dart';

class FamilyProfileScreen extends ConsumerStatefulWidget {
  const FamilyProfileScreen({super.key});

  @override
  ConsumerState<FamilyProfileScreen> createState() => _FamilyProfileScreenState();
}

class _FamilyProfileScreenState extends ConsumerState<FamilyProfileScreen> {
  bool _sosAlertEnabled = true;
  bool _checkInAlertEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          'Akun Pemantau Keluarga',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pemantauan Real-Time & Informasi Jamaah',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    // Brief Hero Profile Summary Card
                    RoleProfileSummaryCard(
                      name: user?.name ?? 'Siti Rahma Al-Farizi',
                      roleSubtitle: 'ID: ${user?.id ?? 'FM-10294'} • Pemantau Keluarga',
                      avatarUrl: user?.avatarUrl ?? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
                      isVerified: false,
                      statusChips: const [
                        RoleStatusChip(label: 'Akun Terverifikasi', iconColor: AppColors.successGreen, icon: LucideIcons.checkCircle2),
                        RoleStatusChip(label: 'Notifikasi Aktif', iconColor: AppColors.secondaryLight, icon: LucideIcons.bellRing),
                        RoleStatusChip(label: 'Akses Real-Time', iconColor: AppColors.infoBlue, icon: LucideIcons.wifi),
                      ],
                      currentLocation: 'Masjidil Haram, Makkah',
                      unreadCount: 3,
                    ),
                    const SizedBox(height: 20),

                    // WHAT FAMILY CAN DO & RESTRICTIONS NOTICE
                    SectionHeader(title: 'Hak Akses & Batasan Keluarga'),
                    AppleCard(
                      padding: const EdgeInsets.all(18),
                      color: isDark ? AppColors.cardDark : AppColors.secondaryContainer,
                      border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.shieldAlert, color: AppColors.secondaryDark, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Kebijakan Keamanan Data Jamaah',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildPermItem('Melihat seluruh informasi pribadi, medis & dokumen jamaah', true, isDark),
                          _buildPermItem('Memantau lokasi GPS jamaah & rute ibadah secara real-time', true, isDark),
                          _buildPermItem('Menerima notifikasi check-in & peringatan darurat SOS otomatis', true, isDark),
                          _buildPermItem('Menghubungi & berkirim pesan dengan Mutawif pendamping', true, isDark),
                          Divider(height: 20, color: isDark ? AppColors.borderDark : AppColors.secondary.withValues(alpha: 0.2)),
                          _buildPermItem('Tidak dapat mengubah data pribadi atau profil medis jamaah (Hanya Baca)', false, isDark),
                          _buildPermItem('Tidak dapat memodifikasi jadwal, hotel, atau alokasi bus', false, isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),





                    // Notification Settings & Account Actions
                    SectionHeader(title: 'Pengaturan Notifikasi Keluarga'),
                    AppleCard(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: Text('Peringatan Darurat SOS', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
                            subtitle: Text('Sirine darurat instan berprioritas tinggi jika terjadi insiden kritis', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondaryLight)),
                            value: _sosAlertEnabled,
                            activeThumbColor: AppColors.emergencyRed,
                            onChanged: (val) => setState(() => _sosAlertEnabled = val),
                          ),
                          SwitchListTile(
                            title: Text('Notifikasi Check-In & Kabar Ibadah', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
                            subtitle: Text('Kabar saat jamaah tiba di hotel, masjid, atau bandara', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondaryLight)),
                            value: _checkInAlertEnabled,
                            activeThumbColor: AppColors.primary,
                            onChanged: (val) => setState(() => _checkInAlertEnabled = val),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(LucideIcons.logOut, color: AppColors.emergencyRed),
                            title: Text('Keluar dari Akun Keluarga', style: GoogleFonts.outfit(color: AppColors.emergencyRed, fontWeight: FontWeight.w700)),
                            onTap: () {
                              ref.read(authProvider.notifier).logout();
                              context.go('/role_selection');
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPermItem(String text, bool isAllowed, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isAllowed
            ? (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.6))
            : AppColors.emergencyRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAllowed ? Colors.transparent : AppColors.emergencyRed.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isAllowed ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 18,
            color: isAllowed ? AppColors.successGreen : AppColors.emergencyRed,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 13,
                height: 1.35,
                color: isAllowed ? (isDark ? Colors.white : AppColors.textPrimaryLight) : AppColors.emergencyRed,
                fontWeight: isAllowed ? FontWeight.w500 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
