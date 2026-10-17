import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<String?> getToken() async {
    await _messaging.requestPermission();

    final token = await _messaging.getToken();

    debugPrint(
      'FCM token status: ${token == null ? "belum tersedia" : "berhasil didapat"}',
    );

    return token;
  }
}
