// test/integration/auth_api_integration_test.dart
//
// Integration test untuk AuthRepository — menghubungi backend Laravel secara nyata.
//
// PERINGATAN:
// - File ini BUKAN bagian dari unit test standar.
// - Jalankan secara eksplisit: flutter test test/integration/auth_api_integration_test.dart
// - Backend Laravel harus aktif dan dapat dijangkau di BASE_URL yang dikonfigurasi.
// - Gunakan data pengujian terkontrol; jangan gunakan data produksi.
//
// Konfigurasi base URL:
// - Windows/Desktop host: http://127.0.0.1:8000/api  (localhost)
// - Android Emulator:     http://10.0.2.2:8000/api   (alias loopback QEMU)
//
// KEAMANAN:
// - Token autentikasi dan kredensial sensitif TIDAK dicetak ke log.
// - Test tidak mengasumsikan bahwa user test tertentu selalu tersedia.
// - Test memeriksa ketersediaan backend sebelum mengirim request login.

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:umrah_monitor/core/network/api_client.dart';
import 'package:umrah_monitor/core/storage/secure_storage.dart';
import 'package:umrah_monitor/features/auth/data/auth_repository.dart';

// ---------------------------------------------------------------------------
// Konfigurasi
// ---------------------------------------------------------------------------

/// Base URL untuk integration test pada lingkungan desktop/Windows.
/// Ubah sesuai lingkungan jika diperlukan.
const _integrationBaseUrl = 'http://127.0.0.1:8000/api';

/// Login ID Jamaah yang digunakan untuk integration test.
/// Pastikan data ini tersedia di database pengujian dan berstatus 'active'.
const _testJamaahLoginId = 'JAMAAH001';

// ---------------------------------------------------------------------------
// Fake Secure Storage (in-memory) — tidak memerlukan platform channel
// ---------------------------------------------------------------------------

class _FakeSecureStorage extends SecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> saveToken(String token) async => _storage['auth_token'] = token;

  @override
  Future<String?> getToken() async => _storage['auth_token'];

  @override
  Future<void> saveRole(String role) async => _storage['auth_role'] = role;

  @override
  Future<String?> getRole() async => _storage['auth_role'];

  @override
  Future<void> deleteToken() async {
    _storage.remove('auth_token');
    _storage.remove('auth_role');
  }

  @override
  Future<bool> hasToken() async =>
      _storage.containsKey('auth_token') &&
      _storage['auth_token']!.isNotEmpty;
}

// ---------------------------------------------------------------------------
// Helper: periksa ketersediaan backend
// ---------------------------------------------------------------------------

/// Mengembalikan true jika backend dapat dihubungi pada port 8000.
/// Menggunakan TCP socket langsung — tidak memerlukan Dio.
Future<bool> _isBackendReachable() async {
  try {
    final socket = await Socket.connect(
      '127.0.0.1',
      8000,
      timeout: const Duration(seconds: 3),
    );
    socket.destroy();
    return true;
  } on SocketException {
    return false;
  }
}

