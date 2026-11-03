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
  ///
  /// Backend Laravel dapat mengembalikan dua format pada field `data`:
  ///   - **Paginated** : `{ data: { current_page, data: [...], total } }`
  ///   - **Flat list** : `{ data: [...] }`
  ///
  /// Keduanya ditangani secara eksplisit; tipe yang tidak dikenal
  /// diperlakukan sebagai list kosong agar tidak menyebabkan type-cast error.
  /// Mengembalikan list kosong bila respons tidak mengandung data.
  Future<List<Broadcast>> getBroadcasts() async {
    final token = await _requireToken();
    final response = await apiClient.dio.get(
      '/broadcasts',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final raw = response.data;
    if (raw is! Map<String, dynamic>) return <Broadcast>[];

    final rawData = raw['data'];

    // Normalise ke List<dynamic> agar logic di bawah seragam.
    final List<dynamic> list;
    if (rawData is List) {
      // Format B – flat list: { data: [...] }
      list = rawData;
    } else if (rawData is Map) {
      // Format A – paginated: { data: { data: [...], ... } }
      final inner = rawData['data'];
      list = inner is List ? inner : <dynamic>[];
    } else {
      // Format tidak dikenal atau null — kembalikan list kosong
      return <Broadcast>[];
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map(Broadcast.fromJson)
        .toList();
  }
}
