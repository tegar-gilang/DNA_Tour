import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../tracking/presentation/journey_provider.dart';

class FamilyHomeScreen extends ConsumerWidget {
  const FamilyHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final journeyState = ref.watch(journeyProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 800));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pilgrim Hero Summary Card
                RoleProfileSummaryCard(
                  name: 'H. Ahmad Zaki Al-Farizi',
                  roleSubtitle: 'Jamaah Terhubung • Suami (${user?.name ?? "Siti Rahma"})',
                  avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
                  statusChips: const [
                    RoleStatusChip(label: 'Aman & Sehat', iconColor: AppColors.successGreen, icon: Icons.check_circle),
                    RoleStatusChip(label: 'Baterai 86%', iconColor: AppColors.secondaryLight, icon: LucideIcons.batteryCharging),
                    RoleStatusChip(label: 'GPS Aktif', iconColor: AppColors.infoBlue, icon: LucideIcons.navigation),
                  ],
                  currentLocation: 'Masjidil Haram, Makkah',
                  lastUpdatedText: 'Diperbarui 2 mnt lalu',
                ).animate().fadeIn().scale(duration: 400.ms),
                const SizedBox(height: 24),

                // Live Synced Current Journey Activity Card
                SectionHeader(title: 'Status Perjalanan Terkini'),
                AppleCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(LucideIcons.compass, color: AppColors.primary, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        journeyState.currentActivity,
                                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        journeyState.currentLocation,
                                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondaryLight),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(label: 'HADIR', color: AppColors.successGreen),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Diperbarui Oleh:', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondaryLight)),
                                Text(journeyState.updatedBy, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Waktu Pembaruan:', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondaryLight)),
                                Text(journeyState.lastUpdated, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.arrowRightCircle, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Aktivitas Berikutnya: ${journeyState.nextActivity}',
                                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 24),

                // Quick Logistics Summary
                SectionHeader(title: 'Informasi Logistik & Hotel'),
                AppleCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _buildLogisticsRow(LucideIcons.users, 'Rombongan', 'Kloter 4 Al-Barakah'),
                      const Divider(height: 20),
                      _buildLogisticsRow(LucideIcons.building, 'Hotel Saat Ini', 'Swissôtel Al Maqam Makkah (Kamar 1408)'),
                      const Divider(height: 20),
                      _buildLogisticsRow(LucideIcons.bus, 'Nomor Bus', 'Bus #08 Al-Safwa'),
                      const Divider(height: 20),
                      _buildLogisticsRow(LucideIcons.checkCheck, 'Status Kehadiran', 'Hadir (Otomatis oleh Tour Leader)'),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 24),

                // Live Activity & Updates Stream
                SectionHeader(
                  title: 'Aktivitas Terkini',
                  actionText: 'Lihat Semua',
                  onAction: () => context.push('/family/updates'),
                ),
                AppleCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildActivityLog(
                        'Check-in di Masjidil Haram Gerbang 1',
                        '14:20 WAS - Verifikasi GPS',
                        LucideIcons.checkCircle2,
                        AppColors.successGreen,
                      ),
                      const Divider(height: 20),
                      _buildActivityLog(
                        'Pemeriksaan Medis: Nadi & Tensi Normal',
                        '10:00 WAS - Pemeriksaan Dokter Kloter',
                        LucideIcons.heartPulse,
                        AppColors.primary,
                      ),
                      const Divider(height: 20),
                      _buildActivityLog(
                        'Bus #08 Berangkat ke Jabal Rahmah',
                        '07:30 WAS - Logistik Kloter',
                        LucideIcons.bus,
                        AppColors.secondaryDark,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 24),

                // Photo Gallery Stream
                SectionHeader(title: 'Galeri Foto Rombongan'),
                SizedBox(
                  height: 130,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildPhotoCard('https://images.unsplash.com/photo-1564507592333-c60657eea523?w=400', 'Masjidil Haram'),
                      const SizedBox(width: 12),
                      _buildPhotoCard('https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?w=400', 'Tawaf Ka\'bah'),
                      const SizedBox(width: 12),
                      _buildPhotoCard('https://images.unsplash.com/photo-1542816417-0983c9c9ad53?w=400', 'Kumpul Rombongan'),
                    ],
                  ),
                ).animate().fadeIn(delay: 350.ms),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildLogisticsRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.2),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityLog(String title, String subtitle, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(subtitle, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondaryLight)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(String url, String caption) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.5),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Image.network(
              url,
              width: 160,
              height: 130,
              fit: BoxFit.cover,
            ),
            Container(
              width: 160,
              height: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                caption,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
