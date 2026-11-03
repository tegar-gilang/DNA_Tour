// test/notification_navigation_test.dart
//
// Widget and unit tests untuk navigasi Pusat Notifikasi ke:
// 1. Notifikasi SIARAN -> /pilgrim/broadcasts atau /family/broadcasts (Room Chat)
//    MENGGUNAKAN struktur StatefulShellRoute yang menyerupai arsitektur asli aplikasi
// 2. Notifikasi AKTIVITAS / SCHEDULE -> /schedule_detail/{id}
// 3. Notifikasi DARURAT / SOS -> /tour_leader/incidents (TL) atau /sos (Jamaah/Family)
// 4. Hak akses Jamaah vs Family vs Tour Leader (tidak ada redirect salah ke role lain)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:umrah_monitor/features/auth/domain/user_model.dart';
import 'package:umrah_monitor/features/auth/presentation/auth_provider.dart';
import 'package:umrah_monitor/features/common/domain/notification_model.dart';
import 'package:umrah_monitor/features/common/presentation/notification_provider.dart';
import 'package:umrah_monitor/features/common/presentation/notifications_screen.dart';

// ── Fake Notifiers ──────────────────────────────────────────────────────────

class FakeNotificationNotifier extends StateNotifier<NotificationState>
    implements NotificationNotifier {
  final List<String> markedReadIds = [];

  FakeNotificationNotifier(super.state);

  @override
  void addNotificationIfAbsent(NotificationModel item) {}

  @override
  Future<void> fetchNotifications() async {}

  @override
  Future<void> markAsRead(String id) async {
    markedReadIds.add(id);
    state = state.copyWith(
      notifications: state.notifications.map((n) {
        if (n.id == id) return n.copyWith(isRead: true);
        return n;
      }).toList(),
    );
  }
}

class FakeAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  FakeAuthNotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ── Test Setup Helpers ──────────────────────────────────────────────────────

NotificationModel _makeNotification({
  required String id,
  required String title,
  required String subtitle,
  required String category,
  String? incidentId,
  String? broadcastId,
  bool isRead = false,
}) {
  return NotificationModel(
    id: id,
    title: title,
    subtitle: subtitle,
    time: '10:00',
    dateGroup: 'Hari Ini',
    category: category,
    priorityLabel: category == 'Darurat' ? 'URGEN' : 'PENTING',
    icon: category == 'Darurat' ? LucideIcons.alertTriangle : LucideIcons.radio,
    color: Colors.red,
    isRead: isRead,
    incidentId: incidentId,
    broadcastId: broadcastId,
  );
}

/// Dummy Shell Widget untuk mensimulasikan PilgrimShell dan FamilyShell
class _TestShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final String label;

  const _TestShellScaffold({
    required this.navigationShell,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: '$label Home'),
          BottomNavigationBarItem(icon: const Icon(Icons.campaign), label: '$label Broadcast'),
        ],
      ),
    );
  }
}

