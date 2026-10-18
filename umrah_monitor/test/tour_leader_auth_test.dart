import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umrah_monitor/core/config/app_router.dart';
import 'package:umrah_monitor/core/network/api_client.dart';
import 'package:umrah_monitor/core/storage/secure_storage.dart';
import 'package:umrah_monitor/features/auth/data/auth_repository.dart';
import 'package:umrah_monitor/features/auth/data/models/auth_response.dart';
import 'package:umrah_monitor/features/auth/data/models/tour_leader_model.dart';
import 'package:umrah_monitor/features/auth/domain/user_model.dart';
import 'package:umrah_monitor/features/auth/presentation/auth_provider.dart';

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

class FakeAuthRepository extends AuthRepository {
  final FakeSecureStorage fakeStorage;
  bool shouldThrowNetworkErrorOnMe = false;
  bool shouldThrow401OnMe = false;
  bool logoutCalled = false;

  FakeAuthRepository({required this.fakeStorage})
      : super(apiClient: ApiClient(), secureStorage: fakeStorage);

  @override
  Future<TourLeaderLoginResponse> loginTourLeader(String loginId) async {
    if (loginId == 'TL_INVALID') {
      throw DioException(
        requestOptions: RequestOptions(path: '/tour-leader/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/tour-leader/login'),
          statusCode: 401,
          data: {'message': 'Tour Leader tidak ditemukan atau tidak aktif.'},
        ),
      );
    }

    await fakeStorage.saveToken('valid_token_123');
    await fakeStorage.saveRole('tour_leader');

