// ignore_for_file: avoid_print
//
// test/auth_repository_test.dart
//
// Unit tests untuk AuthRepository.
// Seluruh jaringan HTTP diintersep oleh MockHttpClientAdapter yang merupakan
// bagian dari package Dio itu sendiri — tidak ada dependency baru yang ditambahkan.
//
// Pola FakeSecureStorage mengikuti tour_leader_auth_test.dart yang sudah ada.
//
// PENTING: Test ini TIDAK mencetak token atau kredensial sensitif.
// PENTING: Test ini TIDAK melakukan request ke server sungguhan.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:umrah_monitor/core/network/api_client.dart';
import 'package:umrah_monitor/core/storage/secure_storage.dart';
import 'package:umrah_monitor/features/auth/data/auth_repository.dart';

// ---------------------------------------------------------------------------
// Fake Secure Storage (in-memory, mengikuti pola di tour_leader_auth_test.dart)
// ---------------------------------------------------------------------------

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
    return _storage.containsKey('auth_token') &&
        _storage['auth_token']!.isNotEmpty;
  }
}

// ---------------------------------------------------------------------------
// Mock HTTP Adapter — menggunakan HttpClientAdapter bawaan Dio
// ---------------------------------------------------------------------------

/// [MockHttpClientAdapter] menangkap semua request Dio dan mengembalikan
/// response yang telah dikonfigurasi secara programatik.
///
/// Tidak memerlukan package eksternal.  Mengimplementasikan
/// [HttpClientAdapter] dari package `dio`.
class MockHttpClientAdapter implements HttpClientAdapter {
  /// Callback yang akan dipanggil untuk setiap request. Harus di-set sebelum
  /// test dijalankan.
  Future<ResponseBody> Function(RequestOptions, Stream<List<int>>?)? handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    if (handler == null) {
      throw StateError('MockHttpClientAdapter.handler belum dikonfigurasi.');
    }
    return handler!(options, requestStream);
  }

  @override
  void close({bool force = false}) {}
}

// ---------------------------------------------------------------------------
// Payload JSON yang sesuai dengan JamaahMobileResource dari backend Laravel
// ---------------------------------------------------------------------------

Map<String, dynamic> _validLoginPayload({String loginId = 'JAMAAH001'}) => {
      'message': 'Login berhasil.',
      'token': 'mock-sanctum-token-xyz',
      'jamaah': {
        'id': 'uuid-jamaah-001',
        'login_id': loginId,
        'full_name': 'Budi Santoso',
        'phone': '081234567890',
        'profile': {
          'birth_date': '1985-03-15',
          'gender': 'male',
          'nationality': 'Indonesia',
          'passport_number': 'B1234567',
          'visa_number': 'V9876543',
        },
        'journey': {
          'package': {
            'id': 'pkg-001',
            'name': 'Paket Gold 2026',
            'category': 'Gold',
          },
          'kloter': {
            'id': 'kloter-001',
            'code': 'JKT-26-01',
            'departure_date': '2026-02-10',
            'return_date': '2026-02-24',
            'status': 'scheduled',
          },
          'hotel': {
            'makkah': 'Dar Al Taqwa',
            'madinah': 'Anwar Madinah Hotel',
          },
          'tour_leader': {
            'id': 'tl-001',
            'full_name': 'Ust. H. Ridwan',
            'phone': '082100000001',
          },
          'mutawif': null,
        },
      },
    };

Map<String, dynamic> _validMePayload({String loginId = 'JAMAAH001'}) => {
      'jamaah': _validLoginPayload(loginId: loginId)['jamaah']!,
    };

// ---------------------------------------------------------------------------
// Helper: membuat ApiClient dengan mock adapter
// ---------------------------------------------------------------------------

ApiClient _makeApiClientWithAdapter(MockHttpClientAdapter adapter) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://test.local/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
  dio.httpClientAdapter = adapter;
  return ApiClient(customDio: dio);
}

ResponseBody _jsonResponse(Map<String, dynamic> data, {int statusCode = 200}) {
  final bytes = utf8.encode(jsonEncode(data));
  return ResponseBody.fromBytes(
    bytes,
    statusCode,
    headers: {Headers.contentTypeHeader: ['application/json']},
  );
}

