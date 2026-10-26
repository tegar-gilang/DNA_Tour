import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../domain/schedule_model.dart';
import 'schedule_provider.dart';

// =============================================================================
// TOUR LEADER SCHEDULE SCREEN (API-integrated)
// =============================================================================

class TourLeaderScheduleScreen extends ConsumerStatefulWidget {
  const TourLeaderScheduleScreen({super.key});

  @override
  ConsumerState<TourLeaderScheduleScreen> createState() =>
      _TourLeaderScheduleScreenState();
}

class _TourLeaderScheduleScreenState
    extends ConsumerState<TourLeaderScheduleScreen> {
  @override
  void initState() {
    super.initState();
    // Muat data dari API saat pertama kali screen dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scheduleProvider.notifier).fetchSchedules();
    });
  }

  // ---------------------------------------------------------------------------
  // UI helpers: label status
  // ---------------------------------------------------------------------------

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'SELESAI';
      case 'in_progress':
        return 'BERLANGSUNG';
      default:
        return 'AKAN DATANG';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.successGreen;
      case 'in_progress':
        return AppColors.infoBlue;
      default:
        return AppColors.textTertiaryLight;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return LucideIcons.checkCircle2;
      case 'in_progress':
        return LucideIcons.clock;
      default:
        return LucideIcons.circle;
    }
  }

  String _reminderLabel(String reminderStatus) {
    return reminderStatus == 'published' ? 'Telah Disiarkan' : 'Belum Disiarkan';
  }

  Color _reminderColor(String reminderStatus) {
    return reminderStatus == 'published'
        ? AppColors.successGreen
        : AppColors.primary;
  }

  IconData _reminderIcon(String reminderStatus) {
    return reminderStatus == 'published'
        ? LucideIcons.checkCircle
        : LucideIcons.radio;
  }

  // ---------------------------------------------------------------------------
  // Format tanggal dari ISO 8601 ke tampilan yang mudah dibaca
  // ---------------------------------------------------------------------------

  String _formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy - HH:mm', 'id').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  String _formatDateOnly(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy', 'id').format(dt);
    } catch (_) {
      return isoString;
    }
  }

  // ---------------------------------------------------------------------------
  // Konfirmasi + aksi ubah status
  // ---------------------------------------------------------------------------

  Future<void> _handleUpdateStatus(
    BuildContext context,
    ScheduleModel item,
    String newStatus,
  ) async {
    final label = _statusLabel(newStatus).toLowerCase();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Ubah Status?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Jadikan "${item.title}" menjadi status $label?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Ubah'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final success = await ref.read(scheduleProvider.notifier).updateStatus(
          scheduleId: item.id,
          newStatus: newStatus,
        );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Status "${item.title}" berhasil diubah menjadi ${_statusLabel(newStatus)}.',
          ),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      final error = ref.read(scheduleProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Gagal mengubah status. Coba lagi.'),
          backgroundColor: AppColors.emergencyRed,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Konfirmasi + aksi broadcast
  // ---------------------------------------------------------------------------

  Future<void> _handleBroadcast(
    BuildContext context,
    ScheduleModel item,
  ) async {
    if (item.reminderStatus == 'published') {
      // Sudah pernah disiarkan — tanya konfirmasi kembali
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Siarkan Ulang?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(
            '"${item.title}" sudah pernah disiarkan. Apakah Anda ingin menyiarkannya kembali?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ya, Siarkan'),
            ),
          ],
        ),
      );
      if (confirm != true || !context.mounted) return;
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Siarkan Reminder?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Kirimkan reminder jadwal "${item.title}" ke jamaah?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ya, Siarkan'),
            ),
          ],
        ),
      );
      if (confirm != true || !context.mounted) return;
    }

    final result =
        await ref.read(scheduleProvider.notifier).broadcastSchedule(item.id);

    if (!context.mounted) return;

    if (result != null) {
      final notifCount = result.notificationsProcessed;
      final successMsg = notifCount != null
          ? '🔔 Siaran berhasil diproses ($notifCount notifikasi terkirim).'
          : '🔔 Siaran berhasil diproses.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMsg),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      final error = ref.read(scheduleProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Gagal menyiarkan reminder. Coba lagi.'),
          backgroundColor: AppColors.emergencyRed,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Modal tambah jadwal
  // ---------------------------------------------------------------------------

  void _showAddScheduleModal() {
    final titleCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final picCtrl = TextEditingController();

    // Tanggal dan waktu — default hari ini + 1 jam
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));
    TimeOfDay selectedTime =
        TimeOfDay(hour: selectedDate.hour, minute: selectedDate.minute);

    DateTime? selectedEndDate;
    TimeOfDay? selectedEndTime;

    String selectedCategory = 'ibadah';

    final categories = [
      'ibadah',
      'ziarah',
      'transportasi',
      'akomodasi',
      'umum',
    ];

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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
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
                          'Tambah Agenda Kegiatan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Judul *
                    _buildModalLabel('Judul Agenda *', isDark),
                    _buildModalInput(
                      titleCtrl,
                      'Contoh: Shalat Jumat di Masjid Nabawi',
                      isDark,
                    ),
                    const SizedBox(height: 14),

                    // Kategori *
                    _buildModalLabel('Kategori *', isDark),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.backgroundDark
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          dropdownColor:
                              isDark ? AppColors.cardDark : Colors.white,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimaryLight,
                          ),
                          items: categories
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(
                                      c[0].toUpperCase() + c.substring(1),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedCategory = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Lokasi
                    _buildModalLabel('Lokasi', isDark),
                    _buildModalInput(
                      locationCtrl,
                      'Contoh: Masjid Nabawi - Gate 21',
                      isDark,
                    ),
                    const SizedBox(height: 14),

                    // Tanggal & Waktu Mulai *
                    _buildModalLabel('Tanggal & Waktu Mulai *', isDark),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateButton(
                            ctx,
                            label: _formatDateOnly(selectedDate.toIso8601String()),
                            isDark: isDark,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  selectedDate = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    selectedTime.hour,
                                    selectedTime.minute,
                                  );
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDateButton(
                            ctx,
                            label:
                                '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            isDark: isDark,
                            icon: LucideIcons.clock,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: ctx,
                                initialTime: selectedTime,
                              );
                              if (picked != null) {
                                setModalState(() {
                                  selectedTime = picked;
                                  selectedDate = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    picked.hour,
                                    picked.minute,
                                  );
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Waktu Selesai (opsional)
                    _buildModalLabel('Waktu Selesai (Opsional)', isDark),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateButton(
                            ctx,
                            label: selectedEndDate != null
                                ? _formatDateOnly(
                                    selectedEndDate!.toIso8601String())
                                : 'Pilih Tanggal',
                            isDark: isDark,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate:
                                    selectedEndDate ?? selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  final t = selectedEndTime ??
                                      TimeOfDay(
                                          hour: (selectedDate.hour + 1)
                                              .clamp(0, 23),
                                          minute: 0);
                                  selectedEndDate = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    t.hour,
                                    t.minute,
                                  );
                                  selectedEndTime = t;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDateButton(
                            ctx,
                            label: selectedEndTime != null
                                ? '${selectedEndTime!.hour.toString().padLeft(2, '0')}:${selectedEndTime!.minute.toString().padLeft(2, '0')}'
                                : 'Pilih Waktu',
                            isDark: isDark,
                            icon: LucideIcons.clock,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: ctx,
                                initialTime: selectedEndTime ??
                                    TimeOfDay(
                                        hour: (selectedDate.hour + 1)
                                            .clamp(0, 23),
                                        minute: 0),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  selectedEndTime = picked;
                                  final base = selectedEndDate ?? selectedDate;
                                  selectedEndDate = DateTime(
                                    base.year,
                                    base.month,
                                    base.day,
                                    picked.hour,
                                    picked.minute,
                                  );
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    // Tombol hapus waktu selesai
                    if (selectedEndDate != null)
                      TextButton.icon(
                        onPressed: () => setModalState(() {
                          selectedEndDate = null;
                          selectedEndTime = null;
                        }),
                        icon: const Icon(LucideIcons.x,
                            size: 14, color: AppColors.textSecondaryLight),
                        label: const Text(
                          'Hapus Waktu Selesai',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight),
                        ),
                      ),
                    const SizedBox(height: 14),

                    // PIC
                    _buildModalLabel('PIC / Penanggung Jawab', isDark),
                    _buildModalInput(
                      picCtrl,
                      'Contoh: Ust. H. Ridwan',
                      isDark,
                    ),
                    const SizedBox(height: 14),

                    // Deskripsi
                    _buildModalLabel('Deskripsi / Catatan', isDark),
                    _buildModalInput(
                      descCtrl,
                      'Tuliskan panduan atau catatan penting...',
                      isDark,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 22),

                    // Tombol Simpan
                    Consumer(
                      builder: (context, ref, _) {
                        final isSubmitting =
                            ref.watch(scheduleProvider).isSubmitting;
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () =>
                                    _submitAddSchedule(
                                      ctx: ctx,
                                      titleCtrl: titleCtrl,
                                      locationCtrl: locationCtrl,
                                      descCtrl: descCtrl,
                                      picCtrl: picCtrl,
                                      selectedDate: selectedDate,
                                      selectedEndDate: selectedEndDate,
                                      selectedCategory: selectedCategory,
                                    ),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : const Text(
                                    'Simpan Agenda',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                  ),
                          ),
                        );
                      },
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

  Future<void> _submitAddSchedule({
    required BuildContext ctx,
    required TextEditingController titleCtrl,
    required TextEditingController locationCtrl,
    required TextEditingController descCtrl,
    required TextEditingController picCtrl,
    required DateTime selectedDate,
    required DateTime? selectedEndDate,
    required String selectedCategory,
  }) async {
    // Validasi field wajib
    if (titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul agenda tidak boleh kosong.'),
          backgroundColor: AppColors.emergencyRed,
        ),
      );
      return;
    }

    // Bangun payload sesuai kontrak API backend (date: YYYY-MM-DD, time: HH:mm)
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final timeStr = DateFormat('HH:mm').format(selectedDate);
    final endTimeStr = selectedEndDate != null
        ? DateFormat('HH:mm').format(selectedEndDate)
        : null;

    final payload = <String, dynamic>{
      'title': titleCtrl.text.trim(),
      'category': selectedCategory,
      'date': dateStr,
      'time': timeStr,
      'start_time': selectedDate.toUtc().toIso8601String(),
      if (endTimeStr != null) 'end_time': endTimeStr,
      if (locationCtrl.text.trim().isNotEmpty)
        'location': locationCtrl.text.trim(),
      if (descCtrl.text.trim().isNotEmpty) ...{
        'description': descCtrl.text.trim(),
        'keterangan': descCtrl.text.trim(),
      },
      if (picCtrl.text.trim().isNotEmpty) 'pic': picCtrl.text.trim(),
    };

    final result =
        await ref.read(scheduleProvider.notifier).createSchedule(payload);

    if (!mounted) return;

    if (result != null) {
      if (ctx.mounted) {
        Navigator.pop(ctx);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agenda baru berhasil ditambahkan.'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } else {
      // Jangan tutup modal agar pengguna bisa memperbaiki input
      final error = ref.read(scheduleProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Gagal menyimpan agenda. Coba lagi.'),
          backgroundColor: AppColors.emergencyRed,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Widget helpers
  // ---------------------------------------------------------------------------

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

  Widget _buildModalInput(
    TextEditingController controller,
    String hint,
    bool isDark, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white : AppColors.textPrimaryLight,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontSize: 13, color: AppColors.textSecondaryLight),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDateButton(
    BuildContext ctx, {
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    IconData icon = LucideIcons.calendar,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color:
                      isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Timeline item builder
  // ---------------------------------------------------------------------------

  Widget _buildTimelineItem(
    ScheduleModel item,
    bool isLast,
    int index,
    bool isDark,
    ScheduleState scheduleState,
  ) {
    final statusColor = _statusColor(item.status);
    final statusLabel = _statusLabel(item.status);
    final statusIcon = _statusIcon(item.status);
    final isUpdatingStatus = scheduleState.updatingStatusId == item.id;
    final isBroadcasting = scheduleState.broadcastingId == item.id;

    Widget indicatorDot = Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color:
            statusColor.withValues(alpha: item.status == 'upcoming' ? 0.12 : 1.0),
        shape: BoxShape.circle,
        border: Border.all(color: statusColor, width: 2),
        boxShadow: item.status == 'in_progress'
            ? [
                BoxShadow(
                    color: statusColor.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 2)
              ]
            : null,
      ),
      child: Icon(
        statusIcon,
        size: 13,
        color: item.status == 'upcoming' ? statusColor : Colors.white,
      ),
    );

    if (item.status == 'in_progress') {
      indicatorDot = indicatorDot
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.12, 1.12),
            duration: 800.ms,
          );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Garis timeline vertikal
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
                              : (isDark
                                  ? Colors.white12
                                  : AppColors.borderLight)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Card konten
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
                    // Status Badge + Loading Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatusBadge(label: statusLabel, color: statusColor),
                        if (isUpdatingStatus)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Judul
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Kategori (jika tersedia)
                    if (item.category != null && item.category!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.tag,
                                size: 12, color: AppColors.textTertiaryLight),
                            const SizedBox(width: 6),
                            Text(
                              item.category![0].toUpperCase() +
                                  item.category!.substring(1),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Lokasi
                    if (item.location != null && item.location!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.mapPin,
                                size: 13, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.location!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Waktu mulai
                    Row(
                      children: [
                        const Icon(LucideIcons.calendar,
                            size: 13, color: AppColors.textTertiaryLight),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _formatDateTime(item.startTime),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Waktu selesai efektif (jika ada)
                    if (item.effectiveEndTime != null ||
                        item.endTime != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(LucideIcons.clock9,
                              size: 13, color: AppColors.textTertiaryLight),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Selesai: ${_formatDateTime(item.effectiveEndTime ?? item.endTime)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // PIC (jika ada)
                    if (item.pic != null && item.pic!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(LucideIcons.user,
                              size: 13, color: AppColors.textTertiaryLight),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'PIC: ${item.pic}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Deskripsi
                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.description!,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark
                              ? Colors.white70
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],

                    // Status mode badge
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item.statusMode == 'manual'
                                ? AppColors.warningAmber.withValues(alpha: 0.12)
                                : AppColors.infoBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.statusMode == 'manual'
                                ? 'Mode Manual'
                                : 'Mode Otomatis',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: item.statusMode == 'manual'
                                  ? AppColors.warningAmber
                                  : AppColors.infoBlue,
                            ),
                          ),
                        ),
                        // Status reminder badge
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item.reminderStatus == 'published'
                                ? AppColors.successGreen.withValues(alpha: 0.10)
                                : AppColors.textTertiaryLight
                                    .withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.reminderStatus == 'published'
                                ? 'Telah Disiarkan'
                                : 'Belum Disiarkan',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: item.reminderStatus == 'published'
                                  ? AppColors.successGreen
                                  : AppColors.textTertiaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Action row: ubah status + siarkan
                    Row(
                      children: [
                        // Ubah Status
                        Expanded(
                          child: PopupMenuButton<String>(
                            enabled: !isUpdatingStatus,
                            offset: const Offset(0, 40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            onSelected: (val) =>
                                _handleUpdateStatus(context, item, val),
                            itemBuilder: (ctx) => [
                              PopupMenuItem(
                                value: 'upcoming',
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.circle,
                                        size: 15,
                                        color: AppColors.textTertiaryLight),
                                    const SizedBox(width: 10),
                                    const Text('Akan Datang',
                                        style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'in_progress',
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.clock,
                                        size: 15, color: AppColors.primary),
                                    const SizedBox(width: 10),
                                    const Text('Sedang Berlangsung',
                                        style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'completed',
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.checkCircle2,
                                        size: 15,
                                        color: AppColors.successGreen),
                                    const SizedBox(width: 10),
                                    const Text('Tandai Selesai',
                                        style: TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.backgroundDark
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  isUpdatingStatus
                                      ? const SizedBox(
                                          width: 13,
                                          height: 13,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 1.5),
                                        )
                                      : const Icon(LucideIcons.rotateCw,
                                          size: 13, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Ubah Status',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Siarkan Reminder
                        Expanded(
                          child: InkWell(
                            onTap: isBroadcasting
                                ? null
                                : () => _handleBroadcast(context, item),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: item.reminderStatus == 'published'
                                    ? AppColors.successGreen
                                        .withValues(alpha: 0.12)
                                    : AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  isBroadcasting
                                      ? const SizedBox(
                                          width: 13,
                                          height: 13,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 1.5),
                                        )
                                      : Icon(
                                          _reminderIcon(item.reminderStatus),
                                          size: 13,
                                          color: _reminderColor(
                                              item.reminderStatus),
                                        ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isBroadcasting
                                        ? 'Menyiarkan...'
                                        : _reminderLabel(item.reminderStatus),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isBroadcasting
                                          ? AppColors.textSecondaryLight
                                          : _reminderColor(item.reminderStatus),
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
    ).animate(delay: (index * 65).ms).fadeIn(duration: 400.ms).slideY(
          begin: 0.08,
          end: 0,
        );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheduleState = ref.watch(scheduleProvider);
    final schedules = scheduleState.schedules;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------------------
            // Header
            // ----------------------------------------------------------------
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
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          scheduleState.isLoading
                              ? 'Memuat jadwal...'
                              : '${schedules.length} Agenda',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tombol refresh
                  IconButton(
                    icon: scheduleState.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(LucideIcons.refreshCw,
                            size: 18, color: AppColors.primary),
                    tooltip: 'Muat Ulang',
                    onPressed: scheduleState.isLoading
                        ? null
                        : () => ref
                            .read(scheduleProvider.notifier)
                            .fetchSchedules(),
                  ),
                  // Tombol tambah jadwal
                  ElevatedButton.icon(
                    onPressed: _showAddScheduleModal,
                    icon: const Icon(LucideIcons.plus,
                        size: 16, color: Colors.white),
                    label: const Text(
                      'Tambah',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          width: 1.5),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),

            // ----------------------------------------------------------------
            // Error banner (jika ada)
            // ----------------------------------------------------------------
            if (scheduleState.errorMessage != null && !scheduleState.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.emergencyRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.emergencyRed.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.alertCircle,
                          size: 16, color: AppColors.emergencyRed),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          scheduleState.errorMessage!,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.emergencyRed),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            ref.read(scheduleProvider.notifier).fetchSchedules(),
                        child: const Text('Coba Lagi',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.emergencyRed,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ),

            // ----------------------------------------------------------------
            // Konten utama: loading / empty / list
            // ----------------------------------------------------------------
            Expanded(
              child: _buildBody(isDark, scheduleState, schedules),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    bool isDark,
    ScheduleState scheduleState,
    List<ScheduleModel> schedules,
  ) {
    // Loading state (saat pertama kali dan daftar belum ada)
    if (scheduleState.isLoading && schedules.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Memuat jadwal...',
              style: TextStyle(color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      );
    }

    // Empty state (tidak ada jadwal dan tidak ada error)
    if (schedules.isEmpty && scheduleState.errorMessage == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.calendarX,
                size: 48, color: AppColors.textTertiaryLight),
            const SizedBox(height: 12),
            const Text(
              'Belum ada agenda kegiatan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tekan tombol Tambah untuk membuat\nagenda pertama rombongan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      );
    }

    // Empty state saat ada error
    if (schedules.isEmpty && scheduleState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.wifiOff,
                size: 48, color: AppColors.textTertiaryLight),
            const SizedBox(height: 12),
            const Text(
              'Gagal memuat jadwal',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(scheduleProvider.notifier).fetchSchedules(),
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // Daftar jadwal
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final item = schedules[index];
        final isLast = index == schedules.length - 1;
        return _buildTimelineItem(item, isLast, index, isDark, scheduleState);
      },
    );
  }
}
