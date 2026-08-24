import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';

class ScheduleAgendaItem {
  final String id;
  final String title;
  final String location;
  final String date;
  final String status; // 'completed', 'in_progress', 'upcoming'
  final String description;
  final bool isBroadcasted;

  const ScheduleAgendaItem({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.status,
    required this.description,
    this.isBroadcasted = false,
  });

  ScheduleAgendaItem copyWith({
    String? id,
    String? title,
    String? location,
    String? date,
    String? status,
    String? description,
    bool? isBroadcasted,
  }) {
    return ScheduleAgendaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      date: date ?? this.date,
      status: status ?? this.status,
      description: description ?? this.description,
      isBroadcasted: isBroadcasted ?? this.isBroadcasted,
    );
  }
}

class TourLeaderScheduleScreen extends ConsumerStatefulWidget {
  const TourLeaderScheduleScreen({super.key});

  @override
  ConsumerState<TourLeaderScheduleScreen> createState() => _TourLeaderScheduleScreenState();
}

class _TourLeaderScheduleScreenState extends ConsumerState<TourLeaderScheduleScreen> {

  final List<ScheduleAgendaItem> _agendaList = [
    const ScheduleAgendaItem(
      id: 'cp1',
      title: 'Kumpul di Bandara & Briefing Keberangkatan',
      location: 'Bandara Soekarno-Hatta Terminal 3 (Gate 4)',
      date: '14 Juli 2026 - 06:00 WAS',
      status: 'completed',
      description: 'Pemeriksaan bagasi, pembagian paspor/ID Card, serta doa bersama sebelum penerbangan.',
      isBroadcasted: true,
    ),
    const ScheduleAgendaItem(
      id: 'cp2',
      title: 'Penerbangan Langsung ke Jeddah',
      location: 'Pesawat Saudia SV 817 (Direct Flight)',
      date: '14 Juli 2026 - 10:45 WAS',
      status: 'completed',
      description: 'Durasi penerbangan sekitar 9 jam. Niat Ihram dilakukan saat melintasi Miqat Yalamlam.',
      isBroadcasted: true,
    ),
    const ScheduleAgendaItem(
      id: 'cp3',
      title: 'Kedatangan & Transit Bus VIP',
      location: 'Bandara King Abdulaziz -> Hotel Makkah',
      date: '14 Juli 2026 - 18:30 WAS',
      status: 'completed',
      description: 'Penyelesaian imigrasi dan perjalanan menuju Makkah menggunakan Bus VIP #08 Al-Safwa.',
      isBroadcasted: true,
    ),
    const ScheduleAgendaItem(
      id: 'cp4',
      title: 'Check-In Hotel Swissôtel & Istirahat',
      location: 'Swissôtel Al Maqam Makkah (Lantai 14)',
      date: '14 Juli 2026 - 21:30 WAS',
      status: 'completed',
      description: 'Pembagian kunci kamar, makan malam prasmanan di restoran, dan istirahat sebelum Umrah wajib.',
      isBroadcasted: true,
    ),
    const ScheduleAgendaItem(
      id: 'cp5',
      title: 'Pelaksanaan Umrah Wajib 1 (Tawaf & Sa\'i)',
      location: 'Masjidil Haram & Bukit Safa-Marwah',
      date: '15 Juli 2026 - 02:00 WAS',
      status: 'completed',
      description: 'Bimbingan Tawaf 7 putaran mengelilingi Ka\'bah, Sa\'i, dan diakhiri dengan Tahallul (cukur rambut).',
      isBroadcasted: true,
    ),
    const ScheduleAgendaItem(
      id: 'cp6',
      title: 'Ziarah Sejarah Kota Makkah',
      location: 'Jabal Rahmah, Gua Hira, & Mina/Arafah',
      date: '16 Juli 2026 - 07:30 WAS',
      status: 'in_progress',
      description: 'Tur edukasi dan ziarah ke tempat-tempat bersejarah menggunakan Bus Rombongan #08.',
      isBroadcasted: true,
    ),
    const ScheduleAgendaItem(
      id: 'cp7',
      title: 'Tawaf Wada (Tawaf Perpisahan Makkah)',
      location: 'Masjidil Haram - Lantai 2',
      date: '19 Juli 2026 - 08:00 WAS',
      status: 'upcoming',
      description: 'Tawaf perpisahan sebelum rombongan bersiap menuju Kota Suci Madinah Al-Munawwarah.',
      isBroadcasted: false,
    ),
    const ScheduleAgendaItem(
      id: 'cp8',
      title: 'Keberangkatan ke Madinah via Kereta Haramain',
      location: 'Stasiun Haramain Makkah -> Madinah',
      date: '19 Juli 2026 - 14:00 WAS',
      status: 'upcoming',
      description: 'Perjalanan cepat dan nyaman selama 2 jam menuju Madinah. Kumpul di lobi hotel pukul 12:30 WAS.',
      isBroadcasted: false,
    ),
  ];