Widget _buildTestAppWithRealShell({
  required List<NotificationModel> notifications,
  required UserRole role,
  required List<String> visitedLocations,
  FakeNotificationNotifier? customNotifNotifier,
}) {
  final notifNotifier = customNotifNotifier ??
      FakeNotificationNotifier(NotificationState(notifications: notifications));

  final authState = AuthState(
    isAuthenticated: true,
    selectedRole: role,
    user: UserModel(
      id: 'user-1',
      name: 'Test User',
      email: 'test@example.com',
      role: role,
      avatarUrl: '',
      passportNumber: '',
      visaNumber: '',
      groupCode: '',
      hotelName: '',
      busNumber: '',
      phone: '',
    ),
  );

  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'test_root');

  final testRouter = GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/notifications',
    routes: [
      // Pilgrim Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _TestShellScaffold(navigationShell: navigationShell, label: 'Pilgrim');
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pilgrim',
                builder: (context, state) {
                  visitedLocations.add('/pilgrim');
                  return const Scaffold(body: Text('PILGRIM_HOME_VIEW'));
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pilgrim/broadcasts',
                builder: (context, state) {
                  visitedLocations.add('/pilgrim/broadcasts');
                  return const Scaffold(body: Text('PILGRIM_BROADCAST_ROOM_CHAT'));
                },
              ),
            ],
          ),
        ],
      ),

      // Family Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _TestShellScaffold(navigationShell: navigationShell, label: 'Family');
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/family',
                builder: (context, state) {
                  visitedLocations.add('/family');
                  return const Scaffold(body: Text('FAMILY_HOME_VIEW'));
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/family/broadcasts',
                builder: (context, state) {
                  visitedLocations.add('/family/broadcasts');
                  return const Scaffold(body: Text('FAMILY_BROADCAST_ROOM_CHAT'));
                },
              ),
            ],
          ),
        ],
      ),

      // Standalone Routes
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/tour_leader/incidents',
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          visitedLocations.add('/tour_leader/incidents');
          return const Scaffold(body: Text('INCIDENTS_MANAGEMENT_SCREEN'));
        },
      ),
      GoRoute(
        path: '/sos',
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          visitedLocations.add('/sos');
          return const Scaffold(body: Text('SOS_EMERGENCY_SCREEN'));
        },
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      notificationNotifierProvider.overrideWith((ref) => notifNotifier),
      authProvider.overrideWith((ref) => FakeAuthNotifier(authState)),
    ],
    child: MaterialApp.router(
      routerConfig: testRouter,
    ),
  );
}

// ── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('Pusat Notifikasi — Integrasi Navigasi Notifikasi (dengan StatefulShellRoute)', () {
    testWidgets('Ketuk notifikasi SIARAN (Jamaah) berpindah ke /pilgrim/broadcasts tanpa assertion error', (tester) async {
      final visitedLocations = <String>[];
      final fakeNotifier = FakeNotificationNotifier(
        NotificationState(
          notifications: [
            _makeNotification(
              id: 'notif-bc-01',
              title: 'Pengumuman Manasik',
              subtitle: 'Kumpul jam 8 di lobby',
              category: 'Siaran',
              broadcastId: 'bc-uuid-123',
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        _buildTestAppWithRealShell(
          notifications: [],
          role: UserRole.pilgrim,
          visitedLocations: visitedLocations,
          customNotifNotifier: fakeNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pengumuman Manasik'), findsOneWidget);

      // Ketuk card notifikasi SIARAN
      await tester.tap(find.text('Pengumuman Manasik'));
      await tester.pumpAndSettle();

      // Verifikasi navigasi ke Room Chat Broadcast Jamaah tanpa crash assertion
      expect(visitedLocations, contains('/pilgrim/broadcasts'));
      expect(find.text('PILGRIM_BROADCAST_ROOM_CHAT'), findsOneWidget);

      // Verifikasi notifikasi ditandai telah dibaca
      expect(fakeNotifier.markedReadIds, contains('notif-bc-01'));
    });

    testWidgets('Ketuk notifikasi SIARAN (Family) berpindah ke /family/broadcasts tanpa assertion error', (tester) async {
      final visitedLocations = <String>[];
      final fakeNotifier = FakeNotificationNotifier(
        NotificationState(
          notifications: [
            _makeNotification(
              id: 'notif-bc-02',
              title: 'Pengumuman Penerbangan',
              subtitle: 'Pesawat telah mendarat di Jeddah',
              category: 'Siaran',
              broadcastId: 'bc-uuid-456',
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        _buildTestAppWithRealShell(
          notifications: [],
          role: UserRole.family,
          visitedLocations: visitedLocations,
          customNotifNotifier: fakeNotifier,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pengumuman Penerbangan'), findsOneWidget);

      // Ketuk card notifikasi SIARAN
      await tester.tap(find.text('Pengumuman Penerbangan'));
      await tester.pumpAndSettle();

      // Verifikasi navigasi ke Room Chat Broadcast Family
      expect(visitedLocations, contains('/family/broadcasts'));
      expect(find.text('FAMILY_BROADCAST_ROOM_CHAT'), findsOneWidget);
      expect(fakeNotifier.markedReadIds, contains('notif-bc-02'));
    });

    testWidgets('Tour Leader mengetuk notifikasi SIARAN tidak dialihkan ke /pilgrim/broadcasts', (tester) async {
      final visitedLocations = <String>[];
      final fakeNotifier = FakeNotificationNotifier(
        NotificationState(
          notifications: [
            _makeNotification(
              id: 'notif-bc-tl',
              title: 'Pengumuman TL',
              subtitle: 'Informasi untuk semua',
              category: 'Siaran',
              broadcastId: 'bc-tl-123',
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        _buildTestAppWithRealShell(
          notifications: [],
          role: UserRole.tourLeader,
          visitedLocations: visitedLocations,
          customNotifNotifier: fakeNotifier,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pengumuman TL'));
      await tester.pumpAndSettle();

      // Tour Leader tidak boleh dialihkan ke shell pilgrim atau family
      expect(visitedLocations.contains('/pilgrim/broadcasts'), isFalse);
      expect(visitedLocations.contains('/family/broadcasts'), isFalse);
      // Tapi notifikasi tetap ditandai dibaca
      expect(fakeNotifier.markedReadIds, contains('notif-bc-tl'));
    });

    testWidgets('Ketuk notifikasi DARURAT (Tour Leader) tetap mengarahkan ke /tour_leader/incidents', (tester) async {
      final visitedLocations = <String>[];

      await tester.pumpWidget(
        _buildTestAppWithRealShell(
          notifications: [
            _makeNotification(
              id: 'notif-sos-01',
              title: 'SOS Darurat',
              subtitle: 'Jamaah tersesat di Safa',
              category: 'Darurat',
              incidentId: 'inc-99',
            ),
          ],
          role: UserRole.tourLeader,
          visitedLocations: visitedLocations,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('SOS Darurat'));
      await tester.pumpAndSettle();

      expect(visitedLocations, contains('/tour_leader/incidents'));
      expect(find.text('INCIDENTS_MANAGEMENT_SCREEN'), findsOneWidget);
    });

    testWidgets('Ketuk notifikasi DARURAT (Jamaah) tetap mengarahkan ke /sos', (tester) async {
      final visitedLocations = <String>[];

      await tester.pumpWidget(
        _buildTestAppWithRealShell(
          notifications: [
            _makeNotification(
              id: 'notif-sos-02',
              title: 'Status Darurat Anda',
              subtitle: 'Petugas sedang menuju lokasi Anda',
              category: 'Darurat',
              incidentId: 'inc-100',
            ),
          ],
          role: UserRole.pilgrim,
          visitedLocations: visitedLocations,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Status Darurat Anda'));
      await tester.pumpAndSettle();

      expect(visitedLocations, contains('/sos'));
      expect(find.text('SOS_EMERGENCY_SCREEN'), findsOneWidget);
    });

    testWidgets('Notifikasi AKTIVITAS / non-broadcast & non-incident hanya markAsRead tanpa navigasi salah', (tester) async {
      final visitedLocations = <String>[];
      final fakeNotifier = FakeNotificationNotifier(
        NotificationState(
          notifications: [
            _makeNotification(
              id: 'notif-act-01',
              title: 'Waktu Sholat Ashar',
              subtitle: 'Waktu sholat telah tiba',
              category: 'Aktivitas',
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        _buildTestAppWithRealShell(
          notifications: [],
          role: UserRole.pilgrim,
          visitedLocations: visitedLocations,
          customNotifNotifier: fakeNotifier,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Waktu Sholat Ashar'));
      await tester.pumpAndSettle();

      // Tidak ada navigasi tak terduga
      expect(visitedLocations, isEmpty);
      // Notifikasi tetap ditandai dibaca
      expect(fakeNotifier.markedReadIds, contains('notif-act-01'));
    });
  });
}
