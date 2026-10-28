import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umrah_monitor/core/network/api_client.dart';
import 'package:umrah_monitor/core/storage/secure_storage.dart';
import 'package:umrah_monitor/features/common/domain/notification_model.dart';
import 'package:umrah_monitor/features/tour_leader/data/broadcast_repository.dart';
import 'package:umrah_monitor/features/tour_leader/presentation/broadcast_provider.dart';

class FakeSecureStorage extends SecureStorage {
  String? token = 'valid_tour_leader_token';
  String? role = 'tour_leader';

  @override
  Future<String?> getToken() async => token;
  @override
  Future<String?> getRole() async => role;
}

class FakeApiClient extends ApiClient {
  final Dio mockDio;
  FakeApiClient(this.mockDio);
  @override
  Dio get dio => mockDio;
}

void main() {
  group('NotificationModel Broadcast Mapping Tests', () {
    test('NotificationModel.fromJson memetakan notifikasi type broadcast dengan aman', () {
      final json = {
        'id': 'b1029c78-5e8a-4c25-bb30-1b777a988d8b',
        'broadcast_id': 'f7d24ab5-4627-4632-a50e-7c5efc078e47',
        'type': 'broadcast',
        'title': 'Jadwal Ziarah Raudhah',
        'message': 'Jamaah berkumpul di lobi hotel pukul 08.00 pagi.',
        'read_at': null,
        'created_at': '2026-10-27T10:00:00Z',
      };

      final model = NotificationModel.fromJson(json);

      expect(model.id, equals('b1029c78-5e8a-4c25-bb30-1b777a988d8b'));
      expect(model.broadcastId, equals('f7d24ab5-4627-4632-a50e-7c5efc078e47'));
      expect(model.category, equals('Siaran'));
      expect(model.title, equals('Jadwal Ziarah Raudhah'));
      expect(model.subtitle, equals('Jamaah berkumpul di lobi hotel pukul 08.00 pagi.'));
      expect(model.isRead, isFalse);
    });

    test('NotificationModel.fromJson memetakan notifikasi broadcast yang sudah read_at', () {
      final json = {
        'id': 'b1029c78-5e8a-4c25-bb30-1b777a988d8c',
        'broadcast_id': 'f7d24ab5-4627-4632-a50e-7c5efc078e47',
        'type': 'broadcast',
        'title': 'Pengumuman Selesai',
        'message': 'Kegiatan telah berakhir.',
        'read_at': '2026-10-27T11:00:00Z',
        'created_at': '2026-10-27T10:00:00Z',
      };

      final model = NotificationModel.fromJson(json);

      expect(model.isRead, isTrue);
      expect(model.category, equals('Siaran'));
    });

    test('Notifikasi SOS dan Schedule tidak terpengaruh oleh penambahan broadcast', () {
      final sosJson = {
        'id': 'sos-notif-1',
        'sos_incident_id': 'inc-99',
        'type': 'sos',
        'title': 'SOS Darurat',
        'message': 'Jamaah membutuhkan pertolongan.',
      };
      final sosModel = NotificationModel.fromJson(sosJson);
      expect(sosModel.category, equals('Darurat'));
      expect(sosModel.priorityLabel, equals('URGEN'));

      final scheduleJson = {
        'id': 'sched-notif-1',
        'type': 'schedule_reminder',
        'title': 'Pengingat Jadwal',
        'message': 'Sholat Ashar di Masjidil Haram',
      };
      final schedModel = NotificationModel.fromJson(scheduleJson);
      expect(schedModel.category, equals('Aktivitas'));
    });
  });

  group('BroadcastRepository & Idempotency Tests', () {
    late Dio dio;
    late FakeSecureStorage secureStorage;
    late BroadcastRepository repository;

    setUp(() {
      dio = Dio();
      secureStorage = FakeSecureStorage();
      repository = BroadcastRepository(
        apiClient: FakeApiClient(dio),
        secureStorage: secureStorage,
      );
    });

    test('createBroadcast mengirim payload dan menyertakan header X-Idempotency-Key', () async {
      RequestOptions? capturedOptions;

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedOptions = options;
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'message': 'Broadcast informasi berhasil diterbitkan dan sedang dikirim.',
                  'data': {
                    'recipients_count': 45,
                    'notifications_queued': 45,
                    'broadcast': {'id': 'bc-123'},
                  },
                },
              ),
            );
          },
        ),
      );

      final payload = CreateBroadcastPayload(
        title: 'Pengumuman Kloter 4',
        message: 'Harap standby di bus 8.',
        category: 'logistik',
        priority: 'urgent',
        targetType: 'kloter',
        kloterIds: ['kloter-uuid-1'],
        sendToFamily: true,
      );

      const customKey = 'test-idempotency-key-uuid-1234';
      final result = await repository.createBroadcast(
        payload: payload,
        idempotencyKey: customKey,
      );

      expect(result.recipientsCount, equals(45));
      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.path, equals('/broadcasts'));
      expect(capturedOptions!.headers['X-Idempotency-Key'], equals(customKey));
      expect(capturedOptions!.headers['Authorization'], equals('Bearer valid_tour_leader_token'));

      final body = capturedOptions!.data as Map<String, dynamic>;
      expect(body['title'], equals('Pengumuman Kloter 4'));
      expect(body['target_type'], equals('kloter'));
      expect(body['kloter_ids'], equals(['kloter-uuid-1']));
      expect(body['send_to_family'], isTrue);
    });

    test('BroadcastNotifier mempertahankan idempotency key yang sama jika terjadi error', () async {
      int requestCount = 0;
      List<String?> sentKeys = [];

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestCount++;
            sentKeys.add(options.headers['X-Idempotency-Key']?.toString());
            if (requestCount == 1) {
              return handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response(
                    requestOptions: options,
                    statusCode: 504,
                    data: {'message': 'Gateway Timeout'},
                  ),
                  type: DioExceptionType.receiveTimeout,
                ),
              );
            }
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'message': 'Broadcast telah diproses sebelumnya (idempotent replay).',
                  'data': {
                    'recipients_count': 45,
                    'notifications_queued': 45,
                  },
                },
              ),
            );
          },
        ),
      );

      final notifier = BroadcastNotifier(repository);
      final initialKey = notifier.currentIdempotencyKey;

      final payload = CreateBroadcastPayload(
        title: 'Pengumuman Retry',
        message: 'Percobaan idempotensi.',
        kloterIds: ['kloter-1'],
      );

      // Attempt 1 -> Fail
      final firstSuccess = await notifier.sendBroadcast(payload);
      expect(firstSuccess, isFalse);
      expect(notifier.currentIdempotencyKey, equals(initialKey)); // Key tidak berubah saat gagal

      // Attempt 2 -> Retry dengan key yang sama
      final secondSuccess = await notifier.sendBroadcast(payload);
      expect(secondSuccess, isTrue);

      expect(sentKeys.length, equals(2));
      expect(sentKeys[0], equals(sentKeys[1])); // Keduanya menggunakan idempotency key yang sama
    });
  });
}
