// test/schedule_repository_and_provider_test.dart
//
// Unit tests untuk ScheduleRepository, ScheduleNotifier, dan ScheduleModel.
//
// Seluruh jaringan HTTP diintersep oleh MockHttpClientAdapter yang mengikuti
// pola auth_repository_test.dart yang sudah ada.
//
// PENTING: Test ini TIDAK mencetak token atau kredensial sensitif.
// PENTING: Test ini TIDAK melakukan request ke server sungguhan.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:umrah_monitor/core/network/api_client.dart';
import 'package:umrah_monitor/core/storage/secure_storage.dart';
import 'package:umrah_monitor/features/tour_leader/data/schedule_repository.dart';
import 'package:umrah_monitor/features/tour_leader/domain/schedule_model.dart';
import 'package:umrah_monitor/features/tour_leader/presentation/schedule_provider.dart';

// ============================================================================
// Fake Secure Storage (mengikuti pola auth_repository_test.dart)
// ============================================================================

class FakeSecureStorage extends SecureStorage {
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

// ============================================================================
// Mock HTTP Adapter (mengikuti pola auth_repository_test.dart)
// ============================================================================

class MockHttpClientAdapter implements HttpClientAdapter {
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

// ============================================================================
// Helper builders
// ============================================================================

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
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

// ============================================================================
// Contoh payload JSON yang sesuai kontrak backend Stage 2
// ============================================================================

Map<String, dynamic> _scheduleJson({
  String id = 'schedule-uuid-001',
  String status = 'upcoming',
  String reminderStatus = 'draft',
  String? endTime,
  String? effectiveEndTime,
  String? broadcastedAt,
}) =>
    {
      'id': id,
      'title': 'Pelaksanaan Umrah Wajib 1',
      'category': 'ibadah',
      'location': 'Masjidil Haram',
      'description': 'Tawaf 7 putaran dan Sa\'i',
      'pic': 'Ust. H. Ridwan',
      'start_time': '2026-07-15T02:00:00.000000Z',
      'end_time': endTime,
      'effective_end_time': effectiveEndTime,
      'status': status,
      'status_mode': 'auto',
      'reminder_status': reminderStatus,
      'broadcasted_at': broadcastedAt,
    };

Map<String, dynamic> _listResponse({List<Map<String, dynamic>>? items}) => {
      'data': {
        'current_page': 1,
        'data': items ?? [_scheduleJson()],
        'total': items?.length ?? 1,
      }
    };

Map<String, dynamic> _singleResponse({
  Map<String, dynamic>? scheduleData,
  String? message,
}) =>
    {
      'data': scheduleData ?? _scheduleJson(),
      'message': message ?? 'Berhasil.',
    };

// ============================================================================
// TEST SUITE
// ============================================================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockHttpClientAdapter mockAdapter;
  late FakeSecureStorage fakeStorage;
  late ApiClient apiClient;
  late ScheduleRepository repository;

  setUp(() {
    mockAdapter = MockHttpClientAdapter();
    fakeStorage = FakeSecureStorage();
    apiClient = _makeApiClientWithAdapter(mockAdapter);
    repository = ScheduleRepository(
      apiClient: apiClient,
      secureStorage: fakeStorage,
    );
  });

  // =========================================================================
  // A. ScheduleModel.fromJson — parsing field
  // =========================================================================

