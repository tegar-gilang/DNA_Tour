import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../domain/broadcast_model.dart';

class BroadcastRepository {
  final ApiClient apiClient;
  final SecureStorage secureStorage;

  BroadcastRepository({required this.apiClient, required this.secureStorage});

  Future<String> _requireToken() async {
    final token = await secureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }
    return token;
  }

  /// Mengambil daftar broadcast yang tersedia untuk user yang login.
  /// Mengembalikan list kosong bila respons tidak mengandung data.
  Future<List<Broadcast>> getBroadcasts() async {
    final token = await _requireToken();
    final response = await apiClient.dio.get(
      '/broadcasts',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final raw = response.data as Map<String, dynamic>?;
    if (raw == null || raw['data'] == null) return <Broadcast>[];
    final List<dynamic> list = raw['data'] as List<dynamic>;
    return list.map((e) => Broadcast.fromJson(e as Map<String, dynamic>)).toList();
  }
}
