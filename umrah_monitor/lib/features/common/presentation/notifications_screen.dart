import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../auth/domain/user_model.dart';

class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final String dateGroup; // 'Today', 'Yesterday', 'Earlier This Week'
  final String category; // 'Emergency', 'Journey', 'Prayer', 'Broadcasts', 'Meeting', 'Hotel', 'Bus Departure', 'Health', 'Incident'
  final String priorityLabel; // 'HIGH PRIORITY', 'URGENT', 'ROUTINE', 'IMPORTANT'
  final IconData icon;
  final Color color;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.dateGroup,
    required this.category,
    required this.priorityLabel,
    required this.icon,
    required this.color,
    this.isRead = false,
  });
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _selectedFilter = 'Semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  bool get _isFamily {
    final authState = ref.watch(authProvider);
    return authState.user?.role == UserRole.family || authState.selectedRole == UserRole.family;
  }

  List<String> get _activeFilters {
    if (_isFamily) {
      return [
        'Semua',
        'Belum Dibaca',
        'Perjalanan',
        'Aktivitas',
        'Insiden',
        'Darurat',
      ];
    }
    return _allFilters;
  }

  final List<String> _allFilters = [
    'Semua',
    'Belum Dibaca',
    'Darurat',
    'Perjalanan',
    'Aktivitas',
    'Sholat',
    'Siaran',
    'Pertemuan',
    'Hotel',
    'Keberangkatan Bus',
    'Kesehatan',
    'Insiden',
  ];

  final List<NotificationItem> _allNotifications = [
    NotificationItem(
      id: 'n1',
      title: 'Peringatan Cuaca Darurat: Gelombang Panas Ekstrem',
      subtitle: 'Suhu siang hari di Makkah diperkirakan mencapai 44°C. Harap tetap berada di area teduh atau lobi hotel antara pukul 12:00 dan 15:00 Waktu Arab Saudi.',
      time: '10:15 AST',
      dateGroup: 'Hari Ini',
      category: 'Darurat',
      priorityLabel: 'URGEN',
      icon: LucideIcons.alertTriangle,
      color: AppColors.emergencyRed,
      isRead: false,
    ),
    NotificationItem(
      id: 'n_fam_1',
      title: 'Perpindahan Aktivitas: Menuju Sa\'i di Bukit Shafa',
      subtitle: 'Jamaah H. Ahmad Zaki Al-Farizi telah selesai melontar Thawaf dan kini berpindah ke kegiatan selanjutnya: Sa\'i 7 putaran.',
      time: '09:10 AST',
      dateGroup: 'Hari Ini',
      category: 'Aktivitas',
      priorityLabel: 'PENTING',
      icon: LucideIcons.arrowRightCircle,
      color: AppColors.primary,
      isRead: false,
    ),
    NotificationItem(
      id: 'n_fam_2',
      title: 'Aktivitas Selesai: Ibadah Thawaf Selesai',
      subtitle: 'Alhamdulillah, jamaah H. Ahmad Zaki Al-Farizi telah selesai melakukan aktivitas Thawaf mengelilingi Ka\'bah dengan selamat.',
      time: '08:55 AST',
      dateGroup: 'Hari Ini',
      category: 'Aktivitas',
      priorityLabel: 'PENTING',
      icon: LucideIcons.checkCircle2,
      color: AppColors.successGreen,
      isRead: true,
    ),
    NotificationItem(
      id: 'n2',
      title: 'Pengingat Sholat: Adzan Dzuhur Segera Tiba',
      subtitle: 'Adzan Dzuhur akan berkumandang dalam 25 menit. Siapkan wudhu Anda dan segera menuju Gerbang 1 King Abdulaziz.',
      time: '11:45 AST',
      dateGroup: 'Hari Ini',
      category: 'Sholat',
      priorityLabel: 'PRIORITAS TINGGI',
      icon: Icons.mosque_rounded,
      color: AppColors.secondaryDark,
      isRead: false,
    ),
    NotificationItem(
      id: 'n3',
      title: 'Kabar Perjalanan: Memulai Fase Thawaf & Sa\'i',
      subtitle: 'Pembimbing Ust. Ridwan memperbarui status kloter menjadi "Menuju Masjidil Haram". Status absensi: Hadir.',
      time: '08:20 AST',
      dateGroup: 'Hari Ini',
      category: 'Perjalanan',
      priorityLabel: 'PENTING',
      icon: LucideIcons.compass,
      color: AppColors.primary,
      isRead: false,
    ),
    NotificationItem(
      id: 'n4',
      title: 'Keberangkatan Bus: Bersiap di Lobi Hotel',
      subtitle: 'Bus VIP #08 Al-Safwa telah parkir di depan lobi Swissôtel Al Maqam. Seluruh jamaah dimohon naik ke bus dalam 10 menit.',
      time: '07:50 AST',
      dateGroup: 'Hari Ini',
      category: 'Keberangkatan Bus',
      priorityLabel: 'PRIORITAS TINGGI',
      icon: LucideIcons.bus,
      color: AppColors.infoBlue,
      isRead: true,
    ),
    NotificationItem(
      id: 'n5',
      title: 'Siaran Kloter: Pengarahan Malam Mutawif',
      subtitle: 'Bergabunglah dengan Ust. Ibrahim di Musholla Lantai 3 setelah sholat Maghrib untuk pengarahan jadwal Ziyarah Jabal Rahmah.',
      time: 'Kemarin, 19:30',
      dateGroup: 'Kemarin',
      category: 'Siaran',
      priorityLabel: 'RUTIN',
      icon: LucideIcons.radio,
      color: AppColors.primaryDark,
      isRead: true,
    ),
    NotificationItem(
      id: 'n6',
      title: 'Pengingat Pertemuan: Kumpul Rombongan',
      subtitle: 'Kumpul di pintu masuk Menara Jam Zamzam untuk foto bersama dan pembagian alat bantu dengar (receiver) ibadah.',
      time: 'Kemarin, 16:00',
      dateGroup: 'Kemarin',
      category: 'Pertemuan',
      priorityLabel: 'RUTIN',
      icon: LucideIcons.users,
      color: AppColors.secondaryDark,
      isRead: true,
    ),
    NotificationItem(
      id: 'n7',
      title: 'Informasi Hotel: Pembaruan Kartu Kamar',
      subtitle: 'Manajemen Swissôtel menginformasikan kunci elektronik lantai 14 telah diperbarui. Kartu kamar Anda tetap dapat digunakan secara normal.',
      time: '2 hari lalu',
      dateGroup: 'Minggu Ini',
      category: 'Hotel',
      priorityLabel: 'RUTIN',
      icon: LucideIcons.building,
      color: AppColors.primaryLight,
      isRead: true,
    ),
    NotificationItem(
      id: 'n8',
      title: 'Pemeriksaan Kesehatan & Hidrasi Tubuh',
      subtitle: 'Ingat untuk rutin mengonsumsi Vitamin C setiap hari dan minum setidaknya 2,5 liter air Zamzam selama menjalankan aktivitas fisik ibadah.',
      time: '3 hari lalu',
      dateGroup: 'Minggu Ini',
      category: 'Kesehatan',
      priorityLabel: 'PENTING',
      icon: LucideIcons.heartPulse,
      color: AppColors.successGreen,
      isRead: true,
    ),
    NotificationItem(
      id: 'n9',
      title: 'Kabar Insiden: Koper Tertukar Telah Diselesaikan',
      subtitle: 'Koper milik jamaah H. Sulaiman yang tertunda dari bandara Jeddah telah tiba dan diamankan di meja layanan Pembimbing kamar 1402.',
      time: '3 hari lalu',
      dateGroup: 'Minggu Ini',
      category: 'Insiden',
      priorityLabel: 'RUTIN',
      icon: LucideIcons.checkCircle2,
      color: AppColors.infoBlue,
      isRead: true,
    ),
  ];

  List<NotificationItem> get _activeNotifications {
    if (_isFamily) {
      return _allNotifications.where((n) {
        return n.category == 'Perjalanan' ||
            n.category == 'Aktivitas' ||
            n.category == 'Insiden' ||
            n.category == 'Darurat';
      }).toList();
    }
    return _allNotifications;
  }

  int get _unreadCount => _activeNotifications.where((n) => !n.isRead).length;

  List<NotificationItem> get _filteredNotifications {
    if (!_activeFilters.contains(_selectedFilter)) {
      _selectedFilter = 'Semua';
    }
    return _activeNotifications.where((n) {
      bool matchesFilter = true;
      if (_selectedFilter == 'Belum Dibaca') {
        matchesFilter = !n.isRead;
      } else if (_selectedFilter != 'Semua') {
        matchesFilter = n.category.toLowerCase() == _selectedFilter.toLowerCase();
      }

      final matchesSearch = _searchQuery.isEmpty ||
          n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _toggleReadStatus(NotificationItem item) {
    setState(() {
      item.isRead = !item.isRead;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredNotifications;

    // Group items by dateGroup
    final Map<String, List<NotificationItem>> grouped = {};
    for (var item in filtered) {
      grouped.putIfAbsent(item.dateGroup, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Minimalist Apple Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : AppColors.cardLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          child: Icon(
                            LucideIcons.arrowLeft,
                            size: 20,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Pusat Notifikasi',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              if (_unreadCount > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$_unreadCount baru',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Apple iOS Style Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari peringatan, jadwal sholat, info bus...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryLight,
                    ),
                    prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textSecondaryLight),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.xCircle, size: 16, color: AppColors.textSecondaryLight),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),

            // Apple Minimalist Segmented Pill Filters
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                itemCount: _activeFilters.length,
                itemBuilder: (context, index) {
                  final filter = _activeFilters[index];
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.cardDark : AppColors.cardLight),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),

            // Notification List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : AppColors.cardLight,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                            ),
                            child: const Icon(LucideIcons.bellOff, size: 36, color: AppColors.textSecondaryLight),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada notifikasi ditemukan',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Coba sesuaikan kata kunci pencarian atau filter kategori Anda.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: grouped.keys.length,
                      itemBuilder: (context, groupIndex) {
                        final dateKey = grouped.keys.elementAt(groupIndex);
                        final items = grouped[dateKey]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 8, left: 4),
                              child: Text(
                                dateKey.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                            ...items.map((item) => _buildNotificationCard(context, item, isDark)),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem item, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _toggleReadStatus(item),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: !item.isRead
                  ? item.color.withValues(alpha: 0.4)
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: !item.isRead ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: !item.isRead ? item.color.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Apple Notification App Icon Style Squircle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: item.color,
                                letterSpacing: 0.6,
                              ),
                            ),
                            if (!item.isRead) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          item.time,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: !item.isRead ? FontWeight.w700 : FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