// ---------------------------------------------------------------------------
// Test Suite
// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockHttpClientAdapter mockAdapter;
  late FakeSecureStorage fakeStorage;
  late ApiClient apiClient;
  late AuthRepository repository;

  setUp(() {
    mockAdapter = MockHttpClientAdapter();
    fakeStorage = FakeSecureStorage();
    apiClient = _makeApiClientWithAdapter(mockAdapter);
    repository = AuthRepository(
      apiClient: apiClient,
      secureStorage: fakeStorage,
    );
  });

  // =========================================================================
  // Group: loginJamaah — sukses
  // =========================================================================

  group('loginJamaah — respons sukses', () {
    setUp(() {
      mockAdapter.handler = (options, _) async {
        expect(options.path, '/jamaah/login');
        expect((options.data as Map)['login_id'], 'JAMAAH001');
        return _jsonResponse(_validLoginPayload());
      };
    });

    test('mengembalikan LoginResponse dengan token yang tidak kosong', () async {
      final result = await repository.loginJamaah('JAMAAH001');
      expect(result.token, isNotEmpty);
    });

    test('message sesuai kontrak API backend', () async {
      final result = await repository.loginJamaah('JAMAAH001');
      expect(result.message, 'Login berhasil.');
    });

    test('login_id Jamaah berhasil diparsing', () async {
      final result = await repository.loginJamaah('JAMAAH001');
      expect(result.jamaah.loginId, 'JAMAAH001');
    });

    test('full_name Jamaah berhasil diparsing', () async {
      final result = await repository.loginJamaah('JAMAAH001');
      expect(result.jamaah.fullName, 'Budi Santoso');
    });

    test('id Jamaah berhasil diparsing', () async {
      final result = await repository.loginJamaah('JAMAAH001');
      expect(result.jamaah.id, 'uuid-jamaah-001');
    });

    test('profile Jamaah berhasil diparsing', () async {
      final result = await repository.loginJamaah('JAMAAH001');
      expect(result.jamaah.profile.gender, 'male');
      expect(result.jamaah.profile.nationality, 'Indonesia');
      expect(result.jamaah.profile.passportNumber, 'B1234567');
    });

    test('journey.package berhasil diparsing', () async {
      final result = await repository.loginJamaah('JAMAAH001');
      expect(result.jamaah.journey.package?.name, 'Paket Gold 2026');
      expect(result.jamaah.journey.package?.category, 'Gold');
    });

    test('journey.kloter berhasil diparsing', () async {
      final result = await repository.loginJamaah('JAMAAH001');
      expect(result.jamaah.journey.kloter?.code, 'JKT-26-01');
      expect(result.jamaah.journey.kloter?.status, 'scheduled');
    });

    test('journey.tour_leader berhasil diparsing', () async {
      final result = await repository.loginJamaah('JAMAAH001');
      expect(result.jamaah.journey.tourLeader?.fullName, 'Ust. H. Ridwan');
    });

    test('journey.mutawif null jika tidak ada', () async {
      final result = await repository.loginJamaah('JAMAAH001');
      expect(result.jamaah.journey.mutawif, isNull);
    });
  });

  // =========================================================================
  // Group: loginJamaah — penyimpanan token & role
  // =========================================================================

  group('loginJamaah — penyimpanan token & role di secure storage', () {
    setUp(() {
      mockAdapter.handler = (options, _) async =>
          _jsonResponse(_validLoginPayload());
    });

    test('token disimpan ke secure storage', () async {
      await repository.loginJamaah('JAMAAH001');
      final savedToken = await fakeStorage.getToken();
      expect(savedToken, isNotNull);
      expect(savedToken, isNotEmpty);
      // Nilai token mock harus sesuai dengan payload
      expect(savedToken, 'mock-sanctum-token-xyz');
    });

    test('role "pilgrim" disimpan ke secure storage', () async {
      await repository.loginJamaah('JAMAAH001');
      final savedRole = await fakeStorage.getRole();
      expect(savedRole, 'pilgrim');
    });

    test('hasToken bernilai true setelah login berhasil', () async {
      await repository.loginJamaah('JAMAAH001');
      expect(await fakeStorage.hasToken(), isTrue);
    });
  });

  // =========================================================================
  // Group: loginJamaah — error handling
  // =========================================================================

  group('loginJamaah — HTTP 401 Unauthorized', () {
    test('melempar DioException ketika backend mengembalikan 401', () async {
      mockAdapter.handler = (options, _) async => _jsonResponse(
            {'message': 'Jamaah tidak ditemukan atau tidak aktif.'},
            statusCode: 401,
          );

      expect(
        () => repository.loginJamaah('ID_TIDAK_ADA'),
        throwsA(isA<DioException>()),
      );
    });

    test('response 401 tidak menyimpan token ke secure storage', () async {
      mockAdapter.handler = (options, _) async => _jsonResponse(
            {'message': 'Jamaah tidak ditemukan atau tidak aktif.'},
            statusCode: 401,
          );

      try {
        await repository.loginJamaah('ID_TIDAK_ADA');
      } on DioException {
        // Expected
      }

      expect(await fakeStorage.getToken(), isNull);
    });
  });

  group('loginJamaah — respons JSON tidak valid', () {
    test('melempar exception saat field "token" tidak ada', () async {
      // Hapus key "token" dari payload agar fromJson gagal
      final badPayload = _validLoginPayload()..remove('token');
      mockAdapter.handler = (options, _) async =>
          _jsonResponse(badPayload);

      expect(
        () => repository.loginJamaah('JAMAAH001'),
        throwsA(anything),
      );
    });

    test('melempar exception saat field "jamaah" tidak ada', () async {
      mockAdapter.handler = (options, _) async => _jsonResponse({
            'message': 'Login berhasil.',
            'token': 'some-token',
            // "jamaah" sengaja dihilangkan
          });

      expect(
        () => repository.loginJamaah('JAMAAH001'),
        throwsA(anything),
      );
    });

    test('melempar exception saat response bukan JSON', () async {
      // Kirimkan HTML bukan JSON untuk memicu error parsing
      mockAdapter.handler = (options, _) async {
        return ResponseBody.fromBytes(
          utf8.encode('<html>Internal Server Error</html>'),
          200,
          headers: {Headers.contentTypeHeader: ['text/html']},
        );
      };

      expect(
        () => repository.loginJamaah('JAMAAH001'),
        throwsA(anything),
      );
    });
  });

  // =========================================================================
  // Group: getJamaahMe
  // =========================================================================

  group('getJamaahMe', () {
    test('mengembalikan MeResponse ketika token tersedia', () async {
      await fakeStorage.saveToken('valid-token');

      mockAdapter.handler = (options, _) async {
        expect(options.path, '/jamaah/me');
        expect(
          options.headers['Authorization'],
          'Bearer valid-token',
        );
        return _jsonResponse(_validMePayload());
      };

      final result = await repository.getJamaahMe();
      expect(result.jamaah.loginId, 'JAMAAH001');
      expect(result.jamaah.fullName, 'Budi Santoso');
    });

    test('melempar Exception ketika token tidak tersedia', () async {
      // Jangan simpan token — storage kosong

      expect(
        () => repository.getJamaahMe(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Token tidak ditemukan'),
          ),
        ),
      );
    });

    test('melempar Exception ketika token kosong', () async {
      await fakeStorage.saveToken('');

      expect(
        () => repository.getJamaahMe(),
        throwsA(isA<Exception>()),
      );
    });

    test('melempar DioException saat backend mengembalikan 401', () async {
      await fakeStorage.saveToken('expired-token');

      mockAdapter.handler = (options, _) async => _jsonResponse(
            {'message': 'Unauthenticated.'},
            statusCode: 401,
          );

      expect(
        () => repository.getJamaahMe(),
        throwsA(isA<DioException>()),
      );
    });
  });

  // =========================================================================
  // Group: logout
  // =========================================================================

  group('logout', () {
    test('token dihapus dari secure storage setelah logout berhasil', () async {
      await fakeStorage.saveToken('valid-token');
      await fakeStorage.saveRole('pilgrim');

      mockAdapter.handler = (options, _) async =>
          _jsonResponse({'message': 'Logout berhasil.'});

      await repository.logout();

      expect(await fakeStorage.getToken(), isNull);
      expect(await fakeStorage.getRole(), isNull);
    });

    test('token tetap dihapus meski server mengembalikan error', () async {
      // logout() menggunakan try/finally di production code:
      //   try { await dio.post('/logout') } finally { deleteToken() }
      // Artinya:
      //   1. deleteToken() PASTI dipanggil (via finally).
      //   2. DioException TETAP di-rethrow ke pemanggil setelah finally.
      // Test ini memverifikasi perilaku nyata tersebut.

      await fakeStorage.saveToken('valid-token');

      mockAdapter.handler = (options, _) async => _jsonResponse(
            {'message': 'Unauthenticated.'},
            statusCode: 401,
          );

      // Tangkap DioException yang di-rethrow setelah finally
      try {
        await repository.logout();
        fail('Seharusnya melempar DioException karena server mengembalikan 401');
      } on DioException {
        // Expected — finally sudah berjalan sebelum re-throw
      }

      // Verifikasi: token tetap terhapus meskipun terjadi DioException
      expect(await fakeStorage.getToken(), isNull);
    });

    test('logout tanpa token tidak melempar exception', () async {
      // Storage kosong, tidak ada panggilan jaringan yang dilakukan
      // Tidak perlu adapter handler karena tidak ada request

      await expectLater(
        repository.logout(),
        completes,
      );
    });
  });

  // =========================================================================
  // Group: loginFamily — verifikasi tidak rusak
  // =========================================================================

  group('loginFamily — verifikasi tidak rusak', () {
    setUp(() {
      mockAdapter.handler = (options, _) async {
        expect(options.path, '/family/login');
        expect((options.data as Map)['login_id'], 'FAMILY001');
        return _jsonResponse(_validLoginPayload(loginId: 'FAMILY001'));
      };
    });

    test('endpoint yang dipanggil adalah /family/login', () async {
      await repository.loginFamily('FAMILY001');
      // Assertion ada di handler atas; jika endpoint salah, test akan gagal.
    });

    test('role "family" disimpan ke secure storage', () async {
      await repository.loginFamily('FAMILY001');
      expect(await fakeStorage.getRole(), 'family');
    });
  });
}
