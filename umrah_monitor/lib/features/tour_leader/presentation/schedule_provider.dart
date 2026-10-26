import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../data/schedule_repository.dart';
import '../domain/schedule_model.dart';

// =============================================================================
// STATE
// =============================================================================

/// State untuk seluruh fitur Timeline Tour Leader.
class ScheduleState {
  final List<ScheduleModel> schedules;
  final bool isLoading;

  /// Pesan error dari pengambilan daftar jadwal; null jika tidak ada error.
  final String? errorMessage;

  /// ID jadwal yang sedang dalam proses update status (null = tidak ada).
  final String? updatingStatusId;

  /// ID jadwal yang sedang dalam proses broadcast (null = tidak ada).
  final String? broadcastingId;

  /// Apakah form tambah jadwal sedang disubmit.
  final bool isSubmitting;

  const ScheduleState({
    this.schedules = const [],
    this.isLoading = false,
    this.errorMessage,
    this.updatingStatusId,
    this.broadcastingId,
    this.isSubmitting = false,
  });

  ScheduleState copyWith({
    List<ScheduleModel>? schedules,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? updatingStatusId,
    bool clearUpdatingStatusId = false,
    String? broadcastingId,
    bool clearBroadcastingId = false,
    bool? isSubmitting,
  }) {
    return ScheduleState(
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      updatingStatusId: clearUpdatingStatusId
          ? null
          : (updatingStatusId ?? this.updatingStatusId),
      broadcastingId: clearBroadcastingId
          ? null
          : (broadcastingId ?? this.broadcastingId),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

// =============================================================================
// NOTIFIER
// =============================================================================

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  final ScheduleRepository _repository;

  ScheduleNotifier(this._repository) : super(const ScheduleState());

  // ---------------------------------------------------------------------------
  // Fetch jadwal dari API
  // ---------------------------------------------------------------------------

  Future<void> fetchSchedules() async {
    // Cegah fetch berulang saat masih loading
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.getSchedules();
      state = state.copyWith(
        schedules: result.schedules,
        isLoading: false,
        clearError: true,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapDioError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Tambah jadwal baru
  // ---------------------------------------------------------------------------

  /// Mengirim jadwal baru ke backend.
  ///
  /// Mengembalikan [ScheduleModel] hasil respons backend jika berhasil,
  /// atau null jika gagal.  Pesan error disimpan di state.
  Future<ScheduleModel?> createSchedule(Map<String, dynamic> payload) async {
    if (state.isSubmitting) return null;

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final result = await _repository.createSchedule(payload);
      // Tambahkan jadwal baru ke awal list dan reload dari backend
      state = state.copyWith(
        schedules: [result.schedule, ...state.schedules],
        isSubmitting: false,
        clearError: true,
      );
      return result.schedule;
    } on DioException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _mapDioError(e),
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Update status pelaksanaan
  // ---------------------------------------------------------------------------

  /// Mengubah status pelaksanaan jadwal [scheduleId] menjadi [newStatus].
  ///
  /// Backend adalah sumber kebenaran; state lokal hanya diperbarui
  /// setelah backend mengonfirmasi perubahan.
  Future<bool> updateStatus({
    required String scheduleId,
    required String newStatus,
  }) async {
    // Cegah request ganda pada jadwal yang sama
    if (state.updatingStatusId == scheduleId) return false;

    state = state.copyWith(updatingStatusId: scheduleId, clearError: true);

    try {
      final result = await _repository.updateStatus(
        scheduleId: scheduleId,
        status: newStatus,
      );

      // Perbarui item di list berdasarkan respons backend
      final updated = state.schedules.map((s) {
        if (s.id == scheduleId) return result.schedule;
        return s;
      }).toList();

      state = state.copyWith(
        schedules: updated,
        clearUpdatingStatusId: true,
        clearError: true,
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        clearUpdatingStatusId: true,
        errorMessage: _mapDioError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        clearUpdatingStatusId: true,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Broadcast reminder
  // ---------------------------------------------------------------------------

  /// Menyiarkan reminder untuk jadwal [scheduleId].
  ///
  /// Mengembalikan [BroadcastResponse] jika berhasil, atau null jika gagal.
  Future<BroadcastResponse?> broadcastSchedule(String scheduleId) async {
    if (state.broadcastingId == scheduleId) return null;

    state = state.copyWith(broadcastingId: scheduleId, clearError: true);

    try {
      final result = await _repository.broadcastSchedule(scheduleId);

      // Perbarui reminderStatus di item lokal berdasarkan respons backend
      if (result.reminderStatus != null) {
        final updated = state.schedules.map((s) {
          if (s.id == scheduleId) {
            return s.copyWith(
              reminderStatus: result.reminderStatus,
              broadcastedAt: result.broadcastedAt,
            );
          }
          return s;
        }).toList();
        state = state.copyWith(
          schedules: updated,
          clearBroadcastingId: true,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          clearBroadcastingId: true,
          clearError: true,
        );
        // Reload untuk mendapatkan state terbaru dari backend
        await fetchSchedules();
      }

      return result;
    } on DioException catch (e) {
      state = state.copyWith(
        clearBroadcastingId: true,
        errorMessage: _mapDioError(e),
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        clearBroadcastingId: true,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Clear error
  // ---------------------------------------------------------------------------

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // ---------------------------------------------------------------------------
  // Helper: pemetaan DioException ke pesan yang bisa ditampilkan pengguna
  // ---------------------------------------------------------------------------

  String _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Koneksi ke server gagal. Periksa jaringan Anda.';
    }

    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic> &&
        responseData['message'] is String) {
      return responseData['message'] as String;
    }

    final statusCode = e.response?.statusCode;
    if (statusCode == 401) {
      return 'Sesi Anda telah berakhir. Silakan login kembali.';
    }
    if (statusCode == 403) {
      return 'Akses ditolak. Anda tidak memiliki izin untuk melihat jadwal ini.';
    }
    if (statusCode == 422) {
      return 'Data yang dikirim tidak valid. Periksa kembali isian Anda.';
    }
    if (statusCode == 404) {
      return 'Jadwal tidak ditemukan.';
    }

    return 'Terjadi kesalahan. Coba lagi beberapa saat.';
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(
    apiClient: ApiClient(),
    secureStorage: SecureStorage(),
  );
});

final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return ScheduleNotifier(repository);
});