  void _showAddEditAgendaModal({ScheduleAgendaItem? existingItem}) {
    final isEditing = existingItem != null;
    final titleCtrl = TextEditingController(text: existingItem?.title ?? '');
    final locationCtrl = TextEditingController(text: existingItem?.location ?? '');
    final dateCtrl = TextEditingController(text: existingItem?.date ?? '20 Juli 2026 - 08:00 WAS');
    final descCtrl = TextEditingController(text: existingItem?.description ?? '');
    String statusValue = existingItem?.status ?? 'upcoming';
    bool sendBroadcast = !isEditing;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
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
                          isEditing ? 'Ubah Agenda Kegiatan' : 'Tambah Agenda Kegiatan Baru',
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

                    _buildModalLabel('Tanggal & Jam Kegiatan', isDark),
                    _buildModalInput(dateCtrl, 'Contoh: 20 Juli 2026 - 11:30 WAS', isDark),
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
                            DropdownMenuItem(value: 'upcoming', child: Text('Akan Datang (Upcoming)')),
                            DropdownMenuItem(value: 'in_progress', child: Text('Sedang Berlangsung (Active)')),
                            DropdownMenuItem(value: 'completed', child: Text('Selesai (Completed)')),
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

                    if (!isEditing)
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

                          setState(() {
                            if (isEditing) {
                              final index = _agendaList.indexWhere((item) => item.id == existingItem.id);
                              if (index != -1) {
                                _agendaList[index] = existingItem.copyWith(
                                  title: titleCtrl.text.trim(),
                                  location: locationCtrl.text.trim(),
                                  date: dateCtrl.text.trim(),
                                  description: descCtrl.text.trim(),
                                  status: statusValue,
                                );
                              }
                            } else {
                              _agendaList.add(
                                ScheduleAgendaItem(
                                  id: 'cp_${DateTime.now().millisecondsSinceEpoch}',
                                  title: titleCtrl.text.trim(),
                                  location: locationCtrl.text.trim(),
                                  date: dateCtrl.text.trim(),
                                  status: statusValue,
                                  description: descCtrl.text.trim(),
                                  isBroadcasted: sendBroadcast,
                                ),
                              );
                            }
                          });

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing
                                    ? 'Agenda berhasil diperbarui & disinkronkan ke aplikasi jamaah.'
                                    : 'Agenda baru berhasil ditambahkan${sendBroadcast ? ' & disiarkan ke jamaah' : ''}.',
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
                          isEditing ? 'Simpan Perubahan Agenda' : 'Simpan & Publikasikan Agenda',
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

  void _updateItemStatus(ScheduleAgendaItem item, String newStatus) {
    setState(() {
      final idx = _agendaList.indexWhere((x) => x.id == item.id);
      if (idx != -1) {
        _agendaList[idx] = item.copyWith(status: newStatus);
      }
    });
    String label = newStatus == 'completed'
        ? 'Selesai'
        : (newStatus == 'in_progress' ? 'Sedang Berlangsung' : 'Akan Datang');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status "${item.title}" diubah menjadi $label.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _broadcastReminder(ScheduleAgendaItem item) {
    setState(() {
      final idx = _agendaList.indexWhere((x) => x.id == item.id);
      if (idx != -1) {
        _agendaList[idx] = item.copyWith(isBroadcasted: true);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔔 Reminder "${item.title}" berhasil disiarkan ke ponsel 45 jamaah!'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _deleteAgenda(ScheduleAgendaItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Agenda?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Apakah Anda yakin ingin menghapus "${item.title}" dari jadwal resmi rombongan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: AppColors.textSecondaryLight)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _agendaList.removeWhere((x) => x.id == item.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Agenda berhasil dihapus.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emergencyRed),
            child: Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = _agendaList.length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
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
                          'Kelola Jadwal Rombongan',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kloter 4 Al-Barakah ($total Agenda)',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditAgendaModal(),
                    icon: const Icon(LucideIcons.plus, size: 16, color: Colors.white),
                    label: Text('Tambah', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),

            // Agenda Timeline List (Garis Turus Panjang dari Atas ke Bawah)
            Expanded(
              child: _agendaList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.calendarX, size: 48, color: AppColors.textTertiaryLight),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada agenda kegiatan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                      itemCount: _agendaList.length,
                      itemBuilder: (context, index) {
                        final item = _agendaList[index];
                        final isLast = index == _agendaList.length - 1;
                        return _buildTimelineItem(item, isLast, index, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(ScheduleAgendaItem item, bool isLast, int index, bool isDark) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (item.status == 'completed') {
      statusColor = AppColors.successGreen;
      statusLabel = 'SELESAI';
      statusIcon = LucideIcons.checkCircle2;
    } else if (item.status == 'in_progress') {
      statusColor = AppColors.infoBlue;
      statusLabel = 'BERLANGSUNG';
      statusIcon = LucideIcons.clock;
    } else {
      statusColor = AppColors.textTertiaryLight;
      statusLabel = 'AKAN DATANG';
      statusIcon = LucideIcons.circle;
    }

    Widget indicatorDot = Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: item.status == 'upcoming' ? 0.12 : 1.0),
        shape: BoxShape.circle,
        border: Border.all(color: statusColor, width: 2),
        boxShadow: item.status == 'in_progress'
            ? [BoxShadow(color: statusColor.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2)]
            : null,
      ),
      child: Icon(
        statusIcon,
        size: 13,
        color: item.status == 'upcoming' ? statusColor : Colors.white,
      ),
    );

    if (item.status == 'in_progress') {
      indicatorDot = indicatorDot.animate(onPlay: (c) => c.repeat(reverse: true)).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.12, 1.12),
            duration: 800.ms,
          );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Garis Turus Panjang dari Atas ke Bawah
          Column(
            children: [
              indicatorDot,
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: item.status == 'completed'
                          ? AppColors.successGreen.withValues(alpha: 0.6)
                          : (item.status == 'in_progress'
                              ? AppColors.infoBlue.withValues(alpha: 0.6)
                              : (isDark ? Colors.white12 : AppColors.borderLight)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Checkpoint / Agenda Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: AppleCard(
                padding: const EdgeInsets.all(16),
                border: item.status == 'in_progress'
                    ? Border.all(color: AppColors.infoBlue, width: 1.5)
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge & Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatusBadge(label: statusLabel, color: statusColor),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(LucideIcons.edit3, size: 16, color: AppColors.textSecondaryLight),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                              tooltip: 'Ubah Agenda',
                              onPressed: () => _showAddEditAgendaModal(existingItem: item),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.emergencyRed),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                              tooltip: 'Hapus Agenda',
                              onPressed: () => _deleteAgenda(item),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Title
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Location & Date
                    Row(
                      children: [
                        const Icon(LucideIcons.mapPin, size: 13, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.location,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.calendar, size: 13, color: AppColors.textTertiaryLight),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.date,
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                          ),
                        ),
                      ],
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    // Bottom Controls Bar (Status Switcher & Reminder Broadcast)
                    Row(
                      children: [
                        Expanded(
                          child: PopupMenuButton<String>(
                            offset: const Offset(0, 40),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            onSelected: (val) => _updateItemStatus(item, val),
                            itemBuilder: (ctx) => [
                              PopupMenuItem(
                                value: 'upcoming',
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.circle, size: 15, color: AppColors.textTertiaryLight),
                                    const SizedBox(width: 10),
                                    Text('Jadikan Akan Datang', style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'in_progress',
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.clock, size: 15, color: AppColors.primary),
                                    const SizedBox(width: 10),
                                    Text('Jadikan Berlangsung', style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'completed',
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.checkCircle2, size: 15, color: AppColors.successGreen),
                                    const SizedBox(width: 10),
                                    Text('Tandai Selesai', style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.backgroundDark : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.rotateCw, size: 13, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Ubah Status',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => _broadcastReminder(item),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: item.isBroadcasted
                                    ? AppColors.successGreen.withValues(alpha: 0.12)
                                    : AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    item.isBroadcasted ? LucideIcons.checkCircle : LucideIcons.radio,
                                    size: 13,
                                    color: item.isBroadcasted ? AppColors.successGreen : AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item.isBroadcasted ? 'Telah Disiarkan' : 'Siarkan Reminder',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: item.isBroadcasted ? AppColors.successGreen : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: (index * 65).ms).fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0);
  }
}
