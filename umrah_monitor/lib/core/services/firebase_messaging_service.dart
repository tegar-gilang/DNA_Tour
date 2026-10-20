import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_router.dart';
import '../../features/tracking/presentation/incident_provider.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/common/presentation/notification_provider.dart';
import '../../features/common/domain/notification_model.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background message handler entry-point untuk Android/iOS
  debugPrint('FCM background message received: ${message.messageId}');
}

class FirebaseMessagingService {
  final FirebaseMessaging? _customMessaging;
  FirebaseMessaging get _messaging => _customMessaging ?? FirebaseMessaging.instance;
  bool _isConfigured = false;
  String? _lastHandledMessageId;

  // Mencegah multiple sync berjalan bersamaan
  bool _isSyncing = false;

  FirebaseMessagingService({FirebaseMessaging? messaging})
      : _customMessaging = messaging;

  Future<String?> getToken() async {
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

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

    // Gunakan notification_id dari payload backend jika ada (stabil & idempotent).
    // Fallback ke messageId hanya jika notification_id tidak tersedia.
    final rawNotifId = data['notification_id']?.toString();
    final notifId = (rawNotifId != null && rawNotifId.isNotEmpty)
        ? rawNotifId
        : (message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString());

    final notification = message.notification;
    final title = notification?.title ??
        (data['title']?.toString() ?? 'Pemberitahuan DNA Tour');
    final body = notification?.body ??
        (data['body']?.toString() ?? 'Ada informasi terbaru.');

    // 1. Refresh daftar insiden jika ada incident terkait
    if (incidentId != null && incidentId.isNotEmpty) {
      ref.read(incidentNotifierProvider.notifier).fetchIncidents();
    }

    // 2. Tambahkan notifikasi ke state lokal terlebih dahulu (optimistic).
    //    Ini memastikan notifikasi muncul di Pusat Notifikasi segera,
    //    sebelum backend selesai menyimpan via ProcessSosNotificationJob.
    //    Guard terhadap id kosong dilakukan di dalam addNotificationIfAbsent.
    ref.read(notificationNotifierProvider.notifier).addNotificationIfAbsent(
      NotificationModel(
        id: notifId,
        title: title,
        subtitle: body,
        time: 'Baru Saja',
        dateGroup: 'Hari Ini',
        category:
            incidentId != null && incidentId.isNotEmpty ? 'Darurat' : 'Umum',
        priorityLabel:
            incidentId != null && incidentId.isNotEmpty ? 'URGEN' : 'RUTIN',
        icon: incidentId != null && incidentId.isNotEmpty
            ? Icons.warning_amber_rounded
            : Icons.notifications_rounded,
        color: incidentId != null && incidentId.isNotEmpty
            ? const Color(0xFFE53935)
            : const Color(0xFF1E88E5),
        isRead: false,
        incidentId: incidentId,
      ),
    );

    // 3. Sinkronisasi data dari backend dengan retry terbatas.
    //    Retry diperlukan karena ProcessSosNotificationJob berjalan async —
    //    FCM dapat tiba sebelum record Notification tersimpan di database.
    //    Notifikasi lokal (langkah 2) tetap dipertahankan selama sinkronisasi.
    _scheduleSyncWithMerge(ref, notifId: notifId);

    // 4. Tampilkan feedback singkat (SnackBar) saat aplikasi foreground
    if (isForeground) {
      final context = rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(body, style: const TextStyle(fontSize: 12)),
              ],
            ),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'LIHAT',
              textColor: Colors.amberAccent,
              onPressed: () {
                _handleNotificationNavigation(message, ref);
              },
            ),
          ),
        );
      }
    }
  }

  /// Menjadwalkan sinkronisasi backend dengan retry eksponensial terbatas.
  ///
  /// Strategi:
  /// - Attempt 1: setelah 2 detik (memberi waktu job backend selesai).
  /// - Attempt 2: setelah 5 detik (jika job lambat / antrian penuh).
  /// - Attempt 3: tidak ada. Maksimum 2 retry.
  ///
  /// [notifId] digunakan untuk memastikan notifikasi lokal tidak hilang
  /// saat merge hasil fetch backend. Jika backend mengembalikan notifikasi
  /// dengan ID yang sama, deduplication mencegah duplikasi.
  ///
  /// Guard [_isSyncing] memastikan tidak ada request bertumpuk.
  void _scheduleSyncWithMerge(WidgetRef ref, {required String notifId}) {
    const delays = [Duration(seconds: 2), Duration(seconds: 5)];

    Future<void> attempt(int index) async {
      if (index >= delays.length) return;
      await Future.delayed(delays[index]);

      if (_isSyncing) {
        // Ada sync lain berjalan; lewati attempt ini.
        return;
      }
      _isSyncing = true;

      try {
        await ref
            .read(notificationNotifierProvider.notifier)
            .fetchNotifications();
        // Berhasil — tidak perlu retry lagi.
      } catch (_) {
        // Gagal — coba attempt berikutnya.
        _isSyncing = false;
        await attempt(index + 1);
        return;
      } finally {
        _isSyncing = false;
      }
    }

    // Jalankan attempt pertama (non-blocking terhadap UI).
    attempt(0);
  }

  void _handleNotificationNavigation(RemoteMessage message, WidgetRef ref) {
    final messageId = message.messageId;
    if (messageId != null && messageId == _lastHandledMessageId) {
      return; // Cegah navigasi ganda
    }
    _lastHandledMessageId = messageId;

    final data = message.data;
    final incidentId = data['incident_id']?.toString();
    final router = ref.read(routerProvider);
    final authState = ref.read(authProvider);

    if (!authState.isAuthenticated) {
      router.go('/login');
      return;
    }

    if (incidentId != null && incidentId.isNotEmpty) {
      ref.read(incidentNotifierProvider.notifier).fetchIncidents();
      router.push('/tour_leader/incidents');
    } else {
      router.push('/notifications');
    }
  }
}

final firebaseMessagingServiceProvider = Provider<FirebaseMessagingService>((ref) {
  return FirebaseMessagingService();
});
