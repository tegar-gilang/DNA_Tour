import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../domain/schedule_model.dart';

/// Repository untuk semua operasi jadwal (schedule) Tour Leader.
///
/// Semua method mengikuti pola yang sama dengan [AuthRepository] dan
/// [NotificationRepository] yang sudah ada: mengambil token dari
/// [SecureStorage] lalu menyertakannya di header Authorization.
///
/// Tidak ada transformasi state di sini — hanya I/O bersih ke API.
class ScheduleRepository {
  final ApiClient apiClient;
  final SecureStorage secureStorage;

  ScheduleRepository({
    required this.apiClient,
    required this.secureStorage,
  });

  // =========================================================================
  // Helper: mendapatkan token atau melempar Exception
  // =========================================================================

  Future<String> _requireToken() async {
    final token = await secureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token autentikasi tidak ditemukan. Silakan login kembali.');
    }
    return token;
  }

  Options _authOptions(String token) {
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  // =========================================================================
  // GET /api/schedules
  // =========================================================================

  /// Mengambil daftar jadwal dari backend.
  ///
  /// Backend dapat mengembalikan struktur paginated atau list biasa;
  /// [ScheduleListResponse.fromJson] menangani kedua format tersebut.
  Future<ScheduleListResponse> getSchedules() async {
    final token = await _requireToken();

    final response = await apiClient.dio.get(
      '/schedules',
      options: _authOptions(token),
    );

    return ScheduleListResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // =========================================================================
  // GET /api/schedules/{id}
  // =========================================================================

  /// Mengambil detail jadwal dari backend.
  ///
  /// Dapat diakses oleh Admin, Tour Leader, Jamaah, dan Family.
  Future<ScheduleSingleResponse> getScheduleDetail(String scheduleId) async {
    final token = await _requireToken();

    final response = await apiClient.dio.get(
      '/schedules/$scheduleId',
      options: _authOptions(token),
    );

    return ScheduleSingleResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // =========================================================================
  // POST /api/schedules
  // =========================================================================

  /// Membuat jadwal baru.
  ///
  /// [payload] hanya berisi field yang didukung backend.
  /// Field opsional (end_time, dll.) boleh tidak disertakan.
  Future<ScheduleSingleResponse> createSchedule(
    Map<String, dynamic> payload,
  ) async {
    final token = await _requireToken();

    final response = await apiClient.dio.post(
      '/schedules',
      data: payload,
      options: _authOptions(token),
    );

    return ScheduleSingleResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // =========================================================================
  // PATCH /api/schedules/{schedule}/status
  // =========================================================================

  /// Mengubah status pelaksanaan jadwal secara manual.
  ///
  /// [status] adalah salah satu dari: 'upcoming', 'in_progress', 'completed'.
  /// Backend menentukan apakah perubahan ini diizinkan berdasarkan token.
  Future<ScheduleSingleResponse> updateStatus({
    required String scheduleId,
    required String status,
  }) async {
    final token = await _requireToken();

    final response = await apiClient.dio.patch(
      '/schedules/$scheduleId/status',
      data: {'status': status},
      options: _authOptions(token),
    );

    return ScheduleSingleResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  // =========================================================================
  // POST /api/schedules/{schedule}/broadcast
  // =========================================================================

  /// Menyiarkan reminder jadwal ke jamaah.
  ///
  /// Deduplikasi notifikasi adalah tanggung jawab backend.
  /// Pencegahan klik ganda di UI hanya merupakan perlindungan tambahan.
  Future<BroadcastResponse> broadcastSchedule(String scheduleId) async {
    final token = await _requireToken();

    final response = await apiClient.dio.post(
      '/schedules/$scheduleId/broadcast',
      options: _authOptions(token),
    );

    return BroadcastResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
