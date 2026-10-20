import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';

class SosRepository {
  final ApiClient apiClient;
  final SecureStorage secureStorage;

  SosRepository({required this.apiClient, required this.secureStorage});

  Future<Map<String, dynamic>> createIncident({
    required String type,
    required double latitude,
    required double longitude,
    String? description,
    String? locationName,
  }) async {
    final token = await secureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Token autentikasi tidak ditemukan. Silakan login kembali.',
      );
    }

    final response = await apiClient.dio.post(
      '/sos-incidents',
      data: {
        'type': type,
        'latitude': latitude,
        'longitude': longitude,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        if (locationName != null && locationName.trim().isNotEmpty)
          'location_name': locationName.trim(),
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );

    if (response.statusCode != 201) {
      throw Exception('SOS belum berhasil dibuat di backend.');
    }

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getIncidents() async {
    final token = await secureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Token autentikasi tidak ditemukan. Silakan login kembali.',
      );
    }

    final response = await apiClient.dio.get(
      '/sos-incidents',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil daftar insiden SOS.');
    }

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getIncidentDetail(String id) async {
    final token = await secureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Token autentikasi tidak ditemukan. Silakan login kembali.',
      );
    }

    final response = await apiClient.dio.get(
      '/sos-incidents/$id',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil detail insiden SOS.');
    }

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateIncidentStatus({
    required String id,
    required String status,
    String? reason,
  }) async {
    final token = await secureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Token autentikasi tidak ditemukan. Silakan login kembali.',
      );
    }

    final response = await apiClient.dio.patch(
      '/sos-incidents/$id/status',
      data: {
        'status': status,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui status insiden SOS.');
    }

    return Map<String, dynamic>.from(response.data as Map);
  }
}