    return TourLeaderLoginResponse(
      message: 'Login Tour Leader berhasil.',
      token: 'valid_token_123',
      tourLeader: const TourLeaderAuthModel(
        id: 'uuid-1',
        loginId: 'TL-55012',
        fullName: 'Ust. Muhammad Ridwan',
        status: 'active',
      ),
    );
  }

  @override
  Future<TourLeaderMeResponse> getTourLeaderMe() async {
    if (shouldThrowNetworkErrorOnMe) {
      throw DioException(
        requestOptions: RequestOptions(path: '/tour-leader/me'),
        type: DioExceptionType.connectionTimeout,
        error: 'Network timeout',
      );
    }
    if (shouldThrow401OnMe) {
      throw DioException(
        requestOptions: RequestOptions(path: '/tour-leader/me'),
        response: Response(
          requestOptions: RequestOptions(path: '/tour-leader/me'),
          statusCode: 401,
        ),
      );
    }

    return const TourLeaderMeResponse(
      tourLeader: TourLeaderAuthModel(
        id: 'uuid-1',
        loginId: 'TL-55012',
        fullName: 'Ust. Muhammad Ridwan',
        status: 'active',
      ),
    );
  }

  @override
  Future<void> logoutTourLeader() async {
    logoutCalled = true;
    await fakeStorage.deleteToken();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TourLeaderAuthModel & AuthResponse Parser', () {
    test('Berhasil parse TourLeaderLoginResponse JSON', () {
      final json = {
        'message': 'Login Tour Leader berhasil.',
        'token': 'mock-sanctum-token-123',
        'tour_leader': {
          'id': 'uuid-tl-001',
          'login_id': 'TL-55012',
          'full_name': 'Ust. H. Muhammad Ridwan, Lc.',
          'certification_number': 'SERT-2026-99',
          'phone': '081234567890',
          'status': 'active',
          'experience': 5,
          'performance': 4.8,
        },
      };

      final response = TourLeaderLoginResponse.fromJson(json);

      expect(response.message, 'Login Tour Leader berhasil.');
      expect(response.token, 'mock-sanctum-token-123');
      expect(response.tourLeader.id, 'uuid-tl-001');
      expect(response.tourLeader.loginId, 'TL-55012');
      expect(response.tourLeader.fullName, 'Ust. H. Muhammad Ridwan, Lc.');
      expect(response.tourLeader.certificationNumber, 'SERT-2026-99');
      expect(response.tourLeader.phone, '081234567890');
      expect(response.tourLeader.status, 'active');
      expect(response.tourLeader.experience, 5);
      expect(response.tourLeader.performance, 4.8);
    });

    test('Berhasil parse TourLeaderMeResponse dengan nilai nullable', () {
      final json = {
        'tour_leader': {
          'id': 'uuid-tl-002',
          'login_id': 'TL-99999',
          'full_name': 'Ahmad Fauzi',
          'certification_number': null,
          'phone': null,
          'status': 'active',
          'experience': null,
          'performance': null,
        },
      };

      final response = TourLeaderMeResponse.fromJson(json);

      expect(response.tourLeader.id, 'uuid-tl-002');
      expect(response.tourLeader.loginId, 'TL-99999');
      expect(response.tourLeader.certificationNumber, isNull);
      expect(response.tourLeader.phone, isNull);
      expect(response.tourLeader.experience, isNull);
      expect(response.tourLeader.performance, isNull);
    });
  });

  group('AuthState State Isolation & Reset', () {
    test('Memastikan switch role dan copyWith membersihkan akun sebelumnya', () {
      const initial = AuthState();
      expect(initial.isAuthenticated, isFalse);
      expect(initial.tourLeader, isNull);
      expect(initial.jamaah, isNull);
      expect(initial.user, isNull);

      final withTourLeader = initial.copyWith(
        isAuthenticated: true,
        selectedRole: UserRole.tourLeader,
        tourLeader: const TourLeaderAuthModel(
          id: 'uuid-1',
          loginId: 'TL-55012',
          fullName: 'Ust. Ridwan',
          status: 'active',
        ),
      );

      expect(withTourLeader.isAuthenticated, isTrue);
      expect(withTourLeader.tourLeader?.fullName, 'Ust. Ridwan');
      expect(withTourLeader.jamaah, isNull);

      final switchedToJamaah = withTourLeader.copyWith(
        selectedRole: UserRole.pilgrim,
        clearTourLeader: true,
        clearUser: true,
      );

      expect(switchedToJamaah.tourLeader, isNull);
      expect(switchedToJamaah.user, isNull);
      expect(switchedToJamaah.selectedRole, UserRole.pilgrim);
    });

    test('State login gagal membersihkan objek tourLeader dan jamaah', () {
      final loggedInState = const AuthState().copyWith(
        isAuthenticated: true,
        selectedRole: UserRole.tourLeader,
        tourLeader: const TourLeaderAuthModel(
          id: 'uuid-1',
          loginId: 'TL-55012',
          fullName: 'Ust. Ridwan',
          status: 'active',
        ),
      );

      final failedState = loggedInState.copyWith(
        isAuthenticated: false,
        clearTourLeader: true,
        clearJamaah: true,
        clearUser: true,
        errorMessage: 'Login gagal.',
      );

      expect(failedState.isAuthenticated, isFalse);
      expect(failedState.tourLeader, isNull);
      expect(failedState.jamaah, isNull);
      expect(failedState.user, isNull);
      expect(failedState.errorMessage, 'Login gagal.');
    });
  });

  group('Pemulihan Sesi (restoreSession) dengan Mock', () {
    late FakeSecureStorage fakeStorage;
    late FakeAuthRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeStorage = FakeSecureStorage();
      fakeRepo = FakeAuthRepository(fakeStorage: fakeStorage);
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Memulihkan sesi Tour Leader ketika token dan role valid', () async {
      await fakeStorage.saveToken('valid_token_tl');
      await fakeStorage.saveRole('tour_leader');

      await container.read(authProvider.notifier).restoreSession();

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.selectedRole, UserRole.tourLeader);
      expect(state.tourLeader?.loginId, 'TL-55012');
      expect(state.isSessionRestored, isTrue);
    });

    test('Menghapus token jika backend mengembalikan 401 saat pemulihan sesi', () async {
      await fakeStorage.saveToken('invalid_token');
      await fakeStorage.saveRole('tour_leader');
      fakeRepo.shouldThrow401OnMe = true;

      await container.read(authProvider.notifier).restoreSession();

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.tourLeader, isNull);
      expect(await fakeStorage.getToken(), isNull);
    });

    test('Tidak menghapus token saat terjadi gangguan jaringan pada pemulihan sesi', () async {
      await fakeStorage.saveToken('valid_token');
      await fakeStorage.saveRole('tour_leader');
      fakeRepo.shouldThrowNetworkErrorOnMe = true;

      await container.read(authProvider.notifier).restoreSession();

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isFalse); // Memori belum login
      expect(await fakeStorage.getToken(), 'valid_token'); // Token tetap utuh
    });

    test('Logout membersihkan token dan state', () async {
      await fakeStorage.saveToken('valid_token');
      await fakeStorage.saveRole('tour_leader');

      await container.read(authProvider.notifier).restoreSession();
      expect(container.read(authProvider).isAuthenticated, isTrue);

      await container.read(authProvider.notifier).logout();

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.tourLeader, isNull);
      expect(await fakeStorage.getToken(), isNull);
      expect(fakeRepo.logoutCalled, isTrue);
    });
  });

  group('GoRouter Route Guard & Reaktivitas', () {
    testWidgets('Unauthenticated user mengakses /tour_leader dialihkan ke /login', (tester) async {
      final fakeStorage = FakeSecureStorage();
      final fakeRepo = FakeAuthRepository(fakeStorage: fakeStorage);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(routerProvider);
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );

      // Pompa durasi splash screen agar timer selesai
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      final router = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      ).read(routerProvider);

      router.go('/tour_leader');
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.toString(), '/login');
    });

    testWidgets('Login berhasil merefresh router guard sehingga /tour_leader dapat dibuka', (tester) async {
      final fakeStorage = FakeSecureStorage();
      final fakeRepo = FakeAuthRepository(fakeStorage: fakeStorage);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final router = ref.watch(routerProvider);
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );

      // Pompa durasi splash screen agar timer selesai
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );

      container.read(authProvider.notifier).selectRole(UserRole.tourLeader);
      await container.read(authProvider.notifier).login(id: 'TL-55012');
      await tester.pumpAndSettle();

      final router = container.read(routerProvider);
      router.go('/tour_leader');
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.toString(), '/tour_leader');
    });
  });
}
