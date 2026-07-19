import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';

class IncidentModel {
  final String id;
  final String title;
  final String pilgrimName;
  final String type; // 'medical', 'sos', 'lost', 'attendance'
  final String priority; // 'critical', 'high', 'medium'
  final String time;
  final String location;
  final String status; // 'open', 'investigating', 'resolved'

  const IncidentModel({
    required this.id,
    required this.title,
    required this.pilgrimName,
    required this.type,
    required this.priority,
    required this.time,
    required this.location,
    required this.status,
  });

  IncidentModel copyWith({
    String? id,
    String? title,
    String? pilgrimName,
    String? type,
    String? priority,
    String? time,
    String? location,
    String? status,
  }) {
    return IncidentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      pilgrimName: pilgrimName ?? this.pilgrimName,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      time: time ?? this.time,
      location: location ?? this.location,
      status: status ?? this.status,
    );
  }
}

class IncidentManagementScreen extends StatefulWidget {
  const IncidentManagementScreen({super.key});

  @override
  State<IncidentManagementScreen> createState() => _IncidentManagementScreenState();
}

class _IncidentManagementScreenState extends State<IncidentManagementScreen> {
  String _selectedFilter = 'Semua';

  final List<IncidentModel> _incidents = [
    const IncidentModel(
      id: 'SOS-201',
      title: 'Darurat Medis: Kelelahan & Pusing Dilaporkan',
      pilgrimName: 'Hj. Fatimah Zahra (PL-90214)',
      type: 'medical',
      priority: 'critical',
      time: '12:05 WAS (15 menit lalu)',
      location: 'Area Bukit Safa-Marwah Lantai 2 Dekat Gate 18',
      status: 'investigating',
    ),
    const IncidentModel(
      id: 'SOS-202',
      title: 'Terlepas dari Rombongan & Kehilangan Arah',
      pilgrimName: 'H. Sulaiman Rasyid (PL-88901)',
      type: 'lost',
      priority: 'high',
      time: '11:10 WAS (1 jam lalu)',
      location: 'Parkiran Bus Jabal Rahmah Area C',
      status: 'resolved',
    ),
    const IncidentModel(
      id: 'SOS-203',
      title: 'Gagal Check-In Absensi di Lobi Hotel',
      pilgrimName: 'H. Budi Santoso (PL-88402)',
      type: 'attendance',
      priority: 'medium',
      time: '09:00 WAS (3 jam lalu)',
      location: 'Lobi Swissôtel Al Maqam Makkah',
      status: 'resolved',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredIncidents = _incidents.where((inc) {
      if (_selectedFilter == 'Perlu Respons') return inc.status != 'resolved';
      if (_selectedFilter == 'Investigasi') return inc.status == 'investigating';
      if (_selectedFilter == 'Selesai') return inc.status == 'resolved';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (Navigator.canPop(context)) ...[
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.arrowLeft),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pusat Respons SOS & Insiden',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pemantauan & Penanganan Darurat Jamaah Kloter 4',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: AppColors.emergencyRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateIncidentModal(context),
                    icon: const Icon(LucideIcons.plus, size: 16, color: Colors.white),
                    label: Text('Catat', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emergencyRed,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: ['Semua', 'Perlu Respons', 'Investigasi', 'Selesai'].map((tab) {
                  final isSelected = _selectedFilter == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedFilter = tab),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.emergencyRed : (isDark ? AppColors.cardDark : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.emergencyRed
                                : (isDark ? AppColors.borderDark : AppColors.borderLight),
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

            // Incidents List
            Expanded(
              child: filteredIncidents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.shieldCheck, size: 54, color: AppColors.successGreen),
                          const SizedBox(height: 14),
                          Text(
                            'Tidak ada insiden darurat pada kategori ini',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: filteredIncidents.length,
                      itemBuilder: (context, index) {
                        final inc = filteredIncidents[index];
                        Color priorityColor;
                        String priorityLabel;
                        if (inc.priority == 'critical') {
                          priorityColor = AppColors.emergencyRed;
                          priorityLabel = 'KRITIS • DARURAT SOS';
                        } else if (inc.priority == 'high') {
                          priorityColor = AppColors.warningAmber;
                          priorityLabel = 'PRIORITAS TINGGI';
                        } else {
                          priorityColor = AppColors.infoBlue;
                          priorityLabel = 'PERINGATAN SEDANG';
                        }

                        String statusLabel = inc.status == 'resolved'
                            ? 'SELESAI DITANGANI'
                            : (inc.status == 'investigating' ? 'SEDANG DITANGANI' : 'PERLU PENANGANAN');
                        Color statusColor = inc.status == 'resolved' ? AppColors.successGreen : priorityColor;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: inc.status != 'resolved' ? priorityColor : (isDark ? AppColors.borderDark : AppColors.borderLight),
                              width: inc.status != 'resolved' ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: inc.status != 'resolved' ? 0.06 : 0.02),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      StatusBadge(label: priorityLabel, color: priorityColor),
                                      const SizedBox(width: 8),
                                      Text(
                                        inc.id,
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: priorityColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  StatusBadge(label: statusLabel, color: statusColor),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                inc.title,
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(LucideIcons.user, size: 15, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    inc.pilgrimName,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(LucideIcons.mapPin, size: 15, color: AppColors.secondaryDark),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      inc.location,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(LucideIcons.clock, size: 15, color: AppColors.textTertiaryLight),
                                  const SizedBox(width: 8),
                                  Text(
                                    inc.time,
                                    style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondaryLight),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Mengirimkan tim bantuan ke lokasi ${inc.location}...')),
                                      );
                                    },
                                    icon: const Icon(LucideIcons.heartPulse, size: 16, color: AppColors.primary),
                                    label: Text('Kirim Bantuan Medis', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.primary)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.primary),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (inc.status != 'resolved')
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          final idx = _incidents.indexWhere((x) => x.id == inc.id);
                                          if (idx != -1) {
                                            _incidents[idx] = inc.copyWith(status: 'resolved');
                                          }
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Insiden ${inc.id} berhasil ditandai Selesai Ditangani!'),
                                            backgroundColor: AppColors.successGreen,
                                          ),
                                        );
                                      },
                                      icon: const Icon(LucideIcons.checkCircle2, size: 16, color: Colors.white),
                                      label: Text('Tandai Selesai', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.successGreen,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
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

  void _showCreateIncidentModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 24,
            right: 24,
            top: 24,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text('Catat Laporan Insiden Baru', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700)),
                  IconButton(icon: const Icon(LucideIcons.x, size: 20), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              Text('ID atau Nama Jamaah:', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                style: GoogleFonts.outfit(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Contoh: H. Ahmad Zaki (PL-88210)...',
                  hintStyle: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondaryLight),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 14),
              Text('Deskripsi Insiden & Penanganan:', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                style: GoogleFonts.outfit(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Jelaskan kondisi darurat atau bantuan yang diperlukan...',
                  hintStyle: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondaryLight),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nama atau ID jamaah harus diisi.')),
                      );
                      return;
                    }
                    setState(() {
                      _incidents.insert(
                        0,
                        IncidentModel(
                          id: 'SOS-${DateTime.now().millisecondsSinceEpoch % 1000}',
                          title: descCtrl.text.trim().isEmpty ? 'Laporan Bantuan Darurat' : descCtrl.text.trim(),
                          pilgrimName: nameCtrl.text.trim(),
                          type: 'sos',
                          priority: 'high',
                          time: 'Baru saja',
                          location: 'Area Masjidil Haram / Hotel Swissôtel',
                          status: 'investigating',
                        ),
                      );
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Insiden baru berhasil dicatat & disebarkan ke tim siaga!'),
                        backgroundColor: AppColors.emergencyRed,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emergencyRed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Simpan & Siagakan Tim', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