// ---------------------------------------------------------------------------
// Test Suite
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // PENTING: Jangan panggil TestWidgetsFlutterBinding.ensureInitialized() di sini.
  //
  // TestWidgetsFlutterBinding secara desain menggantikan dart:io HttpClient
  // dengan implementasi yang selalu mengembalikan HTTP 400 untuk semua request
  // nyata. Perilaku ini dimaksudkan untuk unit/widget test agar tidak bergantung
  // pada jaringan.
  //
  // Integration test ini MEMERLUKAN koneksi HTTP nyata ke backend Laravel.
  // Solusi: tetapkan HttpOverrides.global = null sebelum test berjalan untuk
  // memastikan tidak ada override HttpClient yang aktif dari proses test runner.
  // -------------------------------------------------------------------------
  HttpOverrides.global = null;

  late _FakeSecureStorage fakeStorage;
  late AuthRepository repository;

  setUpAll(() async {
    final reachable = await _isBackendReachable();
    if (!reachable) {
      // Gagal dengan pesan yang informatif daripada mencoba koneksi yang pasti timeout.
      fail(
        '\n'
        '══════════════════════════════════════════════════════════════\n'
        '  INTEGRATION TEST DIBATALKAN\n'
        '  Backend Laravel tidak dapat dijangkau di:\n'
        '    $_integrationBaseUrl\n'
        '\n'
        '  Pastikan:\n'
        '    1. Server Laravel aktif: php artisan serve --port=8000\n'
        '    2. Tidak ada firewall yang memblokir port 8000\n'
        '    3. DATABASE berisi data pengujian yang valid\n'
        '══════════════════════════════════════════════════════════════\n',
      );
    }

    fakeStorage = _FakeSecureStorage();

    final apiClient = ApiClient(baseUrl: _integrationBaseUrl);

    repository = AuthRepository(
      apiClient: apiClient,
      secureStorage: fakeStorage,
    );
  });

  tearDown(() async {
    // Bersihkan token setelah setiap test
    await fakeStorage.deleteToken();
  });

  // =========================================================================
  // Group: Login Jamaah ke API Laravel nyata
  // =========================================================================

  group('Integration — loginJamaah ke backend Laravel', () {
    test(
      'login dengan ID $_testJamaahLoginId berhasil dan mengembalikan token',
      () async {
        late String savedRole;

        try {
          final result = await repository.loginJamaah(_testJamaahLoginId);

          // Validasi token tidak kosong (JANGAN cetak nilai token)
          expect(result.token, isNotEmpty,
              reason: 'Token harus dikembalikan oleh backend');

          // Validasi login_id sesuai
          expect(result.jamaah.loginId, _testJamaahLoginId,
              reason: 'login_id harus sesuai dengan yang dikirimkan');

          // Validasi data profil tersedia
          expect(result.jamaah.fullName, isNotEmpty,
              reason: 'full_name tidak boleh kosong');

          // Validasi token tersimpan di storage
          final savedToken = await fakeStorage.getToken();
          expect(savedToken, isNotNull,
              reason: 'Token harus tersimpan di secure storage');
          expect(savedToken, isNotEmpty);

          // Validasi role pilgrim tersimpan
          savedRole = await fakeStorage.getRole() ?? '';
          expect(savedRole, 'pilgrim',
              reason: 'Role "pilgrim" harus disimpan setelah login Jamaah');

          // Log informatif (bukan token)
          // ignore: avoid_print
          print('[Integration] Login Jamaah berhasil.');
          // ignore: avoid_print
          print('[Integration] login_id    : ${result.jamaah.loginId}');
          // ignore: avoid_print
          print('[Integration] full_name   : ${result.jamaah.fullName}');
          // ignore: avoid_print
          print('[Integration] role stored : $savedRole');
        } on DioException catch (e) {
          if (e.response?.statusCode == 401) {
            fail(
              'Backend mengembalikan 401. '
              'Pastikan Jamaah dengan login_id="$_testJamaahLoginId" '
              'tersedia dan berstatus "active" di database pengujian.',
            );
          }
          rethrow;
        }
      },
    );

    test(
      'login dengan ID yang tidak valid mengembalikan HTTP 401',
      () async {
        const nonExistentId = 'TIDAK_ADA_9999';

        try {
          await repository.loginJamaah(nonExistentId);
          fail('Seharusnya melempar DioException untuk ID yang tidak valid');
        } on DioException catch (e) {
          expect(
            e.response?.statusCode,
            401,
            reason: 'Backend harus mengembalikan 401 untuk ID tidak valid',
          );
          // Validasi pesan error dari backend
          final message = e.response?.data?['message'] as String?;
          expect(message, isNotNull);
          expect(message, isNotEmpty);
          // ignore: avoid_print
          print('[Integration] Pesan error 401: $message');
        }
      },
    );
  });
}
