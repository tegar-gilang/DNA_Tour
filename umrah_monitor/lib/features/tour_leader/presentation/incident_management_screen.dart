import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/design_system/custom_widgets.dart';
import '../../tracking/presentation/incident_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IncidentManagementScreen extends ConsumerStatefulWidget {
  const IncidentManagementScreen({super.key});

  @override
  ConsumerState<IncidentManagementScreen> createState() =>
      _IncidentManagementScreenState();
}

class _IncidentManagementScreenState
    extends ConsumerState<IncidentManagementScreen> {
  String _selectedFilter = 'Semua';

  // Menyimpan ID insiden yang sedang dalam proses agar tombol tidak bisa
  // ditekan ganda selama request berlangsung.
  final Set<String> _processingIds = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final incidentState = ref.watch(incidentNotifierProvider);
    final allIncidents = incidentState.incidents;

    final filteredIncidents = allIncidents.where((inc) {
      if (_selectedFilter == 'Perlu Respons') {
        return inc.status == 'triggered' || inc.status == 'acknowledged';
      }
      if (_selectedFilter == 'Dalam Penanganan') {
        return inc.status == 'in_action';
      }
      if (_selectedFilter == 'Selesai') {
        return inc.status == 'resolved';
      }
      if (_selectedFilter == 'Alarm Palsu') {
        return inc.status == 'false_alarm';
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
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
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pemantauan & Penanganan Darurat Jamaah',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.emergencyRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Muat ulang data SOS',
                    onPressed: () {
                      ref
                          .read(incidentNotifierProvider.notifier)
                          .fetchIncidents();
                    },
                    icon: Icon(
                      LucideIcons.refreshCw,
                      size: 18,
                      color: isDark
                          ? Colors.white70
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateIncidentModal(context),
                    icon: const Icon(
                      LucideIcons.plus,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Catat',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emergencyRed,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
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
                children:
                    [
                      'Semua',
                      'Perlu Respons',
                      'Dalam Penanganan',
                      'Selesai',
                      'Alarm Palsu',
                    ].map((tab) {
                      final isSelected = _selectedFilter == tab;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _selectedFilter = tab),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.emergencyRed
                                  : (isDark
                                        ? AppColors.cardDark
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.emergencyRed
                                    : (isDark
                                          ? AppColors.borderDark
                                          : AppColors.borderLight),
                              ),
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                          ? Colors.white70
                                          : AppColors.textPrimaryLight),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Incidents List / Loading / Error
            Expanded(
              child: Builder(
                builder: (context) {
                  if (incidentState.isLoading && allIncidents.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (incidentState.errorMessage != null &&
                      allIncidents.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              LucideIcons.alertTriangle,
                              size: 48,
                              color: AppColors.emergencyRed,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              incidentState.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                ref
                                    .read(incidentNotifierProvider.notifier)
                                    .fetchIncidents();
                              },
                              icon: const Icon(LucideIcons.refreshCw, size: 16),
                              label: const Text('Coba Lagi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (filteredIncidents.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => ref
                          .read(incidentNotifierProvider.notifier)
                          .fetchIncidents(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.2,
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.shieldCheck,
                                  size: 54,
                                  color: AppColors.successGreen,
                                ),
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
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref
                        .read(incidentNotifierProvider.notifier)
                        .fetchIncidents(),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
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

                        final incidentStatus = inc.incidentStatus;
                        String statusLabel = incidentStatus.label.toUpperCase();
                        Color statusColor;
                        switch (incidentStatus) {
                          case SosIncidentStatus.resolved:
                            statusColor = AppColors.successGreen;
                            break;
                          case SosIncidentStatus.falseAlarm:
                            statusColor = AppColors.textSecondaryLight;
                            break;
                          case SosIncidentStatus.inAction:
                            statusColor = AppColors.primary;
                            break;
                          case SosIncidentStatus.acknowledged:
                            statusColor = AppColors.warningAmber;
                            break;
                          case SosIncidentStatus.triggered:
                            statusColor = AppColors.emergencyRed;
                            break;
                        }

                        final isClosed =
                            incidentStatus == SosIncidentStatus.resolved ||
                            incidentStatus == SosIncidentStatus.falseAlarm;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: !isClosed
                                  ? priorityColor
                                  : (isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight),
                              width: !isClosed ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: !isClosed ? 0.06 : 0.02,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header baris 1: priority badge + ID di kiri,
                              // status badge di kanan.
                              // Gunakan Flexible pada kiri agar status badge
                              // tidak terdorong keluar layar saat label panjang.
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        StatusBadge(
                                          label: priorityLabel,
                                          color: priorityColor,
                                        ),
                                        Text(
                                          inc.id.length > 8
                                              ? inc.id.substring(0, 8)
                                              : inc.id,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: priorityColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StatusBadge(
                                    label: statusLabel,
                                    color: statusColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Judul insiden: potong dengan ellipsis jika
                              // terlalu panjang untuk menjaga layout rapi.
                              Text(
                                inc.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Nama Jamaah: dibungkus Flexible agar teks
                              // panjang tidak overflow ke luar kartu.
                              Row(
                                children: [
                                  const Icon(
                                    LucideIcons.user,
                                    size: 15,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      inc.pilgrimName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white70
                                            : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    LucideIcons.mapPin,
                                    size: 15,
                                    color: AppColors.textTertiaryLight,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      inc.location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white60
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    LucideIcons.clock,
                                    size: 15,
                                    color: AppColors.textTertiaryLight,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    inc.time,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              // Gunakan Wrap agar tombol tidak overflow pada layar kecil
                              Wrap(
                                alignment: WrapAlignment.end,
                                spacing: 10,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Mengirimkan tim bantuan ke lokasi ${inc.location}...',
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      LucideIcons.heartPulse,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    label: const Text(
                                      'Kirim Bantuan Medis',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.primary,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  // Tombol Mulai Penanganan: hanya tampil pada status
                                  // triggered dan acknowledged. Setiap penekanan
                                  // menghasilkan tepat satu PATCH sesuai aturan
                                  // transisi backend.
                                  if (incidentStatus ==
                                          SosIncidentStatus.triggered ||
                                      incidentStatus ==
                                          SosIncidentStatus.acknowledged)
                                    Builder(
                                      builder: (context) {
                                        final isProcessing = _processingIds
                                            .contains(inc.id);
                                        return ElevatedButton.icon(
                                          onPressed: isProcessing
                                              ? null
                                              : () async {
                                                  setState(() {
                                                    _processingIds.add(inc.id);
                                                  });
                                                  try {
                                                    await ref
                                                        .read(
                                                          incidentNotifierProvider
                                                              .notifier,
                                                        )
                                                        .startHandlingIncident(
                                                          inc.id,
                                                        );
                                                    if (!context.mounted) { return; }
                                                    final newStatus =
                                                        SosIncidentStatus.fromString(
                                                          incidentStatus ==
                                                                  SosIncidentStatus
                                                                      .triggered
                                                              ? 'acknowledged'
                                                              : 'in_action',
                                                        );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Status insiden diperbarui ke: ${newStatus.label}.',
                                                        ),
                                                        backgroundColor:
                                                            AppColors
                                                                .warningAmber,
                                                      ),
                                                    );
                                                  } catch (e) {
                                                    if (!context.mounted) { return; }
                                                    final safeMsg =
                                                        IncidentNotifier.extractSafeErrorMessage(
                                                          e,
                                                        );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(safeMsg),
                                                        backgroundColor:
                                                            AppColors
                                                                .emergencyRed,
                                                      ),
                                                    );
                                                  } finally {
                                                    if (mounted) {
                                                      setState(() {
                                                        _processingIds.remove(
                                                          inc.id,
                                                        );
                                                      });
                                                    }
                                                  }
                                                },
                                          icon: isProcessing
                                              ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                )
                                              : const Icon(
                                                  LucideIcons.play,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                          label: const Text(
                                            'Mulai Penanganan',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isProcessing
                                                ? AppColors.warningAmber
                                                      .withValues(alpha: 0.6)
                                                : AppColors.warningAmber,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  // Tombol Tandai Selesai: HANYA tampil jika status
                                  // in_action. Backend menolak transisi resolved dari
                                  // status lain (HTTP 422).
                                  if (incidentStatus ==
                                      SosIncidentStatus.inAction)
                                    Builder(
                                      builder: (context) {
                                        final isProcessing = _processingIds
                                            .contains(inc.id);
                                        return ElevatedButton.icon(
                                          // Nonaktifkan tombol selama proses
                                          // berjalan untuk mencegah double-tap
                                          onPressed: isProcessing
                                              ? null
                                              : () async {
                                                  setState(() {
                                                    _processingIds.add(inc.id);
                                                  });
                                                  try {
                                                    await ref
                                                        .read(
                                                          incidentNotifierProvider
                                                              .notifier,
                                                        )
                                                        .completeIncident(
                                                          inc.id,
                                                        );
                                                    if (!context.mounted) { return; }
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Insiden ${inc.id.length > 8 ? inc.id.substring(0, 8) : inc.id} berhasil diselesaikan!',
                                                        ),
                                                        backgroundColor:
                                                            AppColors
                                                                .successGreen,
                                                      ),
                                                    );
                                                  } catch (e) {
                                                    if (!context.mounted) { return; }
                                                    final safeMsg =
                                                        IncidentNotifier.extractSafeErrorMessage(
                                                          e,
                                                        );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(safeMsg),
                                                        backgroundColor:
                                                            AppColors
                                                                .emergencyRed,
                                                      ),
                                                    );
                                                  } finally {
                                                    if (mounted) {
                                                      setState(() {
                                                        _processingIds.remove(
                                                          inc.id,
                                                        );
                                                      });
                                                    }
                                                  }
                                                },
                                          icon: isProcessing
                                              ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                )
                                              : const Icon(
                                                  LucideIcons.checkCircle2,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                          label: const Text(
                                            'Tandai Selesai',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isProcessing
                                                ? AppColors.successGreen
                                                      .withValues(alpha: 0.6)
                                                : AppColors.successGreen,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
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
                  const Text(
                    'Catat Laporan Insiden Baru',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'ID atau Nama Jamaah:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Contoh: H. Ahmad Zaki (PL-88210)...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Deskripsi Insiden & Penanganan:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText:
                      'Jelaskan kondisi darurat atau bantuan yang diperlukan...',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                        const SnackBar(
                          content: Text('Nama atau ID jamaah harus diisi.'),
                        ),
                      );
                      return;
                    }
                    ref
                        .read(incidentNotifierProvider.notifier)
                        .addIncident(
                          IncidentModel(
                            id: 'SOS-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                            title: descCtrl.text.trim().isEmpty
                                ? 'Laporan Bantuan Darurat'
                                : descCtrl.text.trim(),
                            pilgrimName: nameCtrl.text.trim(),
                            type: 'sos',
                            priority: 'high',
                            time: 'Baru Saja',
                            location: 'Area Masjidil Haram / Hotel Swissôtel',
                            status: 'triggered',
                          ),
                        );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '✅ Insiden baru berhasil dicatat & disebarkan ke tim siaga!',
                        ),
                        backgroundColor: AppColors.emergencyRed,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emergencyRed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Simpan Insiden Darurat',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
