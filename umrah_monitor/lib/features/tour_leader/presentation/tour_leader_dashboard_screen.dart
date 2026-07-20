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

class TourLeaderDashboardScreen extends ConsumerWidget {
  const TourLeaderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
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
                  roleSubtitle: 'Pembimbing Kloter • Kloter 4 Al-Barakah',
                  avatarUrl: user?.avatarUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
                  statusChips: const [
                    RoleStatusChip(label: '42 Jamaah Aktif', iconColor: AppColors.successGreen, icon: LucideIcons.users),
                    RoleStatusChip(label: 'Jadwal Hari Ini: 4', iconColor: AppColors.infoBlue, icon: LucideIcons.calendarCheck),
                  ],
                  currentLocation: 'Masjidil Haram, Makkah',
                  lastUpdatedText: 'Status: Memimpin',
                ).animate().fadeIn().scale(duration: 400.ms),
                const SizedBox(height: 24),

                // Telemetry & Status Grid
                SectionHeader(title: 'Status & Telemetri Rombongan'),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      context,
                      title: 'Hadir & Check-In',
                      count: '42',
                      total: '/ 45',
                      icon: LucideIcons.userCheck,
                      color: AppColors.successGreen,
                      onTap: () => context.push('/tour_leader/pilgrims'),
                    ),
                    _buildStatCard(
                      context,
                      title: 'Keluar Rute / Radius',
                      count: '2',
                      total: 'Orang',
                      icon: LucideIcons.alertTriangle,
                      color: AppColors.warningAmber,
                      onTap: () => context.push('/tour_leader/pilgrims'),
                    ),
                    _buildStatCard(
                      context,
                      title: 'Darurat SOS Aktif',
                      count: '1',
                      total: 'Kritis',
                      icon: LucideIcons.shieldAlert,
                      color: AppColors.emergencyRed,
                      onTap: () => context.push('/tour_leader/incidents'),
                    ),
                    _buildStatCard(
                      context,
                      title: 'Baterai Lemah',
                      count: '3',
                      total: '< 20%',
                      icon: LucideIcons.batteryWarning,
                      color: AppColors.infoBlue,
                      onTap: () => context.push('/tour_leader/pilgrims'),
                    ),
                  ],
                ).animate().fadeIn().scale(duration: 400.ms),
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
                        label: 'Absensi Otomatis',
                        icon: LucideIcons.checkSquare,
                        color: AppColors.infoBlue,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('45 jamaah ditandai Hadir melalui sinkronisasi kedekatan Bluetooth & GPS.'),
                              backgroundColor: AppColors.successGreen,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionBtn(
                        context,
                        label: 'Pusat Operasional',
                        icon: LucideIcons.phoneCall,
                        color: AppColors.secondaryDark,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Menghubungkan ke Kantor Pusat Operasional Al-Barakah (+966 12 555 8899)...'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Logistics & Schedule Status Card
                SectionHeader(title: 'Logistik & Agenda Rombongan'),
                AppleCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(LucideIcons.bus, color: AppColors.primary, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Status Bus Rombongan #08',
                                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          StatusBadge(label: 'SIAP DI LOBI HOTEL', color: AppColors.successGreen),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryDark.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(LucideIcons.building, color: AppColors.secondaryDark, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Kunci Kamar Swissôtel Al Maqam',
                                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          Text(
                            '23/23 Terdistribusi',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      InkWell(
                        onTap: () => context.push('/tour_leader/schedule'),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(LucideIcons.calendarRange, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Kelola Jadwal & Agenda Kloter',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(LucideIcons.arrowRight, color: AppColors.primary, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Active Incidents Preview
                SectionHeader(
                  title: 'Insiden Prioritas Aktif',
                  actionText: 'Lihat Semua (4)',
                  onAction: () => context.push('/tour_leader/incidents'),
                ),
                AppleCard(
                  padding: const EdgeInsets.all(18),
                  border: Border.all(color: AppColors.emergencyRed, width: 1.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatusBadge(label: 'KRITIS • SOS MEDIS', color: AppColors.emergencyRed),
                          Text(
                            '5 menit lalu',
                            style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Jamaah #PL-9021 melaporkan Kelelahan & Pusing di Safa Marwah',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hj. Fatimah Zahra • Usia 68 Tahun • Penurunan Tekanan Darah',
                        style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Menghubungi Ketua Regu & Jamaah...'),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              },
                              icon: const Icon(LucideIcons.phoneCall, size: 18, color: AppColors.primary),
                              label: Text(
                                'Telepon Jamaah',
                                style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/tour_leader/incidents'),
                              icon: const Icon(LucideIcons.shieldAlert, size: 18, color: Colors.white),
                              label: Text(
                                'Respons Darurat',
                                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                backgroundColor: AppColors.emergencyRed,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
              Text('Siarkan Pengumuman Rombongan', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pemberitahuan darurat ini akan berbunyi di 45 ponsel jamaah dan keluarga pemantau secara seketika.',
                style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                style: GoogleFonts.outfit(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tulis pesan (misal: Segera berkumpul di lobi hotel dalam 15 menit)...',
                  hintStyle: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondaryLight),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.outfit(color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600)),
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
              child: Text('Siarkan Sekarang', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateJourneyDialog(BuildContext context, WidgetRef ref) {
    String selectedActivity = 'Menuju Masjidil Haram';
    String selectedLocation = 'Lingkar Makkah • Gerbang 1 King Abdulaziz';
    String selectedNext = 'Mulai Ibadah Tawaf & Sa\'i';

    final activities = [
      'Check Out Hotel Swissôtel',
      'Menuju Miqat Bir Ali',
      'Menuju Masjidil Haram',
      'Mulai Tawaf Mengelilingi Ka\'bah',
      'Mulai Sa\'i di Bukit Safa-Marwah',
      'Tahallul (Cukur / Potong Rambut)',
      'Ziarah Sejarah Jabal Rahmah',
      'Kembali ke Hotel Swissôtel Al Maqam',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.rotateCw, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text('Perbarui Tahapan Perjalanan', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Memilih tahapan baru akan otomatis memperbarui status kehadiran 45 jamaah menjadi HADIR serta memberi notifikasi real-time ke keluarga di tanah air.',
                      style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Text('Tahapan Aktivitas Saat Ini:', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedActivity,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: activities
                          .map((act) => DropdownMenuItem(
                                value: act,
                                child: Text(act, style: GoogleFonts.outfit(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedActivity = val;
                            if (val == 'Check Out Hotel Swissôtel') {
                              selectedLocation = 'Lobi Hotel Swissôtel Al Maqam Makkah';
                              selectedNext = 'Menuju Miqat / Kumpul di Bus VIP';
                            } else if (val == 'Mulai Tawaf Mengelilingi Ka\'bah') {
                              selectedLocation = 'Masjidil Haram • Lantai 1 Mataf';
                              selectedNext = 'Mulai Sa\'i di Safa-Marwah';
                            } else if (val == 'Mulai Sa\'i di Bukit Safa-Marwah') {
                              selectedLocation = 'Masjidil Haram • Jalur Sa\'i';
                              selectedNext = 'Tahallul (Cukur Rambut)';
                            } else {
                              selectedLocation = 'Masjidil Haram • Titik Kumpul Kloter';
                              selectedNext = 'Agenda Perjalanan Selanjutnya';
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    Text('Lokasi Real-Time Rombongan:', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextFormField(
                      initialValue: selectedLocation,
                      style: GoogleFonts.outfit(fontSize: 14),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (val) => selectedLocation = val,
                    ),
                    const SizedBox(height: 14),
                    Text('Estimasi Agenda Berikutnya:', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextFormField(
                      initialValue: selectedNext,
                      style: GoogleFonts.outfit(fontSize: 14),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (val) => selectedNext = val,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal', style: GoogleFonts.outfit(color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(journeyProvider.notifier).updateJourneyStatus(
                          activity: selectedActivity,
                          location: selectedLocation,
                          nextActivity: selectedNext,
                          updatedBy: 'Ust. Muhammad Ridwan (TL Kloter 4)',
                        );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Status perjalanan diperbarui menjadi "$selectedActivity". Kehadiran 45 jamaah tersinkronisasi!'),
                        backgroundColor: AppColors.successGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Simpan & Sinkronkan', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String count,
    required String total,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AppleCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              Text(total, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondaryLight)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                count,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
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
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
