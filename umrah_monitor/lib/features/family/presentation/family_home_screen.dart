import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../tracking/presentation/journey_provider.dart';

class FamilyHomeScreen extends ConsumerStatefulWidget {
  const FamilyHomeScreen({super.key});

  @override
  ConsumerState<FamilyHomeScreen> createState() => _FamilyHomeScreenState();
}

class _FamilyHomeScreenState extends ConsumerState<FamilyHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final jamaah = authState.jamaah;
    final journeyState = ref.watch(journeyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
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
                // Pilgrim Hero Summary Card without verified icon
                RoleProfileSummaryCard(
                  name: jamaah?.fullName ?? 'Data Jamaah Belum Tersedia',
                  roleSubtitle: 'Pemantau Keluarga',
                  isVerified: false,
                  statusChips: const [],
                  currentLocation: journeyState.currentLocation,
                  unreadCount: 3,
                ),
                const SizedBox(height: 24),

                // Aktivitas Perjalanan Saat Ini (Sync from journey provider)
                SectionHeader(title: 'Aktivitas Perjalanan Saat Ini'),
                AppleCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimaryLight,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: journeyState.progressPercentage,
                          minHeight: 8,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.15,
                          ),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              LucideIcons.mapPin,
                              size: 16,
                              color: AppColors.textSecondaryLight,
                            ),
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
                      const SizedBox(height: 24),
                      _buildDetailRow(
                        icon: LucideIcons.user,
                        label: 'Diperbarui Oleh',
                        value: journeyState.updatedBy,
                      ),
                      _buildDivider(),
                      _buildDetailRow(
                        icon: LucideIcons.clock,
                        label: 'Terakhir Diperbarui',
                        value: journeyState.lastUpdated,
                      ),
                      _buildDivider(),
                      _buildDetailRow(
                        icon: LucideIcons.arrowRightCircle,
                        label: 'Agenda Berikutnya',
                        value: journeyState.nextActivity,
                      ),
                      _buildDivider(),
                      _buildDetailRow(
                        icon: LucideIcons.timer,
                        label: 'Estimasi Waktu (ETA)',
                        value: journeyState.eta,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Personal Information Section (Full & Detailed as in Pilgrim Page)
                SectionHeader(title: 'Informasi Pribadi Jamaah (Hanya Baca)'),
                AppleCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        icon: LucideIcons.user,
                        label: 'Nama Lengkap Jamaah',
                        value: jamaah?.fullName ?? 'Belum tersedia',
                      ),
                      _buildDivider(),
                      _buildDetailRow(
                        icon: LucideIcons.flag,
                        label: 'Kewarganegaraan',
                        value: jamaah?.profile.nationality ?? 'Belum tersedia',
                      ),
                      _buildDivider(),
                      _buildDetailRow(
                        icon: LucideIcons.users,
                        label: 'Jenis Kelamin',
                        value: jamaah?.profile.gender ?? 'Belum tersedia',
                      ),
                      _buildDivider(),
                      _buildDetailRow(
                        icon: LucideIcons.phone,
                        label: 'Telepon Jamaah',
                        value: jamaah?.phone ?? 'Belum tersedia',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Journey Information Section
                SectionHeader(title: 'Rincian Perjalanan & Logistik Jamaah'),
                AppleCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        icon: LucideIcons.users,
                        label: 'Kloter & Rombongan',
                        value: jamaah?.journey.kloter?.code ?? 'Belum tersedia',
                      ),
                      _buildDivider(),
                      _buildDetailRow(
                        icon: LucideIcons.userCheck,
                        label: 'Pembimbing Utama (Tour Leader)',
                        value:
                            jamaah?.journey.tourLeader?.fullName ??
                            'Belum tersedia',
                      ),
                      _buildDivider(),
                      _buildDetailRow(
                        icon: LucideIcons.user,
                        label: 'Mutawif Lokal Makkah',
                        value:
                            jamaah?.journey.mutawif?.fullName ??
                            'Belum tersedia',
                      ),
                      _buildDivider(),
                      _buildDetailRow(
                        icon: LucideIcons.building,
                        label: 'Hotel Penginapan Makkah',
                        value: 'Belum tersedia',
                      ),
                      _buildDivider(),
                      _buildDetailRow(
                        icon: LucideIcons.building2,
                        label: 'Hotel Penginapan Madinah',
                        value: 'Belum tersedia',
                      ),
                      _buildDivider(),
                      _buildDetailRow(
                        icon: LucideIcons.planeTakeoff,
                        label: 'Tanggal Keberangkatan',
                        value:
                            jamaah?.journey.kloter?.departureDate ??
                            'Belum tersedia',
                      ),
                      _buildDivider(),
                      _buildDetailRow(
                        icon: LucideIcons.planeLanding,
                        label: 'Tanggal Kepulangan',
                        value:
                            jamaah?.journey.kloter?.returnDate ??
                            'Belum tersedia',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, thickness: 0.5),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          flex: 6,
          child: Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
