import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umrah_monitor/core/network/api_client.dart';
import 'package:umrah_monitor/core/storage/secure_storage.dart';
import 'package:umrah_monitor/features/auth/data/auth_repository.dart';
import 'package:umrah_monitor/features/auth/data/models/auth_response.dart';
import 'package:umrah_monitor/features/auth/data/models/tour_leader_model.dart';
import 'package:umrah_monitor/features/auth/domain/user_model.dart';
import 'package:umrah_monitor/features/auth/presentation/auth_provider.dart';
import 'package:umrah_monitor/features/tour_leader/presentation/tour_leader_dashboard_screen.dart';

class FakeSecureStorage extends SecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> saveToken(String token) async {
    _storage['auth_token'] = token;
  }

  @override
  Future<String?> getToken() async {
    return _storage['auth_token'];
  }

  @override
  Future<void> saveRole(String role) async {
    _storage['auth_role'] = role;
  }

  @override
  Future<String?> getRole() async {
    return _storage['auth_role'];
  }

  @override
  Future<void> deleteToken() async {
    _storage.remove('auth_token');
    _storage.remove('auth_role');
  }

  @override
  Future<bool> hasToken() async {
    return _storage.containsKey('auth_token') && _storage['auth_token']!.isNotEmpty;
  }
}

class FakeAuthRepositoryWithKloters extends AuthRepository {
  final FakeSecureStorage fakeStorage;
  final bool hasAssignedKloters;
  int getTourLeaderMeCallCount = 0;

  FakeAuthRepositoryWithKloters({
    required this.fakeStorage,
    this.hasAssignedKloters = true,
  }) : super(apiClient: ApiClient(), secureStorage: fakeStorage);

  @override
  Future<TourLeaderLoginResponse> loginTourLeader(String loginId) async {
    await fakeStorage.saveToken('token_tl_123');
    await fakeStorage.saveRole('tour_leader');

    final kloters = hasAssignedKloters
        ? [
            const TourLeaderKloterModel(
              id: 'kloter-uuid-1',
              name: 'Kloter 1 Al-Amanah',
              code: 'KLT-01',
            ),
          ]
        : <TourLeaderKloterModel>[];

    return TourLeaderLoginResponse(
      message: 'Login Tour Leader berhasil.',
      token: 'token_tl_123',
      tourLeader: TourLeaderAuthModel(
        id: 'tl-uuid-1',
        loginId: loginId,
        fullName: 'Ust. Ahmad Albar',
        status: 'active',
        kloters: kloters,
      ),
    );
  }

  @override
  Future<TourLeaderMeResponse> getTourLeaderMe() async {
    getTourLeaderMeCallCount++;
    final kloters = hasAssignedKloters
        ? [
            const TourLeaderKloterModel(
              id: 'kloter-uuid-1',
              name: 'Kloter 1 Al-Amanah',
              code: 'KLT-01',
            ),
          ]
        : <TourLeaderKloterModel>[];

    return TourLeaderMeResponse(
      tourLeader: TourLeaderAuthModel(
        id: 'tl-uuid-1',
        loginId: 'TL-101',
        fullName: 'Ust. Ahmad Albar',
        status: 'active',
        kloters: kloters,
      ),
    );
  }

