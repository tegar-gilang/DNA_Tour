import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../../../core/theme/theme_provider.dart';
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
    final currentThemeMode = ref.watch(themeModeProvider);
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
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pemantauan Real-Time & Informasi Jamaah',
                          style: TextStyle(
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
                      roleSubtitle: 'Pemantau Keluarga',
                      avatarUrl: user?.avatarUrl ?? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
                      isVerified: false,
                      statusChips: const [],
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
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildPermItem('Melihat seluruh informasi pribadi & medis jamaah', true, isDark),
                          _buildPermItem('Memantau lokasi GPS jamaah & rute ibadah secara real-time', true, isDark),
                          _buildPermItem('Menerima notifikasi check-in & peringatan darurat SOS otomatis', true, isDark),
                          _buildPermItem('Menghubungi & berkirim pesan dengan Mutawif pendamping', true, isDark),
                          Divider(height: 20, color: isDark ? AppColors.borderDark : AppColors.secondary.withValues(alpha: 0.2)),
                          _buildPermItem('Tidak dapat mengubah data pribadi atau profil medis jamaah (Hanya Baca)', false, isDark),
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
                            secondary: const Icon(LucideIcons.moon, color: AppColors.secondaryDark, size: 20),
                            title: const Text('Mode Gelap (Dark Mode)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            subtitle: const Text('Sesuaikan tema warna tampilan aplikasi', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                            value: currentThemeMode == ThemeMode.dark,
                            activeThumbColor: AppColors.primary,
                            onChanged: (val) {
                              ref.read(themeModeProvider.notifier).setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                            },
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            secondary: const Icon(LucideIcons.alertTriangle, color: AppColors.secondaryDark, size: 20),
                            title: const Text('Peringatan Darurat SOS', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            subtitle: const Text('Sirine darurat instan berprioritas tinggi jika terjadi insiden kritis', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                            value: _sosAlertEnabled,
                            activeThumbColor: AppColors.primary,
                            onChanged: (val) => setState(() => _sosAlertEnabled = val),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            secondary: const Icon(LucideIcons.bellRing, color: AppColors.secondaryDark, size: 20),
                            title: const Text('Notifikasi Check-In & Kabar Ibadah', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            subtitle: const Text('Kabar saat jamaah tiba di hotel, masjid, atau bandara', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                            value: _checkInAlertEnabled,
                            activeThumbColor: AppColors.primary,
                            onChanged: (val) => setState(() => _checkInAlertEnabled = val),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(LucideIcons.logOut, color: AppColors.emergencyRed),
                            title: Text('Keluar dari Akun Keluarga', style: TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.w700)),
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
              style: TextStyle(
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
