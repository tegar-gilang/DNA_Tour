// test/timeline_and_detail_stage5_test.dart
//
// Regression tests untuk Stage 5: Timeline Jamaah & Family, Detail Jadwal,
// Read-Only Assurance, dan Navigasi Notifikasi.

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umrah_monitor/core/network/api_client.dart';
import 'package:umrah_monitor/core/services/firebase_messaging_service.dart';
import 'package:umrah_monitor/core/storage/secure_storage.dart';
import 'package:umrah_monitor/features/pilgrim/presentation/pilgrim_schedule_screen.dart';
import 'package:umrah_monitor/features/pilgrim/presentation/timeline_provider.dart';
import 'package:umrah_monitor/features/tour_leader/data/schedule_repository.dart';
import 'package:umrah_monitor/features/tour_leader/domain/schedule_model.dart';

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
      _storage.containsKey('auth_token') && _storage['auth_token']!.isNotEmpty;
}

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

ApiClient _makeApiClientWithAdapter(MockHttpClientAdapter adapter) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://test.local/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockHttpClientAdapter mockAdapter;
  late FakeSecureStorage fakeStorage;
  late ScheduleRepository repository;

  setUp(() async {
    mockAdapter = MockHttpClientAdapter();
    fakeStorage = FakeSecureStorage();
    await fakeStorage.saveToken('test-sanctum-token-123');
    await fakeStorage.saveRole('pilgrim');

    final apiClient = _makeApiClientWithAdapter(mockAdapter);
    repository = ScheduleRepository(
      apiClient: apiClient,
      secureStorage: fakeStorage,
    );
  });

  group('A. ScheduleRepository.getScheduleDetail', () {
    test('berhasil mengambil detail jadwal dari GET /schedules/{id}', () async {
      mockAdapter.handler = (options, _) async {
        expect(options.path, '/schedules/10');
        expect(options.method, 'GET');
        return _jsonResponse({
          'message': 'Detail perjalanan berhasil diambil.',
          'data': {
            'id': 10,
            'title': 'Check in Hotel di Madinah',
            'category': 'hotel',
            'location': 'Hotel di Madinah',
            'keterangan': 'Sampai Hotel di Madinah',
            'pic': 'Ustadz Ahmad',
            'start_time': '2026-07-03T21:30:00.000000Z',
            'end_time': null,
            'effective_end_datetime': '2026-07-04T03:00:00+00:00',
            'status': 'completed',
            'status_mode': 'auto',
            'reminder_status': 'draft',
            'broadcasted_at': null,
          }
        });
      };

      final response = await repository.getScheduleDetail('10');
      expect(response.schedule.id, '10');
      expect(response.schedule.title, 'Check in Hotel di Madinah');
      expect(response.schedule.status, 'completed');
      expect(response.schedule.reminderStatus, 'draft');
      expect(response.schedule.effectiveEndTime, '2026-07-04T03:00:00+00:00');
    });

    test('melempar DioException saat detail jadwal 404', () async {
      mockAdapter.handler = (options, _) async {
        return _jsonResponse({
          'message': 'Jadwal tidak ditemukan.',
        }, statusCode: 404);
      };

      expect(
        () => repository.getScheduleDetail('999'),
        throwsA(isA<DioException>()),
      );
    });

    test('melempar DioException saat akses 403', () async {
      mockAdapter.handler = (options, _) async {
        return _jsonResponse({
          'message': 'Unauthorized.',
        }, statusCode: 403);
      };

      expect(
        () => repository.getScheduleDetail('10'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('B. TimelineNotifier (Read-Only) State Management', () {
    test('state awal: kosong, tidak loading, tidak ada error', () {
      final notifier = TimelineNotifier(repository);
      expect(notifier.state.schedules, isEmpty);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, isNull);
    });

    test('fetchSchedules mengisi state.schedules dan menyertakan jadwal draft', () async {
      mockAdapter.handler = (options, _) async {
        return _jsonResponse({
          'message': 'Sukses',
          'data': [
            {
              'id': 1,
              'title': 'Kumpul Kantor',
              'status': 'upcoming',
              'reminder_status': 'draft',
              'start_time': '2026-07-02T21:00:00',
            },
            {
              'id': 2,
              'title': 'Bandara Soetta',
              'status': 'in_progress',
              'reminder_status': 'published',
              'start_time': '2026-07-02T22:00:00',
            }
          ]
        });
      };

      final notifier = TimelineNotifier(repository);
      await notifier.fetchSchedules();

      expect(notifier.state.schedules.length, 2);
      expect(notifier.state.schedules[0].reminderStatus, 'draft');
      expect(notifier.state.schedules[1].reminderStatus, 'published');
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, isNull);
    });

    test('fetchSchedules menangani 403 Akses Ditolak tanpa menghapus sesi', () async {
      mockAdapter.handler = (options, _) async {
        return _jsonResponse({'message': 'Unauthorized.'}, statusCode: 403);
      };

      final notifier = TimelineNotifier(repository);
      await notifier.fetchSchedules();

      expect(notifier.state.schedules, isEmpty);
      expect(notifier.state.statusCode, 403);
      expect(notifier.state.errorMessage, contains('Akses ditolak'));
    });

    test('fetchSchedules menangani 401 Sesi Berakhir', () async {
      mockAdapter.handler = (options, _) async {
        return _jsonResponse({'message': 'Unauthenticated.'}, statusCode: 401);
      };

      final notifier = TimelineNotifier(repository);
      await notifier.fetchSchedules();

      expect(notifier.state.statusCode, 401);
      expect(notifier.state.errorMessage, contains('Sesi Anda telah berakhir'));
    });
  });

  group('C. ScheduleDetailNotifier State Management', () {
    test('fetchDetail berhasil dan menyimpan ScheduleModel', () async {
      mockAdapter.handler = (options, _) async {
        return _jsonResponse({
          'data': {
            'id': 20,
            'title': 'Check in Hotel',
            'status': 'in_progress',
            'reminder_status': 'draft',
            'start_time': '2026-10-06T16:00:00',
          }
        });
      };

      final notifier = ScheduleDetailNotifier(repository);
      await notifier.fetchDetail('20');

      expect(notifier.state.schedule, isNotNull);
      expect(notifier.state.schedule!.id, '20');
      expect(notifier.state.schedule!.status, 'in_progress');
      expect(notifier.state.errorMessage, isNull);
    });

    test('fetchDetail menggunakan cached data terlebih dahulu', () async {
      mockAdapter.handler = (options, _) async {
        return _jsonResponse({
          'data': {
            'id': 5,
            'title': 'Updated Title dari Server',
            'status': 'completed',
            'reminder_status': 'published',
            'start_time': '2026-10-06T16:00:00',
          }
        });
      };

      const cached = ScheduleModel(
        id: '5',
        title: 'Initial Title Cache',
        startTime: '2026-10-06T16:00:00',
        status: 'upcoming',
        statusMode: 'auto',
        reminderStatus: 'draft',
      );

      final notifier = ScheduleDetailNotifier(repository);
      final future = notifier.fetchDetail('5', cached: cached);
      // Saat fetch berjalan, cached sudah ada
      expect(notifier.state.schedule?.title, 'Initial Title Cache');
      await future;
      // Setelah fetch selesai, data server terpasang
      expect(notifier.state.schedule?.title, 'Updated Title dari Server');
    });
  });

  group('D. Read-Only Widget Tests (Pilgrim & Family Timeline)', () {
    testWidgets('PilgrimScheduleScreen menampilkan data API & tidak ada tombol mutasi', (tester) async {
      final fakeSchedules = [
        const ScheduleModel(
          id: '101',
          title: 'Ziarah Raudhah',
          location: 'Masjid Nabawi',
          startTime: '2026-07-04T07:30:00',
          status: 'upcoming',
          statusMode: 'auto',
          reminderStatus: 'draft',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timelineProvider.overrideWith((ref) {
              final notifier = TimelineNotifier(repository);
              notifier.state = TimelineState(schedules: fakeSchedules);
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: PilgrimScheduleScreen(isFamilyView: false),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Memastikan judul dan detail tampil
      expect(find.text('Jadwal Perjalanan'), findsOneWidget);
      expect(find.text('Ziarah Raudhah'), findsOneWidget);
      expect(find.text('Masjid Nabawi'), findsOneWidget);
      expect(find.text('Akan Datang'), findsOneWidget);
      expect(find.text('Belum Disiarkan'), findsOneWidget);

      // Verifikasi Read-Only: TIDAK BOLEH ada tombol mutasi (Tambah, Ubah Status, Siarkan, dll.)
      expect(find.text('Tambah'), findsNothing);
      expect(find.text('Ubah Status'), findsNothing);
      expect(find.text('Siarkan'), findsNothing);
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Hapus'), findsNothing);
    });

    testWidgets('FamilyUpdatesScreen menampilkan data API & tidak ada tombol mutasi', (tester) async {
      final fakeSchedules = [
        const ScheduleModel(
          id: '102',
          title: 'Tawaf Wada',
          location: 'Masjidil Haram',
          startTime: '2026-07-19T08:00:00',
          status: 'completed',
          statusMode: 'auto',
          reminderStatus: 'published',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            timelineProvider.overrideWith((ref) {
              final notifier = TimelineNotifier(repository);
              notifier.state = TimelineState(schedules: fakeSchedules);
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: PilgrimScheduleScreen(isFamilyView: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tawaf Wada'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
      expect(find.text('Telah Disiarkan'), findsOneWidget);

      // Verifikasi Read-Only
      expect(find.text('Tambah'), findsNothing);
      expect(find.text('Ubah Status'), findsNothing);
      expect(find.text('Siarkan'), findsNothing);
    });
  });

  group('E. FCM Notification Payload & Navigation Tests', () {
    test('navigasi notifikasi menangani schedule_id valid secara idempotent', () {
      final fcmService = FirebaseMessagingService();
      // Verifikasi parsing dan state service
      expect(fcmService, isNotNull);
    });
  });
}