  @override
  Future<void> registerDeviceToken({required String fcmToken, required String platform}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tour Leader Kloter Detection & Broadcast Dialog Access', () {
    test('TourLeaderAuthModel successfully parses kloters list from JSON', () {
      final json = {
        'id': 'tl-uuid-1',
        'login_id': 'TL-101',
        'full_name': 'Ust. Ahmad Albar',
        'status': 'active',
        'kloters': [
          {
            'id': 'kloter-uuid-1',
            'name': 'Kloter 1 Al-Amanah',
            'code': 'KLT-01',
          },
        ],
      };

      final model = TourLeaderAuthModel.fromJson(json);
      expect(model.id, 'tl-uuid-1');
      expect(model.loginId, 'TL-101');
      expect(model.fullName, 'Ust. Ahmad Albar');
      expect(model.kloters.length, 1);
      expect(model.kloters.first.id, 'kloter-uuid-1');
      expect(model.kloters.first.name, 'Kloter 1 Al-Amanah');
      expect(model.kloters.first.code, 'KLT-01');
    });

    test('TourLeaderAuthModel handles empty kloters list correctly', () {
      final json = {
        'id': 'tl-uuid-2',
        'login_id': 'TL-999',
        'full_name': 'Ust. Zaki Tanpa Kloter',
        'status': 'active',
        'kloters': [],
      };

      final model = TourLeaderAuthModel.fromJson(json);
      expect(model.kloters, isEmpty);
    });

    test('TourLeaderAuthModel handles null kloters field fallback gracefully', () {
      final json = {
        'id': 'tl-uuid-3',
        'login_id': 'TL-888',
        'full_name': 'Ust. Null Kloter',
        'status': 'active',
        'kloters': null,
      };

      final model = TourLeaderAuthModel.fromJson(json);
      expect(model.kloters, isEmpty);
    });

    testWidgets('Tour Leader with kloter opens Broadcast Dialog (not Akses Dibatasi)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeStorage = FakeSecureStorage();
      final fakeRepo = FakeAuthRepositoryWithKloters(
        fakeStorage: fakeStorage,
        hasAssignedKloters: true,
      );

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );

      // Login as TL
      container.read(authProvider.notifier).selectRole(UserRole.tourLeader);
      await container.read(authProvider.notifier).login(id: 'TL-101');

      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, isTrue);
      expect(authState.tourLeader?.kloters.length, 1);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: TourLeaderDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final broadcastBtn = find.text('Siarkan Broadcast');
      expect(broadcastBtn, findsOneWidget);

      await tester.tap(broadcastBtn);
      await tester.pumpAndSettle();

      // Dialog should be "Siarkan Pengumuman", NOT "Akses Dibatasi"
      expect(find.text('Siarkan Pengumuman'), findsOneWidget);
      expect(find.text('Akses Dibatasi'), findsNothing);
      expect(find.text('Target Kloter Penugasan'), findsOneWidget);
    });

    testWidgets('Tour Leader without kloter shows Akses Dibatasi dialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeStorage = FakeSecureStorage();
      final fakeRepo = FakeAuthRepositoryWithKloters(
        fakeStorage: fakeStorage,
        hasAssignedKloters: false,
      );

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );

      // Login as TL without kloter
      container.read(authProvider.notifier).selectRole(UserRole.tourLeader);
      await container.read(authProvider.notifier).login(id: 'TL-999');

      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, isTrue);
      expect(authState.tourLeader?.kloters, isEmpty);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: TourLeaderDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final broadcastBtn = find.text('Siarkan Broadcast');
      expect(broadcastBtn, findsOneWidget);

      await tester.tap(broadcastBtn);
      await tester.pumpAndSettle();

      // Dialog should be "Akses Dibatasi"
      expect(find.text('Akses Dibatasi'), findsOneWidget);
      expect(find.text('Siarkan Pengumuman'), findsNothing);
    });

    testWidgets('Tour Leader with empty initial state automatically refreshes profile before showing dialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeStorage = FakeSecureStorage();
      final fakeRepo = FakeAuthRepositoryWithKloters(
        fakeStorage: fakeStorage,
        hasAssignedKloters: true, // Backend has kloters
      );

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );

      // Manually set initial state with empty kloters (e.g. stale state from old session)
      container.read(authProvider.notifier).selectRole(UserRole.tourLeader);
      container.read(authProvider.notifier).state = const AuthState(
        isAuthenticated: true,
        selectedRole: UserRole.tourLeader,
        tourLeader: TourLeaderAuthModel(
          id: 'tl-uuid-1',
          loginId: 'TL-101',
          fullName: 'Ust. Ahmad Albar',
          status: 'active',
          kloters: [], // STALE: empty!
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: TourLeaderDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final broadcastBtn = find.text('Siarkan Broadcast');
      await tester.tap(broadcastBtn);
      await tester.pumpAndSettle();

      // Expect safe refresh triggered getTourLeaderMe
      expect(fakeRepo.getTourLeaderMeCallCount, 1);
      // Now kloters has been refreshed, so "Siarkan Pengumuman" is shown
      expect(find.text('Siarkan Pengumuman'), findsOneWidget);
      expect(find.text('Akses Dibatasi'), findsNothing);
    });
  });
}
