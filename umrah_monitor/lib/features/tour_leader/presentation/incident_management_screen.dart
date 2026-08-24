import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../tracking/presentation/incident_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IncidentManagementScreen extends ConsumerStatefulWidget {
  const IncidentManagementScreen({super.key});

  @override
  ConsumerState<IncidentManagementScreen> createState() => _IncidentManagementScreenState();
}

class _IncidentManagementScreenState extends ConsumerState<IncidentManagementScreen> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allIncidents = ref.watch(incidentProvider);
    
    final filteredIncidents = allIncidents.where((inc) {
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
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pemantauan & Penanganan Darurat Jamaah Kloter 4',
                          style: TextStyle(
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
                    label: Text('Catat', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
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
                          style: TextStyle(
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
                            style: TextStyle(
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
                                        style: TextStyle(
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
                                style: TextStyle(
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
                                    style: TextStyle(
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
                                      style: TextStyle(
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
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
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
                                    label: Text('Kirim Bantuan Medis', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.primary),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (inc.status != 'resolved')
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        ref.read(incidentProvider.notifier).updateIncidentStatus(inc.id, 'resolved');
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Insiden ${inc.id} berhasil ditandai Selesai Ditangani!'),
                                            backgroundColor: AppColors.successGreen,
                                          ),
                                        );
                                      },
                                      icon: const Icon(LucideIcons.checkCircle2, size: 16, color: Colors.white),
                                      label: Text('Tandai Selesai', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
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
                  Text('Catat Laporan Insiden Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  IconButton(icon: const Icon(LucideIcons.x, size: 20), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              Text('ID atau Nama Jamaah:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Contoh: H. Ahmad Zaki (PL-88210)...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 14),
              Text('Deskripsi Insiden & Penanganan:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Jelaskan kondisi darurat atau bantuan yang diperlukan...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
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
                    ref.read(incidentProvider.notifier).addIncident(
                      IncidentModel(
                        id: 'SOS-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                        title: descCtrl.text.trim().isEmpty ? 'Laporan Bantuan Darurat' : descCtrl.text.trim(),
                        pilgrimName: nameCtrl.text.trim(),
                        type: 'sos',
                        priority: 'high',
                        time: 'Baru Saja',
                        location: 'Area Masjidil Haram / Hotel Swissôtel',
                        status: 'open',
                      ),
                    );
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
                  child: Text('Simpan & Siagakan Tim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
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