  group('A. ScheduleModel.fromJson — parsing field', () {
    test('field wajib berhasil diparsing', () {
      final model = ScheduleModel.fromJson(_scheduleJson());
      expect(model.id, 'schedule-uuid-001');
      expect(model.title, 'Pelaksanaan Umrah Wajib 1');
      expect(model.startTime, '2026-07-15T02:00:00.000000Z');
      expect(model.status, 'upcoming');
      expect(model.statusMode, 'auto');
      expect(model.reminderStatus, 'draft');
    });

    test('field opsional null ditangani dengan aman', () {
      final json = _scheduleJson();
      json.remove('end_time');
      json.remove('effective_end_time');
      json.remove('broadcasted_at');
      json.remove('location');
      json.remove('description');
      json.remove('pic');
      json.remove('category');

      final model = ScheduleModel.fromJson(json);
      expect(model.endTime, isNull);
      expect(model.effectiveEndTime, isNull);
      expect(model.broadcastedAt, isNull);
      expect(model.location, isNull);
      expect(model.description, isNull);
      expect(model.pic, isNull);
      expect(model.category, isNull);
    });

    test('status default ke "upcoming" jika field tidak ada', () {
      final json = _scheduleJson();
      json.remove('status');
      final model = ScheduleModel.fromJson(json);
      expect(model.status, 'upcoming');
    });

    test('reminderStatus default ke "draft" jika field tidak ada', () {
      final json = _scheduleJson();
      json.remove('reminder_status');
      final model = ScheduleModel.fromJson(json);
      expect(model.reminderStatus, 'draft');
    });

    test('endTime berhasil diparsing saat tersedia', () {
      final model = ScheduleModel.fromJson(
        _scheduleJson(endTime: '2026-07-15T06:00:00.000000Z'),
      );
      expect(model.endTime, '2026-07-15T06:00:00.000000Z');
    });

    test('effectiveEndTime berhasil diparsing', () {
      final model = ScheduleModel.fromJson(
        _scheduleJson(effectiveEndTime: '2026-07-15T07:00:00.000000Z'),
      );
      expect(model.effectiveEndTime, '2026-07-15T07:00:00.000000Z');
    });

    test('broadcastedAt berhasil diparsing saat jadwal pernah disiarkan', () {
      final model = ScheduleModel.fromJson(
        _scheduleJson(
          reminderStatus: 'published',
          broadcastedAt: '2026-07-14T12:00:00.000000Z',
        ),
      );
      expect(model.reminderStatus, 'published');
      expect(model.broadcastedAt, '2026-07-14T12:00:00.000000Z');
    });

    test('copyWith mempertahankan nilai yang tidak diubah', () {
      final original = ScheduleModel.fromJson(_scheduleJson());
      final copy = original.copyWith(status: 'completed');
      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.status, 'completed');
    });

    test('copyWith clearEndTime menghapus endTime', () {
      final original =
          ScheduleModel.fromJson(_scheduleJson(endTime: '2026-07-15T06:00:00Z'));
      final copy = original.copyWith(clearEndTime: true);
      expect(copy.endTime, isNull);
    });
  });

  // =========================================================================
  // B. ScheduleListResponse.fromJson — parsing respons daftar
  // =========================================================================

  group('B. ScheduleListResponse.fromJson — parsing respons', () {
    test('parsing paginated response berhasil', () {
      final response = ScheduleListResponse.fromJson(_listResponse());
      expect(response.schedules.length, 1);
      expect(response.schedules.first.id, 'schedule-uuid-001');
    });

    test('parsing list kosong menghasilkan list kosong', () {
      final response = ScheduleListResponse.fromJson(_listResponse(items: []));
      expect(response.schedules, isEmpty);
    });

    test('parsing flat list response juga berhasil', () {
      final flatJson = {
        'data': [_scheduleJson(id: 'flat-001'), _scheduleJson(id: 'flat-002')],
      };
      final response = ScheduleListResponse.fromJson(flatJson);
      expect(response.schedules.length, 2);
    });

    test('total berhasil diparsing dari paginated response', () {
      final response = ScheduleListResponse.fromJson(
        _listResponse(items: [_scheduleJson(), _scheduleJson(id: 'schedule-002')]),
      );
      expect(response.total, 2);
    });
  });

  // =========================================================================
  // C. ScheduleRepository.getSchedules — fetch dari API
  // =========================================================================

