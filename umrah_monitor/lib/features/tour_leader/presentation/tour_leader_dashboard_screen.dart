import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../tracking/presentation/journey_provider.dart';
import '../../tracking/presentation/pilgrim_attendance_provider.dart';

class TourLeaderDashboardScreen extends ConsumerWidget {
  const TourLeaderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final journeyState = ref.watch(journeyProvider);
    final allPilgrims = ref.watch(pilgrimAttendanceProvider);
    final presentCount = allPilgrims.where((p) => p.status == 'checked_in').length;
    final totalCount = allPilgrims.length;
    final progressValue = totalCount > 0 ? presentCount / totalCount : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 800));
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brief Profile Hero Summary Card
                RoleProfileSummaryCard(
                  name: user?.name ?? 'Ust. Muhammad Ridwan, Lc.',
                  roleSubtitle: 'Kloter 4 Al-Barakah',
                  avatarUrl: user?.avatarUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                  statusChips: const [],
                  currentLocation: 'Masjidil Haram, Makkah',
                ),
                const SizedBox(height: 24),

                // Aktivitas Perjalanan Saat Ini (Sama seperti pada role Jamaah)
                SectionHeader(title: 'Aktivitas Perjalanan Saat Ini'),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1,
                    ),
                    boxShadow: isDark ? AppColors.softShadowDark : AppColors.softShadowLight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
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
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '($presentCount/$totalCount)',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          minHeight: 8,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(LucideIcons.mapPin, size: 16, color: AppColors.textSecondaryLight),
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
                      const SizedBox(height: 40),

                      // INFORMATION LIST
                      _buildInfoRow(
                        icon: LucideIcons.user,
                        label: 'Diperbarui Oleh',
                        value: journeyState.updatedBy,
                        isDark: isDark,
                      ),
                      _buildInfoRow(
                        icon: LucideIcons.clock,
                        label: 'Terakhir Diperbarui',
                        value: journeyState.lastUpdated,
                        isDark: isDark,
                      ),
                      _buildInfoRow(
                        icon: LucideIcons.arrowRightCircle,
                        label: 'Aktivitas Berikutnya',
                        value: journeyState.nextActivity,
                        isDark: isDark,
                      ),
                      _buildInfoRow(
                        icon: LucideIcons.timer,
                        label: 'Estimasi Waktu (ETA)',
                        value: journeyState.eta,
                        isDark: isDark,
                      ),
                      _buildInfoRow(
                        icon: LucideIcons.mapPin,
                        label: 'Tahapan Saat Ini',
                        value: journeyState.progressPercentage < 0.6 ? 'Fase Makkah' : 'Fase Madinah',
                        isDark: isDark,
                      ),
                      _buildInfoRow(
                        icon: LucideIcons.calendar,
                        label: 'Estimasi Selesai',
                        value: journeyState.estimatedDuration,
                        isDark: isDark,
                        showDivider: false,
                      ),
                      const SizedBox(height: 24),

                      // ACTION SECTION
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.go('/tour_leader/schedule'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                                side: BorderSide(
                                  color: isDark ? AppColors.borderDark : AppColors.primary.withValues(alpha: 0.45),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text(
                                'Lihat Jadwal',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.go('/tour_leader/map'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                                side: BorderSide(
                                  color: isDark ? AppColors.borderDark : AppColors.primary.withValues(alpha: 0.45),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text(
                                'Lihat Peta',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _showUpdateJourneyDialog(context, ref),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                                side: BorderSide(
                                  color: isDark ? AppColors.borderDark : AppColors.primary.withValues(alpha: 0.45),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text(
                                'Perbarui',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Operational Actions
                SectionHeader(title: 'Aksi Operasional Cepat'),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionBtn(
                        context,
                        label: 'Perbarui Tahapan',
                        icon: LucideIcons.rotateCw,
                        color: AppColors.primary,
                        onTap: () => _showUpdateJourneyDialog(context, ref),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionBtn(
                        context,
                        label: 'Siarkan Broadcast',
                        icon: LucideIcons.radio,
                        color: AppColors.emergencyRed,
                        onTap: () => _showBroadcastDialog(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionBtn(
                        context,
                        label: 'Kumpulan Doa',
                        icon: Icons.menu_book_rounded,
                        color: AppColors.primary,
                        onTap: () => context.push('/prayer_collection'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionBtn(
                        context,
                        label: 'Room Chat',
                        icon: LucideIcons.messageSquare,
                        color: AppColors.secondaryDark,
                        onTap: () => context.push('/tour_leader/messages'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBroadcastDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.emergencyRed.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.radio, color: AppColors.emergencyRed, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Siarkan Pengumuman Rombongan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pemberitahuan darurat ini akan berbunyi di 45 ponsel jamaah dan keluarga pemantau secara seketika.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.4),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: controller,
                maxLines: 3,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tulis pesan (misal: Segera berkumpul di lobi hotel dalam 15 menit)...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔔 Pengumuman disiarkan ke seluruh 45 jamaah dan monitor keluarga!'),
                    backgroundColor: AppColors.emergencyRed,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emergencyRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Siarkan Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateJourneyDialog(BuildContext context, WidgetRef ref) {
    final journeyState = ref.read(journeyProvider);
    final user = ref.read(authProvider).user;
    final titleCtrl = TextEditingController(text: journeyState.currentActivity);
    final locationCtrl = TextEditingController(text: journeyState.currentLocation);
    final dateCtrl = TextEditingController(text: '20 Juli 2026 - 08:00 WAS');
    final updatedByCtrl = TextEditingController(text: user?.name != null ? '${user!.name} (TL)' : journeyState.updatedBy);
    String statusValue = 'Sedang Berlangsung (Active)';
    final descCtrl = TextEditingController();
    bool sendBroadcast = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 24,
                right: 24,
                top: 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Perbarui Tahapan Perjalanan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildModalLabel('Judul Agenda / Kegiatan', isDark),
                    _buildModalInput(titleCtrl, 'Contoh: Shalat Jumat di Masjid Nabawi', isDark),
                    const SizedBox(height: 14),

                    _buildModalLabel('Lokasi Kegiatan', isDark),
                    _buildModalInput(locationCtrl, 'Contoh: Masjid Nabawi - Gate 21', isDark),
                    const SizedBox(height: 14),

                    _buildModalLabel('Diperbarui Oleh (Petugas / TL)', isDark),
                    _buildModalInput(updatedByCtrl, 'Contoh: Ust. Muhammad Ridwan (TL)', isDark),
                    const SizedBox(height: 14),

                    _buildModalLabel('Tanggal & Jam Kegiatan', isDark),
                    _buildModalInput(dateCtrl, 'Contoh: 20 Juli 2026 - 08:00 WAS', isDark),
                    const SizedBox(height: 14),

                    _buildModalLabel('Status Agenda', isDark),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.backgroundDark : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: statusValue,
                          isExpanded: true,
                          dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Akan Datang (Upcoming)', child: Text('Akan Datang (Upcoming)')),
                            DropdownMenuItem(value: 'Sedang Berlangsung (Active)', child: Text('Sedang Berlangsung (Active)')),
                            DropdownMenuItem(value: 'Selesai (Completed)', child: Text('Selesai (Completed)')),
                          ],
                          onChanged: (val) {
                            if (val != null) setModalState(() => statusValue = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildModalLabel('Deskripsi / Catatan Bimbingan', isDark),
                    _buildModalInput(descCtrl, 'Tuliskan panduan atau catatan penting untuk jamaah...', isDark, maxLines: 3),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Siarkan Notifikasi ke Jamaah?',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Kirim pemberitahuan otomatis ke ponsel 45 jamaah',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: sendBroadcast,
                            activeThumbColor: AppColors.primary,
                            onChanged: (val) => setModalState(() => sendBroadcast = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Judul agenda tidak boleh kosong.')),
                            );
                            return;
                          }
                          ref.read(journeyProvider.notifier).updateJourneyStatus(
                                activity: titleCtrl.text.trim(),
                                location: locationCtrl.text.trim(),
                                nextActivity: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : 'Agenda Berikutnya',
                                updatedBy: updatedByCtrl.text.trim().isNotEmpty ? updatedByCtrl.text.trim() : 'Ust. Muhammad Ridwan (TL)',
                              );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✅ Tahapan diperbarui menjadi "${titleCtrl.text.trim()}"${sendBroadcast ? ' & disiarkan ke jamaah' : ''}. Kehadiran 45 jamaah tersinkronisasi!',
                              ),
                              backgroundColor: AppColors.successGreen,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'Simpan & Publikasikan Agenda',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  Widget _buildModalInput(TextEditingController controller, String hint, bool isDark, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimaryLight),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildActionBtn(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppleCard(
      onTap: onTap,
      border: Border.all(color: color.withValues(alpha: 0.45), width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondaryLight),
              const SizedBox(width: 14),
              Expanded(
                flex: 4,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
      ],
    );
  }
}
