import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:umrah_monitor/core/network/api_client.dart';
import 'package:umrah_monitor/core/storage/secure_storage.dart';
import 'package:umrah_monitor/features/common/data/notification_repository.dart';
import 'package:umrah_monitor/features/common/domain/notification_model.dart';
import 'package:umrah_monitor/features/common/presentation/notification_provider.dart';

class FakeSecureStorage extends SecureStorage {
  String? fakeToken = 'valid_token_123';

  @override
  Future<String?> getToken() async => fakeToken;
}

void main() {
  group('NotificationRepository & NotificationNotifier Tests', () {
    late FakeSecureStorage storage;

    setUp(() {
      storage = FakeSecureStorage();
    });

    test('getNotifications fetches backend notifications and parses into state', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/notifications');
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'message': 'Notifications retrieved successfully',
                  'data': {
                    'current_page': 1,
                    'data': [
                      {
                        'id': 'notif-001',
                        'sos_incident_id': 'inc-999',
                        'recipient_type': 'App\\Models\\TourLeader',
                        'recipient_id': 'tl-123',
                        'type': 'sos_created',
                        'title': 'Laporan Darurat Baru',
                        'message': 'Ahmad melaporkan darurat di Safa Marwah',
                        'read_at': null,
                        'created_at': '2026-10-20T08:00:00.000000Z',
                      }
                    ],
                  },
                },
              ),
            );
          },
        ),
      );

      final repo = NotificationRepository(apiClient: ApiClient(customDio: dio), secureStorage: storage);
      final notifier = NotificationNotifier(repo);

      await notifier.fetchNotifications();

      expect(notifier.state.isLoading, false);
      expect(notifier.state.errorMessage, isNull);
      expect(notifier.state.notifications.length, 1);

      final notif = notifier.state.notifications.first;
      expect(notif.id, 'notif-001');
      expect(notif.title, 'Laporan Darurat Baru');
      expect(notif.subtitle, 'Ahmad melaporkan darurat di Safa Marwah');
      expect(notif.category, 'Darurat');
      expect(notif.isRead, false);
      expect(notif.incidentId, 'inc-999');
    });

    test('markAsRead triggers PATCH /notifications/{id}/read and updates local isRead', () async {
      String? patchedPath;

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            patchedPath = options.path;
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'message': 'Notification marked as read.'},
              ),
            );
          },
        ),
      );

      final repo = NotificationRepository(apiClient: ApiClient(customDio: dio), secureStorage: storage);
      final notifier = NotificationNotifier(repo);

      notifier.addNotificationIfAbsent(
        const NotificationModel(
          id: 'notif-001',
          title: 'Notif',
          subtitle: 'Sub',
          time: '10:00',
          dateGroup: 'Hari Ini',
          category: 'Darurat',
          priorityLabel: 'URGEN',
          icon: LucideIcons.bell,
          color: Colors.red,
          isRead: false,
        ),
      );

      await notifier.markAsRead('notif-001');

      expect(patchedPath, '/notifications/notif-001/read');
      expect(notifier.state.notifications.first.isRead, true);
    });

    test('addNotificationIfAbsent prevents duplicate notification entries', () {
      final notifier = NotificationNotifier();

      const item = NotificationModel(
        id: 'dup-123',
        title: 'Judul 1',
        subtitle: 'Pesan 1',
        time: '12:00',
        dateGroup: 'Hari Ini',
        category: 'Umum',
        priorityLabel: 'RUTIN',
        icon: LucideIcons.bell,
        color: Colors.blue,
      );

      notifier.addNotificationIfAbsent(item);
      expect(notifier.state.notifications.length, 1);

      // Add duplicate with same id
      notifier.addNotificationIfAbsent(item);
      expect(notifier.state.notifications.length, 1);
    });

    test('fetchNotifications handles error and empty state safely', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                error: 'Connection failed',
              ),
            );
          },
        ),
      );

      final repo = NotificationRepository(apiClient: ApiClient(customDio: dio), secureStorage: storage);
      final notifier = NotificationNotifier(repo);

      await notifier.fetchNotifications();

      expect(notifier.state.isLoading, false);
      expect(notifier.state.errorMessage, isNotNull);
      expect(notifier.state.notifications.isEmpty, true);
    });

    test('fetchNotifications merges backend data but preserves local-only notifications', () async {
      // Notifikasi lokal (dari FCM optimistic insert) dengan ID yang belum di backend
      const localItem = NotificationModel(
        id: 'fcm-local-999',
        title: 'Notif Lokal',
        subtitle: 'Belum di backend',
        time: 'Baru Saja',
        dateGroup: 'Hari Ini',
        category: 'Darurat',
        priorityLabel: 'URGEN',
        icon: LucideIcons.bell,
        color: Colors.red,
        isRead: false,
      );

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'message': 'OK',
                  'data': {
                    'current_page': 1,
                    'data': [
                      {
                        'id': 'notif-backend-001',
                        'sos_incident_id': 'inc-100',
                        'type': 'sos_created',
                        'title': 'Dari Backend',
                        'message': 'Sudah tersimpan',
                        'read_at': null,
                        'created_at': '2026-10-20T08:00:00.000000Z',
                      }
                    ],
                  },
                },
              ),
            );
          },
        ),
      );

      final repo = NotificationRepository(apiClient: ApiClient(customDio: dio), secureStorage: storage);
      final notifier = NotificationNotifier(repo);

      // Simulasikan: notifikasi lokal sudah ada sebelum fetch
      notifier.addNotificationIfAbsent(localItem);
      expect(notifier.state.notifications.length, 1);

      // Fetch dari backend
      await notifier.fetchNotifications();

      // Backend menghasilkan 1 notif, lokal tidak ada di backend
      // Merge harus menghasilkan 2 item: 1 dari backend + 1 lokal
      expect(notifier.state.notifications.length, 2);
      expect(notifier.state.notifications.any((n) => n.id == 'notif-backend-001'), true);
      expect(notifier.state.notifications.any((n) => n.id == 'fcm-local-999'), true);
    });

    test('addNotificationIfAbsent ignores item with empty id', () {
      final notifier = NotificationNotifier();
      const emptyIdItem = NotificationModel(
        id: '',
        title: 'Invalid',
        subtitle: 'Empty ID',
        time: 'Baru Saja',
        dateGroup: 'Hari Ini',
        category: 'Umum',
        priorityLabel: 'RUTIN',
        icon: LucideIcons.bell,
        color: Colors.blue,
      );

      notifier.addNotificationIfAbsent(emptyIdItem);
      expect(notifier.state.notifications.isEmpty, true);
    });
  });
}
