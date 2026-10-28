import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_router.dart';
import '../../features/tracking/presentation/incident_provider.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/domain/user_model.dart';
import '../../features/common/presentation/notification_provider.dart';
import '../../features/common/domain/notification_model.dart';
import '../../features/pilgrim/presentation/timeline_provider.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background message handler entry-point untuk Android/iOS
  // Pesan dengan notification payload sudah otomatis ditampilkan oleh Android OS.
  debugPrint('FCM background message received: ${message.messageId}');
}

class FirebaseMessagingService {
  final FirebaseMessaging? _customMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  FirebaseMessaging get _messaging =>
      _customMessaging ?? FirebaseMessaging.instance;
  bool _isConfigured = false;
  String? _lastHandledMessageId;

  // Notification Channel ID konsisten dengan AndroidManifest.xml
  static const String scheduleChannelId = 'dna_tour_schedule_channel';
  static const AndroidNotificationChannel scheduleChannel =
      AndroidNotificationChannel(
        scheduleChannelId,
        'Jadwal & Agenda DNA Tour',
        description:
            'Notifikasi pengingat jadwal ibadah dan agenda kegiatan DNA Tour',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

  // Mencegah multiple sync berjalan bersamaan
  bool _isSyncing = false;

  FirebaseMessagingService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _customMessaging = messaging,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  Future<void> _initLocalNotifications(WidgetRef ref) async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          try {
            final Map<String, dynamic> data =
                jsonDecode(payload) as Map<String, dynamic>;
            _handleNavigationFromData(data, ref);
          } catch (e) {
            debugPrint('Error parsing notification response payload: $e');
            _handleNavigationFromData({'schedule_id': payload}, ref);
          }
        }
      },
    );

    // Buat notification channel di Android dengan importance MAX (heads-up banner)
    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(scheduleChannel);
    }
  }

  Future<String?> getToken() async {
    try {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);

      final token = await _messaging.getToken();

      debugPrint(
        'FCM token status: ${token == null ? "belum tersedia" : "berhasil didapat"}',
      );

      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  void initializeForegroundAndBackgroundHandlers(WidgetRef ref) {
    if (_isConfigured) return;
    _isConfigured = true;

    // Inisialisasi local notification engine & channel Android
    _initLocalNotifications(ref);

    // Listen to token refresh and update backend
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint('FCM token refreshed: $newToken');
      _updateDeviceTokenOnBackend(newToken, ref);
    });

    // 1. Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM foreground message received: ${message.messageId}');
      _handleIncomingMessage(message, ref, isForeground: true);
    });

    // 2. Background message opened handler (ketika notifikasi diketuk saat app di background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        'FCM notification opened app from background: ${message.messageId}',
      );
      _handleNotificationNavigation(message, ref);
    });

    // 3. Terminated state handler (ketika notifikasi diketuk saat app terminated)
    _checkInitialMessage(ref);
  }

  Future<void> _checkInitialMessage(WidgetRef ref) async {
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
          'FCM initial message from terminated state: ${initialMessage.messageId}',
        );
        _handleNotificationNavigation(initialMessage, ref);
      }
    } catch (e) {
      debugPrint('Error checking initial FCM message: $e');
    }
  }

  void _handleIncomingMessage(
    RemoteMessage message,
    WidgetRef ref, {
    required bool isForeground,
  }) {
    final data = message.data;
    final incidentId = data['incident_id']?.toString();
    final broadcastId = data['broadcast_id']?.toString();
    final type = data['type']?.toString().toLowerCase() ?? '';

    // Gunakan notification_id dari payload backend jika ada (stabil & idempotent).
    // Fallback ke messageId hanya jika notification_id tidak tersedia.
    final rawNotifId = data['notification_id']?.toString();
    final notifId = (rawNotifId != null && rawNotifId.isNotEmpty)
        ? rawNotifId
        : (message.messageId ??
              DateTime.now().millisecondsSinceEpoch.toString());

    final notification = message.notification;
    final title =
        notification?.title ??
        (data['title']?.toString() ?? 'Pemberitahuan DNA Tour');
    final body =
        notification?.body ??
        (data['body']?.toString() ?? 'Ada informasi terbaru.');

    final scheduleId = data['schedule_id']?.toString();

    // 1. Refresh daftar insiden jika ada incident terkait
    if (incidentId != null && incidentId.isNotEmpty) {
      ref.read(incidentNotifierProvider.notifier).fetchIncidents();
    }
    // 1b. Refresh timeline jika notifikasi adalah schedule_reminder
    if (scheduleId != null && scheduleId.isNotEmpty) {
      ref.read(timelineProvider.notifier).refresh();
    }

    // Tentukan kategori, icon, dan warna sesuai tipe notifikasi
    final isEmergency = incidentId != null && incidentId.isNotEmpty;
    final isBroadcast = type == 'broadcast' || (broadcastId != null && broadcastId.isNotEmpty);

    final String category = isEmergency
        ? 'Darurat'
        : (isBroadcast ? 'Siaran' : 'Umum');
    final String priorityLabel = isEmergency
        ? 'URGEN'
        : (isBroadcast ? 'PENTING' : 'RUTIN');
    final IconData icon = isEmergency
        ? Icons.warning_amber_rounded
        : (isBroadcast ? Icons.campaign_rounded : Icons.notifications_rounded);
    final Color color = isEmergency
        ? const Color(0xFFE53935)
        : (isBroadcast ? const Color(0xFFC27803) : const Color(0xFF1E88E5));

    // 2. Tambahkan notifikasi ke state lokal terlebih dahulu (optimistic).
    ref
        .read(notificationNotifierProvider.notifier)
        .addNotificationIfAbsent(
          NotificationModel(
            id: notifId,
            title: title,
            subtitle: body,
            time: 'Baru Saja',
            dateGroup: 'Hari Ini',
            category: category,
            priorityLabel: priorityLabel,
            icon: icon,
            color: color,
            isRead: false,
            incidentId: incidentId,
            broadcastId: broadcastId,
          ),
        );

    // 3. Sinkronisasi data dari backend dengan retry terbatas.
    _scheduleSyncWithMerge(ref, notifId: notifId);

    // 4. Tampilkan Android System Notification Banner saat foreground
    if (isForeground) {
      _showForegroundSystemNotification(
        notifId: notifId,
        title: title,
        body: body,
        data: data,
      );
    }
  }

  void _showForegroundSystemNotification({
    required String notifId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) {
    try {
      // Ubah string notifId menjadi integer stabil 32-bit untuk ID notifikasi Android
      final int id = notifId.hashCode & 0x7FFFFFFF;

      final androidDetails = AndroidNotificationDetails(
        scheduleChannel.id,
        scheduleChannel.name,
        channelDescription: scheduleChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      _localNotifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: jsonEncode(data),
      );
    } catch (e) {
      debugPrint('Error showing local notification banner: $e');
    }
  }

  /// Menjadwalkan sinkronisasi backend dengan retry eksponensial terbatas.
  void _scheduleSyncWithMerge(WidgetRef ref, {required String notifId}) {
    const delays = [Duration(seconds: 2), Duration(seconds: 5)];

    Future<void> attempt(int index) async {
      if (index >= delays.length) return;
      await Future.delayed(delays[index]);

      if (_isSyncing) {
        return;
      }
      _isSyncing = true;

      try {
        await ref
            .read(notificationNotifierProvider.notifier)
            .fetchNotifications();
      } catch (_) {
        _isSyncing = false;
        await attempt(index + 1);
        return;
      } finally {
        _isSyncing = false;
      }
    }

    attempt(0);
  }

  Future<void> _updateDeviceTokenOnBackend(
    String newToken,
    WidgetRef ref,
  ) async {
    try {
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        final authRepo = ref.read(authRepositoryProvider);
        await authRepo.registerDeviceToken(
          fcmToken: newToken,
          platform:
              Theme.of(rootNavigatorKey.currentContext!).platform ==
                  TargetPlatform.iOS
              ? 'ios'
              : 'android',
        );
        debugPrint('FCM refreshed token updated on backend.');
      }
    } catch (e) {
      debugPrint('Failed to update refreshed FCM token: $e');
    }
  }

  void _handleNotificationNavigation(RemoteMessage message, WidgetRef ref) {
    final messageId = message.messageId;
    if (messageId != null && messageId == _lastHandledMessageId) {
      return; // Cegah navigasi ganda
    }
    _lastHandledMessageId = messageId;

    _handleNavigationFromData(message.data, ref);
  }

  void _handleNavigationFromData(Map<String, dynamic> data, WidgetRef ref) {
    final incidentId = data['incident_id']?.toString();
    final rawScheduleId = data['schedule_id']?.toString();
    final router = ref.read(routerProvider);
    final authState = ref.read(authProvider);

    if (!authState.isAuthenticated) {
      router.go('/login');
      return;
    }

    if (incidentId != null && incidentId.isNotEmpty) {
      ref.read(incidentNotifierProvider.notifier).fetchIncidents();

      final isTourLeader =
          authState.selectedRole == UserRole.tourLeader ||
          authState.tourLeader != null;
      if (isTourLeader) {
        router.push('/tour_leader/incidents');
      } else {
        router.push('/sos');
      }
    } else if (rawScheduleId != null &&
        rawScheduleId.isNotEmpty &&
        rawScheduleId != '0') {
      router.push('/schedule_detail/$rawScheduleId');
    } else {
      router.push('/notifications');
    }
  }
}

final firebaseMessagingServiceProvider = Provider<FirebaseMessagingService>((
  ref,
) {
  return FirebaseMessagingService();
});
