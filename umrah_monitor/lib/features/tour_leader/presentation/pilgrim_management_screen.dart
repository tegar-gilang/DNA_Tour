import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';

class PilgrimItemModel {
  final String id;
  final String name;
  final String passport;
  final String status; // 'checked_in', 'missing', 'low_battery'
  final int battery;
  final String location;
  final String lastSeen;
  final String health;
  final String phone;

  const PilgrimItemModel({
    required this.id,
    required this.name,
    required this.passport,
    required this.status,
    required this.battery,
    required this.location,
    required this.lastSeen,
    required this.health,
    required this.phone,
  });
}

class PilgrimManagementScreen extends StatefulWidget {
  const PilgrimManagementScreen({super.key});

  @override
  State<PilgrimManagementScreen> createState() => _PilgrimManagementScreenState();
}

class _PilgrimManagementScreenState extends State<PilgrimManagementScreen> {
  String _filter = 'Semua';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<PilgrimItemModel> _pilgrims = const [
    PilgrimItemModel(
      id: 'PL-88210',
      name: 'H. Ahmad Zaki Al-Farizi',
      passport: 'A9284192B',
      status: 'checked_in',
      battery: 86,
      location: 'Masjidil Haram Gerbang 1 King Abdulaziz',
      lastSeen: '2 menit lalu',
      health: 'Sehat & Bugar',
      phone: '+62 812-3456-7890',
    ),
    PilgrimItemModel(
      id: 'PL-90214',
      name: 'Hj. Fatimah Zahra',
      passport: 'C8810293X',
      status: 'missing',
      battery: 42,
      location: 'Area Bukit Safa-Marwah Lantai 2',
      lastSeen: '18 menit lalu',
      health: 'Melaporkan Kelelahan & Pusing',
      phone: '+62 813-1122-3344',
    ),
    PilgrimItemModel(
      id: 'PL-88402',
      name: 'H. Budi Santoso',
      passport: 'A1029384Z',
      status: 'low_battery',
      battery: 14,
      location: 'Lobi Swissôtel Al Maqam Makkah',
      lastSeen: '5 menit lalu',
      health: 'Sehat & Bugar',
      phone: '+62 811-9988-7766',
    ),
    PilgrimItemModel(
      id: 'PL-88511',
      name: 'Hj. Nurul Huda',
      passport: 'B9910293Y',
      status: 'checked_in',
      battery: 92,
      location: 'Masjidil Haram Gerbang 1 King Abdulaziz',
      lastSeen: '1 menit lalu',
      health: 'Sehat & Bugar',
      phone: '+62 812-5544-3322',
    ),
    PilgrimItemModel(
      id: 'PL-88620',
      name: 'H. Ilham Akbar',
      passport: 'A7710293W',
      status: 'checked_in',
      battery: 78,
      location: 'Kamar 1408 Swissôtel Al Maqam',
      lastSeen: '10 menit lalu',
      health: 'Sehat & Bugar',
      phone: '+62 813-8877-6655',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredList = _pilgrims.where((p) {
      if (_searchQuery.isNotEmpty &&
          !p.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !p.id.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !p.passport.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_filter == 'Hadir / Aman') return p.status == 'checked_in';
      if (_filter == 'Keluar Rute') return p.status == 'missing';
      if (_filter == 'Baterai Lemah') return p.status == 'low_battery' || p.battery < 20;
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar & Pemantauan Jamaah',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kloter 4 Al-Barakah (Total 45 Jamaah Terdaftar)',
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(LucideIcons.users, color: AppColors.primary, size: 20),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: GoogleFonts.outfit(fontSize: 14),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.primary),
                    hintText: 'Cari jamaah berdasarkan nama, ID, atau paspor...',
                    hintStyle: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondaryLight),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: ['Semua', 'Hadir / Aman', 'Keluar Rute', 'Baterai Lemah'].map((tab) {
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
                          Icon(LucideIcons.userX, size: 48, color: AppColors.textTertiaryLight),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak ditemukan jamaah dengan kriteria tersebut',
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
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
                        Color statusColor;
                        String statusLabel;
                        if (p.status == 'checked_in') {
                          statusColor = AppColors.successGreen;
                          statusLabel = 'HADIR / AMAN';
                        } else if (p.status == 'missing') {
                          statusColor = AppColors.emergencyRed;
                          statusLabel = 'KELUAR RADIUS';
                        } else {
                          statusColor = AppColors.warningAmber;
                          statusLabel = 'BATERAI LEMAH';
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: p.status == 'missing'
                                  ? AppColors.emergencyRed
                                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
                              width: p.status == 'missing' ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: p.status == 'missing' ? 0.06 : 0.02),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
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
                                      StatusBadge(label: statusLabel, color: statusColor),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (p.battery < 20 ? AppColors.emergencyRed : AppColors.successGreen)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          p.battery < 20 ? LucideIcons.batteryWarning : LucideIcons.batteryCharging,
                                          size: 14,
                                          color: p.battery < 20 ? AppColors.emergencyRed : AppColors.successGreen,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${p.battery}%',
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: p.battery < 20 ? AppColors.emergencyRed : AppColors.successGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

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
