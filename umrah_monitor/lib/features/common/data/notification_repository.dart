import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';

class NotificationRepository {
  final ApiClient apiClient;
  final SecureStorage secureStorage;

  NotificationRepository({
    required this.apiClient,
    required this.secureStorage,
  });

  Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    final token = await secureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token autentikasi tidak ditemukan. Silakan login kembali.');
    }

    final response = await apiClient.dio.get(
      '/notifications',
      queryParameters: {'page': page},
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil daftar notifikasi.');
    }

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> markAsRead(String id) async {
    final token = await secureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token autentikasi tidak ditemukan. Silakan login kembali.');
    }

    final response = await apiClient.dio.patch(
      '/notifications/$id/read',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menandai notifikasi telah dibaca.');
    }
  }
}