  group('C. ScheduleRepository.getSchedules', () {
    test('memanggil GET /schedules dengan token Authorization', () async {
      await fakeStorage.saveToken('valid-token');
      String? capturedPath;
      String? capturedAuthHeader;

      mockAdapter.handler = (options, _) async {
        capturedPath = options.path;
        capturedAuthHeader = options.headers['Authorization'] as String?;
        return _jsonResponse(_listResponse());
      };

      final result = await repository.getSchedules();

      expect(capturedPath, '/schedules');
      expect(capturedAuthHeader, 'Bearer valid-token');
      expect(result.schedules, isNotEmpty);
    });

    test('melempar Exception saat token tidak tersedia', () async {
      expect(
        () => repository.getSchedules(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Token autentikasi tidak ditemukan'),
          ),
        ),
      );
    });

    test('melempar DioException saat backend mengembalikan 401', () async {
      await fakeStorage.saveToken('expired-token');
      mockAdapter.handler = (options, _) async => _jsonResponse(
            {'message': 'Unauthenticated.'},
            statusCode: 401,
          );

      expect(
        () => repository.getSchedules(),
        throwsA(isA<DioException>()),
      );
    });
  });

  // =========================================================================
  // D. ScheduleRepository.createSchedule — POST payload
  // =========================================================================

  group('D. ScheduleRepository.createSchedule', () {
    test('mengirim payload ke POST /schedules dan mengembalikan jadwal baru',
        () async {
      await fakeStorage.saveToken('valid-token');
      Map<String, dynamic>? sentPayload;
      String? capturedPath;

      mockAdapter.handler = (options, _) async {
        capturedPath = options.path;
        sentPayload = options.data as Map<String, dynamic>?;
        return _jsonResponse(
          _singleResponse(message: 'Jadwal berhasil dibuat.'),
        );
      };

      final payload = {
        'title': 'Jadwal Baru',
        'category': 'ibadah',
        'start_time': '2026-07-20T08:00:00.000000Z',
      };

      final result = await repository.createSchedule(payload);

      expect(capturedPath, '/schedules');
      expect(sentPayload?['title'], 'Jadwal Baru');
      expect(result.schedule.id, 'schedule-uuid-001');
      expect(result.message, 'Jadwal berhasil dibuat.');
    });

    test('end_time boleh tidak disertakan dalam payload', () async {
      await fakeStorage.saveToken('valid-token');
      Map<String, dynamic>? sentPayload;

      mockAdapter.handler = (options, _) async {
        sentPayload = options.data as Map<String, dynamic>?;
        return _jsonResponse(_singleResponse());
      };

      await repository.createSchedule({
        'title': 'Tanpa End Time',
        'category': 'umum',
        'start_time': '2026-07-20T08:00:00.000000Z',
        // end_time tidak disertakan
      });

      expect(sentPayload?.containsKey('end_time'), isFalse);
    });

    test('melempar DioException saat backend mengembalikan 422', () async {
      await fakeStorage.saveToken('valid-token');
      mockAdapter.handler = (options, _) async => _jsonResponse(
            {'message': 'The title field is required.'},
            statusCode: 422,
          );

      expect(
        () => repository.createSchedule({'category': 'ibadah'}),
        throwsA(isA<DioException>()),
      );
    });
  });

  // =========================================================================
  // E. ScheduleRepository.updateStatus — PATCH /schedules/{id}/status
  // =========================================================================

  group('E. ScheduleRepository.updateStatus', () {
    test('memanggil PATCH /schedules/{id}/status dengan payload yang benar',
        () async {
      await fakeStorage.saveToken('valid-token');
      String? capturedPath;
      Map<String, dynamic>? sentPayload;

      mockAdapter.handler = (options, _) async {
        capturedPath = options.path;
        sentPayload = options.data as Map<String, dynamic>?;
        return _jsonResponse(
          _singleResponse(
            scheduleData: _scheduleJson(status: 'completed'),
          ),
        );
      };

      final result = await repository.updateStatus(
        scheduleId: 'schedule-uuid-001',
        status: 'completed',
      );

      expect(capturedPath, '/schedules/schedule-uuid-001/status');
      expect(sentPayload?['status'], 'completed');
      expect(result.schedule.status, 'completed');
    });

    test('semua nilai status yang valid dapat dikirimkan', () async {
      await fakeStorage.saveToken('valid-token');

      for (final status in ['upcoming', 'in_progress', 'completed']) {
        String? sentStatus;
        mockAdapter.handler = (options, _) async {
          sentStatus = (options.data as Map<String, dynamic>?)!['status'] as String;
          return _jsonResponse(
            _singleResponse(scheduleData: _scheduleJson(status: status)),
          );
        };

        await repository.updateStatus(
          scheduleId: 'schedule-uuid-001',
          status: status,
        );
        expect(sentStatus, status);
      }
    });

    test('melempar DioException saat backend menolak perubahan status', () async {
      await fakeStorage.saveToken('valid-token');
      mockAdapter.handler = (options, _) async => _jsonResponse(
            {'message': 'Tidak diizinkan mengubah status ini.'},
            statusCode: 403,
          );

      expect(
        () => repository.updateStatus(
            scheduleId: 'schedule-uuid-001', status: 'completed'),
        throwsA(isA<DioException>()),
      );
    });
  });

  // =========================================================================
  // F. ScheduleRepository.broadcastSchedule — POST /schedules/{id}/broadcast
  // =========================================================================

  group('F. ScheduleRepository.broadcastSchedule', () {
    test('memanggil POST /schedules/{id}/broadcast', () async {
      await fakeStorage.saveToken('valid-token');
      String? capturedPath;

      mockAdapter.handler = (options, _) async {
        capturedPath = options.path;
        return _jsonResponse({
          'message': 'Siaran berhasil diproses.',
          'data': {
            'reminder_status': 'published',
            'notifications_processed': 45,
            'broadcasted_at': '2026-07-14T12:00:00.000000Z',
          },
        });
      };

      final result = await repository.broadcastSchedule('schedule-uuid-001');

      expect(capturedPath, '/schedules/schedule-uuid-001/broadcast');
      expect(result.reminderStatus, 'published');
      expect(result.notificationsProcessed, 45);
      expect(result.broadcastedAt, '2026-07-14T12:00:00.000000Z');
    });

    test('melempar DioException saat broadcast gagal', () async {
      await fakeStorage.saveToken('valid-token');
      mockAdapter.handler = (options, _) async => _jsonResponse(
            {'message': 'Terjadi kesalahan saat menyiarkan.'},
            statusCode: 500,
          );

      expect(
        () => repository.broadcastSchedule('schedule-uuid-001'),
        throwsA(isA<DioException>()),
      );
    });
  });

  // =========================================================================
  // G. ScheduleNotifier — state management
  // =========================================================================

  group('G. ScheduleNotifier — state management', () {
    late ScheduleNotifier notifier;

    setUp(() async {
      await fakeStorage.saveToken('valid-token');
      notifier = ScheduleNotifier(repository);
    });

    test('state awal: tidak loading, list kosong, tidak ada error', () {
      expect(notifier.state.isLoading, false);
      expect(notifier.state.schedules, isEmpty);
      expect(notifier.state.errorMessage, isNull);
    });

    test('fetchSchedules mengisi state.schedules dari API', () async {
      mockAdapter.handler = (options, _) async =>
          _jsonResponse(_listResponse());

      await notifier.fetchSchedules();

      expect(notifier.state.isLoading, false);
      expect(notifier.state.errorMessage, isNull);
      expect(notifier.state.schedules.length, 1);
      expect(notifier.state.schedules.first.id, 'schedule-uuid-001');
    });

    test('fetchSchedules menyimpan error saat API gagal', () async {
      mockAdapter.handler = (options, _) async => _jsonResponse(
            {'message': 'Server error.'},
            statusCode: 500,
          );

      await notifier.fetchSchedules();

      expect(notifier.state.isLoading, false);
      expect(notifier.state.errorMessage, isNotNull);
      expect(notifier.state.schedules, isEmpty);
    });

    test('fetchSchedules mencegah double fetch saat sudah loading', () async {
      int callCount = 0;
      mockAdapter.handler = (options, _) async {
        callCount++;
        await Future.delayed(const Duration(milliseconds: 50));
        return _jsonResponse(_listResponse());
      };

      // Mulai dua fetch secara bersamaan
      final future1 = notifier.fetchSchedules();
      final future2 = notifier.fetchSchedules(); // harus diabaikan
      await Future.wait([future1, future2]);

      // Hanya satu request yang seharusnya dikirim
      expect(callCount, 1);
    });

    test('createSchedule menambahkan jadwal baru ke state', () async {
      mockAdapter.handler = (options, _) async =>
          _jsonResponse(_singleResponse());

      final result = await notifier.createSchedule({
        'title': 'Jadwal Baru',
        'category': 'ibadah',
        'start_time': '2026-07-20T08:00:00.000000Z',
      });

      expect(result, isNotNull);
      expect(notifier.state.schedules.length, 1);
      expect(notifier.state.isSubmitting, false);
    });

    test('createSchedule mencegah double submit', () async {
      int callCount = 0;
      mockAdapter.handler = (options, _) async {
        callCount++;
        await Future.delayed(const Duration(milliseconds: 50));
        return _jsonResponse(_singleResponse());
      };

      // Submit ganda secara bersamaan
      final future1 = notifier.createSchedule({'title': 'A', 'start_time': '2026-07-20T08:00:00.000000Z', 'category': 'ibadah'});
      final future2 = notifier.createSchedule({'title': 'B', 'start_time': '2026-07-20T08:00:00.000000Z', 'category': 'ibadah'});
      await Future.wait([future1, future2]);

      // Hanya satu request yang seharusnya dikirim
      expect(callCount, 1);
    });

    test('createSchedule menyimpan error dan mempertahankan list yang ada', () async {
      // Pre-populate state dengan jadwal yang sudah ada
      mockAdapter.handler = (options, _) async =>
          _jsonResponse(_listResponse());
      await notifier.fetchSchedules();
      expect(notifier.state.schedules.length, 1);

      // Gagalkan create
      mockAdapter.handler = (options, _) async => _jsonResponse(
            {'message': 'Validation failed.'},
            statusCode: 422,
          );

      final result = await notifier.createSchedule({'title': ''});

      expect(result, isNull);
      expect(notifier.state.errorMessage, isNotNull);
      // List yang sudah ada harus dipertahankan
      expect(notifier.state.schedules.length, 1);
    });

    test('updateStatus memperbarui state sesuai respons backend', () async {
      // Isi state dulu
      mockAdapter.handler = (options, _) async =>
          _jsonResponse(_listResponse());
      await notifier.fetchSchedules();

      // Update status
      mockAdapter.handler = (options, _) async => _jsonResponse(
            _singleResponse(
              scheduleData: _scheduleJson(status: 'in_progress'),
            ),
          );

      final success = await notifier.updateStatus(
        scheduleId: 'schedule-uuid-001',
        newStatus: 'in_progress',
      );

      expect(success, true);
      expect(notifier.state.schedules.first.status, 'in_progress');
      expect(notifier.state.updatingStatusId, isNull);
    });

    test('updateStatus menyimpan error dan tidak mengubah status saat gagal',
        () async {
      mockAdapter.handler = (options, _) async =>
          _jsonResponse(_listResponse());
      await notifier.fetchSchedules();

      final originalStatus = notifier.state.schedules.first.status;

      mockAdapter.handler = (options, _) async => _jsonResponse(
            {'message': 'Tidak diizinkan.'},
            statusCode: 403,
          );

      final success = await notifier.updateStatus(
        scheduleId: 'schedule-uuid-001',
        newStatus: 'completed',
      );

      expect(success, false);
      expect(notifier.state.errorMessage, isNotNull);
      // Status TIDAK boleh berubah jika backend menolak
      expect(notifier.state.schedules.first.status, originalStatus);
      expect(notifier.state.updatingStatusId, isNull);
    });

    test('updateStatus tidak menghitung ulang status secara lokal', () async {
      // Pastikan tidak ada kalkulasi waktu perangkat yang mengubah status
      mockAdapter.handler = (options, _) async =>
          _jsonResponse(_listResponse());
      await notifier.fetchSchedules();

      // Verifikasi bahwa status awal adalah 'upcoming' (dari backend mock)
      expect(notifier.state.schedules.first.status, 'upcoming');

      // Notifier tidak boleh secara otomatis mengubah status berdasarkan waktu lokal
      // (hanya backend yang berwenang mengubah status)
      expect(notifier.state.schedules.first.status, 'upcoming');
    });

    test('broadcastSchedule memperbarui reminderStatus setelah sukses', () async {
      mockAdapter.handler = (options, _) async =>
          _jsonResponse(_listResponse());
      await notifier.fetchSchedules();

      expect(notifier.state.schedules.first.reminderStatus, 'draft');

      mockAdapter.handler = (options, _) async => _jsonResponse({
            'message': 'Siaran berhasil diproses.',
            'data': {
              'reminder_status': 'published',
              'notifications_processed': 45,
              'broadcasted_at': '2026-07-14T12:00:00.000000Z',
            },
          });

      final result =
          await notifier.broadcastSchedule('schedule-uuid-001');

      expect(result, isNotNull);
      expect(result!.reminderStatus, 'published');
      expect(notifier.state.schedules.first.reminderStatus, 'published');
      expect(notifier.state.broadcastingId, isNull);
    });

    test('broadcastSchedule tidak mengubah UI menjadi sukses saat gagal',
        () async {
      mockAdapter.handler = (options, _) async =>
          _jsonResponse(_listResponse());
      await notifier.fetchSchedules();

      mockAdapter.handler = (options, _) async => _jsonResponse(
            {'message': 'Siaran gagal.'},
            statusCode: 500,
          );

      final result =
          await notifier.broadcastSchedule('schedule-uuid-001');

      // Harus null saat gagal
      expect(result, isNull);
      // reminderStatus harus tetap 'draft'
      expect(notifier.state.schedules.first.reminderStatus, 'draft');
      expect(notifier.state.errorMessage, isNotNull);
      expect(notifier.state.broadcastingId, isNull);
    });

    test('broadcastSchedule mencegah double broadcast saat masih berlangsung',
        () async {
      await fakeStorage.saveToken('valid-token');
      int callCount = 0;

      mockAdapter.handler = (options, _) async {
        if (options.path == '/schedules') {
          return _jsonResponse(_listResponse());
        }
        callCount++;
        await Future.delayed(const Duration(milliseconds: 50));
        return _jsonResponse({
          'message': 'OK',
          'data': {'reminder_status': 'published'},
        });
      };

      await notifier.fetchSchedules();

      final future1 = notifier.broadcastSchedule('schedule-uuid-001');
      final future2 = notifier.broadcastSchedule('schedule-uuid-001');
      await Future.wait([future1, future2]);

      expect(callCount, 1);
    });

    test('clearError menghapus errorMessage dari state', () async {
      mockAdapter.handler = (options, _) async => _jsonResponse(
            {'message': 'Error.'},
            statusCode: 500,
          );
      await notifier.fetchSchedules();
      expect(notifier.state.errorMessage, isNotNull);

      notifier.clearError();
      expect(notifier.state.errorMessage, isNull);
    });
  });

  // =========================================================================
  // H. BroadcastResponse.fromJson — parsing respons broadcast
  // =========================================================================

  group('H. BroadcastResponse.fromJson — parsing', () {
    test('parsing respons broadcast lengkap berhasil', () {
      final json = {
        'message': 'Siaran berhasil diproses.',
        'data': {
          'reminder_status': 'published',
          'notifications_processed': 45,
          'broadcasted_at': '2026-07-14T12:00:00.000000Z',
        },
      };

      final result = BroadcastResponse.fromJson(json);

      expect(result.message, 'Siaran berhasil diproses.');
      expect(result.reminderStatus, 'published');
      expect(result.notificationsProcessed, 45);
      expect(result.broadcastedAt, '2026-07-14T12:00:00.000000Z');
    });

    test('parsing respons broadcast minimal (tanpa notificationsProcessed)',
        () {
      final json = {
        'message': 'OK.',
        'data': {'reminder_status': 'published'},
      };

      final result = BroadcastResponse.fromJson(json);

      expect(result.reminderStatus, 'published');
      expect(result.notificationsProcessed, isNull);
    });

    test('parsing respons broadcast saat notificationsProcessed di root', () {
      final json = {
        'message': 'OK.',
        'reminder_status': 'published',
        'notifications_processed': 30,
      };

      final result = BroadcastResponse.fromJson(json);

      expect(result.reminderStatus, 'published');
      expect(result.notificationsProcessed, 30);
    });
  });
}
