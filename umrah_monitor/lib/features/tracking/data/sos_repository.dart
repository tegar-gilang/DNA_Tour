import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';

class SosRepository {
  final ApiClient apiClient;
  final SecureStorage secureStorage;

  SosRepository({required this.apiClient, required this.secureStorage});

  /// Membuat laporan darurat SOS baru.
  ///
  /// [latitude] dan [longitude] bersifat opsional. Jika GPS tidak tersedia,
  /// keduanya dikirim sebagai null (tidak disertakan dalam payload JSON).
  /// Backend menerima insiden tanpa koordinat selama keduanya null bersama-sama.
  ///
  /// [locationName] tidak boleh berisi nama dari agenda perjalanan atau
  /// teks hardcoded. Kirim null jika sumber nama lokasi tidak terverifikasi.
  Future<Map<String, dynamic>> createIncident({
    required String type,
    double? latitude,
    double? longitude,
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
        // Koordinat dikirim hanya jika keduanya tersedia sekaligus.
        // Jangan mengirim salah satunya saja, dan jangan memakai 0 sebagai fallback.
        if (latitude != null && longitude != null) 'latitude': latitude,
        if (latitude != null && longitude != null) 'longitude': longitude,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        // location_name hanya dikirim jika berasal dari sumber terverifikasi
        // (misalnya reverse geocoding). Jangan kirim nama agenda perjalanan.
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
