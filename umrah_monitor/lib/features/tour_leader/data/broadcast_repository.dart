import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';

class CreateBroadcastPayload {
  final String title;
  final String message;
  final String category;
  final String priority;
  final String targetType; // 'kloter'
  final List<String> kloterIds;
  final bool sendToFamily;

  const CreateBroadcastPayload({
    required this.title,
    required this.message,
    this.category = 'general',
    this.priority = 'normal',
    this.targetType = 'kloter',
    required this.kloterIds,
    this.sendToFamily = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'category': category,
      'priority': priority,
      'target_type': targetType,
      'kloter_ids': kloterIds,
      'send_to_family': sendToFamily,
    };
  }
}

class BroadcastResult {
  final String message;
  final int recipientsCount;
  final int notificationsQueued;
  final Map<String, dynamic>? broadcast;

  const BroadcastResult({
    required this.message,
    required this.recipientsCount,
    required this.notificationsQueued,
    this.broadcast,
  });

  factory BroadcastResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return BroadcastResult(
      message: json['message']?.toString() ?? 'Broadcast berhasil dikirim.',
      recipientsCount: (data['recipients_count'] as num?)?.toInt() ?? 0,
      notificationsQueued: (data['notifications_queued'] as num?)?.toInt() ?? 0,
      broadcast: data['broadcast'] as Map<String, dynamic>?,
    );
  }
}

class BroadcastRepository {
  final ApiClient apiClient;
  final SecureStorage secureStorage;
  static const _uuid = Uuid();

  BroadcastRepository({
    required this.apiClient,
    required this.secureStorage,
  });

  Future<String> _requireToken() async {
    final token = await secureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token autentikasi tidak ditemukan. Silakan login kembali.');
    }
    return token;
  }

  /// Mengirim siaran pengumuman baru oleh Tour Leader
  /// Idempotensi dijamin melalui header X-Idempotency-Key
  Future<BroadcastResult> createBroadcast({
    required CreateBroadcastPayload payload,
    String? idempotencyKey,
  }) async {
    final token = await _requireToken();
    final key = idempotencyKey ?? _uuid.v4();

    final response = await apiClient.dio.post(
      '/broadcasts',
      data: payload.toJson(),
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'X-Idempotency-Key': key,
        },
      ),
    );

    return BroadcastResult.fromJson(response.data as Map<String, dynamic>);
  }
}
