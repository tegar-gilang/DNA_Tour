import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/design_system/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../auth/domain/user_model.dart';

import '../domain/notification_model.dart';
import 'notification_provider.dart';

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
        'Siaran',
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
    'Siaran',
    'Darurat',
    'Perjalanan',
    'Aktivitas',
    'Sholat',
    'Pertemuan',
    'Hotel',
    'Keberangkatan Bus',
    'Kesehatan',
    'Insiden',
  ];

  List<NotificationModel> _getActiveNotifications(List<NotificationModel> allNotifications) {
    if (_isFamily) {
      return allNotifications.where((n) {
        return n.category == 'Siaran' ||
            n.category == 'Perjalanan' ||
            n.category == 'Aktivitas' ||
            n.category == 'Insiden' ||
            n.category == 'Darurat';
      }).toList();
    }
    return allNotifications;
  }

  int _getUnreadCount(List<NotificationModel> activeNotifications) => activeNotifications.where((n) => !n.isRead).length;

  List<NotificationModel> _getFilteredNotifications(List<NotificationModel> activeNotifications) {
    if (!_activeFilters.contains(_selectedFilter)) {
      _selectedFilter = 'Semua';
    }
    return activeNotifications.where((n) {
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

  void _onNotificationTap(NotificationModel item) {
    ref.read(notificationNotifierProvider.notifier).markAsRead(item.id);

    if (item.incidentId != null && item.incidentId!.isNotEmpty) {
      context.push('/tour_leader/incidents');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifState = ref.watch(notificationNotifierProvider);
    final allNotifications = notifState.notifications;
    final activeNotifications = _getActiveNotifications(allNotifications);
    final unreadCount = _getUnreadCount(activeNotifications);
    final filtered = _getFilteredNotifications(activeNotifications);

    // Group items by dateGroup
    final Map<String, List<NotificationModel>> grouped = {};
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
                              if (unreadCount > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$unreadCount baru',
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
                  IconButton(
                    tooltip: 'Muat ulang notifikasi',
                    onPressed: () {
                      ref.read(notificationNotifierProvider.notifier).fetchNotifications();
                    },
                    icon: Icon(
                      LucideIcons.refreshCw,
                      size: 18,
                      color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                    ),
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
                    hintStyle: const TextStyle(
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
              child: Builder(
                builder: (context) {
                  if (notifState.isLoading && allNotifications.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (notifState.errorMessage != null && allNotifications.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.alertTriangle, size: 48, color: AppColors.emergencyRed),
                            const SizedBox(height: 12),
                            Text(
                              notifState.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                ref.read(notificationNotifierProvider.notifier).fetchNotifications();
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

                  if (filtered.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => ref.read(notificationNotifierProvider.notifier).fetchNotifications(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                          Center(
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
                                const Text(
                                  'Coba sesuaikan kata kunci pencarian atau filter kategori Anda.',
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => ref.read(notificationNotifierProvider.notifier).fetchNotifications(),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                                style: const TextStyle(
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel item, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _onNotificationTap(item),
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
                          style: const TextStyle(
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
