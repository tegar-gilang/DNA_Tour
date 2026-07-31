import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../tracking/presentation/pilgrim_attendance_provider.dart';

class PilgrimConditionTag {
  final String label;
  final Color color;

  const PilgrimConditionTag(this.label, this.color);
}

class PilgrimManagementScreen extends ConsumerStatefulWidget {
  const PilgrimManagementScreen({super.key});

  @override
  ConsumerState<PilgrimManagementScreen> createState() => _PilgrimManagementScreenState();
}

class _PilgrimManagementScreenState extends ConsumerState<PilgrimManagementScreen> {
  String _filter = 'Semua';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  List<PilgrimConditionTag> _getPilgrimConditions(dynamic p) {
    if (p.status == 'checked_in') {
      return [const PilgrimConditionTag('HADIR (SUDAH ABSEN)', AppColors.successGreen)];
    }

    final conditions = <PilgrimConditionTag>[];

    // Kondisi 1: Belum Absen
    if (p.status == 'pending' || p.status == 'not_checked_in' || p.lastSeen.toLowerCase().contains('belum')) {
      conditions.add(const PilgrimConditionTag('BELUM ABSEN', AppColors.infoBlue));
    }

    // Kondisi 2: Di Luar Jangkauan / Radius
    if (p.status == 'missing' || p.location.toLowerCase().contains('luar jangkauan') || p.location.toLowerCase().contains('radius')) {
      conditions.add(const PilgrimConditionTag('DI LUAR JANGKAUAN', AppColors.emergencyRed));
    }

    // Kondisi 3: Pantauan Medis / Darurat (Logic lain)
    if (p.health.toLowerCase().contains('pusing') || p.health.toLowerCase().contains('kelelahan') || p.health.toLowerCase().contains('sakit') || p.health.toLowerCase().contains('darurat')) {
      conditions.add(const PilgrimConditionTag('PERLU PANTAUAN MEDIS', AppColors.warningAmber));
    }

    if (conditions.isEmpty) {
      conditions.add(const PilgrimConditionTag('BELUM ABSEN', AppColors.infoBlue));
    }

    return conditions;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allPilgrims = ref.watch(pilgrimAttendanceProvider);
    final filteredList = allPilgrims.where((p) {
      if (_searchQuery.isNotEmpty &&
          !p.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !p.id.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !p.passport.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      final conditions = _getPilgrimConditions(p);
      if (_filter == 'Hadir / Aman') return conditions.any((c) => c.label == 'HADIR (SUDAH ABSEN)');
      if (_filter == 'Belum Absen') return conditions.any((c) => c.label == 'BELUM ABSEN');
      if (_filter == 'Di Luar Jangkauan') return conditions.any((c) => c.label == 'DI LUAR JANGKAUAN');
      if (_filter == 'Pantauan Medis') return conditions.any((c) => c.label == 'PERLU PANTAUAN MEDIS');
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pantau Status & Absensi Jamaah',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          'Daftar jamaah kloter aktif beserta posisinya',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari nama, ID Gelang, atau nomor paspor...',
                    hintStyle: GoogleFonts.outfit(color: AppColors.textSecondaryLight, fontSize: 14),
                    icon: Icon(LucideIcons.search, size: 20, color: AppColors.textSecondaryLight),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Category Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: ['Semua', 'Hadir / Aman', 'Belum Absen', 'Di Luar Jangkauan', 'Pantauan Medis'].map((tab) {
                  final isSelected = _filter == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _filter = tab),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : (isDark ? AppColors.cardDark : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                        ),
                        child: Text(
                          tab,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Pilgrims List
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.users, size: 50, color: AppColors.textSecondaryLight),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak ada jamaah ditemukan',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final p = filteredList[index];
                        final conditions = _getPilgrimConditions(p);
                        final isMissingOrAlert = conditions.any((c) => c.label == 'DI LUAR JANGKAUAN');

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isMissingOrAlert
                                  ? AppColors.emergencyRed
                                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
                              width: isMissingOrAlert ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isMissingOrAlert ? 0.06 : 0.02),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      p.id,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Row(
                                        children: conditions.map((cond) {
                                          return Container(
                                            margin: const EdgeInsets.only(right: 6),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: cond.color.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              cond.label,
                                              style: GoogleFonts.outfit(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                color: cond.color,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),

                              // Name
                              Text(
                                p.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Location
                              Row(
                                children: [
                                  const Icon(LucideIcons.mapPin, size: 15, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      p.location,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    p.lastSeen,
                                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondaryLight),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Health Status
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.heartPulse,
                                    size: 15,
                                    color: p.status == 'missing' ? AppColors.emergencyRed : AppColors.successGreen,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    p.health,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: p.status == 'missing' ? AppColors.emergencyRed : AppColors.textSecondaryLight,
                                      fontWeight: p.status == 'missing' ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),

                              // Actions Pill Bar
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildCardAction(LucideIcons.phoneCall, 'Telepon', () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Menghubungi ${p.name} (${p.phone})...')),
                                    );
                                  }),
                                  _buildCardAction(LucideIcons.messageSquare, 'Pesan Chat', () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Membuka chat pribadi dengan ${p.name}...')),
                                    );
                                  }),
                                  _buildCardAction(LucideIcons.navigation, 'Lacak GPS', () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Memfokuskan peta pada koordinat GPS ${p.name}...')),
                                    );
                                  }),
                                  _buildCardAction(LucideIcons.userCheck, 'Tandai Hadir', () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${p.name} berhasil ditandai Hadir secara manual!'),
                                        backgroundColor: AppColors.successGreen,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
