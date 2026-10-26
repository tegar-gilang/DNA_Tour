import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tour_leader/data/schedule_repository.dart';
import '../../tour_leader/domain/schedule_model.dart';
import '../../tour_leader/presentation/schedule_provider.dart';

/// State read-only untuk tampilan Timeline Jamaah dan Family.
///
/// Menyediakan list jadwal, status loading, error message,
/// dan fungsi fetch/refresh tanpa ada fungsi mutasi data.
class TimelineState {
  final List<ScheduleModel> schedules;
  final bool isLoading;
  final String? errorMessage;
  final int? statusCode;

  const TimelineState({
    this.schedules = const [],
    this.isLoading = false,
    this.errorMessage,
    this.statusCode,
  });

  TimelineState copyWith({
    List<ScheduleModel>? schedules,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    int? statusCode,
  }) {
    return TimelineState(
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      statusCode: clearError ? null : (statusCode ?? this.statusCode),
    );
  }
}

/// Notifier read-only untuk Timeline Jamaah dan Family.
class TimelineNotifier extends StateNotifier<TimelineState> {
  final ScheduleRepository _repository;

  TimelineNotifier(this._repository) : super(const TimelineState());

  /// Mengambil daftar jadwal dari backend.
  Future<void> fetchSchedules() async {
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
      final code = e.response?.statusCode;
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapDioError(e),
        statusCode: code,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Refresh data terbaru (digunakan oleh Pull-to-Refresh).
  Future<void> refresh() async {
    try {
      final result = await _repository.getSchedules();
      state = state.copyWith(
        schedules: result.schedules,
        isLoading: false,
        clearError: true,
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapDioError(e),
        statusCode: code,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Koneksi ke server gagal. Periksa jaringan Anda.';
    }

    final statusCode = e.response?.statusCode;
    if (statusCode == 401) {
      return 'Sesi Anda telah berakhir. Silakan login kembali.';
    }
    if (statusCode == 403) {
      return 'Akses ditolak. Anda tidak memiliki izin untuk melihat jadwal ini.';
    }
    if (statusCode == 404) {
      return 'Jadwal tidak ditemukan.';
    }

    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic> &&
        responseData['message'] is String) {
      return responseData['message'] as String;
    }

    return 'Terjadi kesalahan saat memuat jadwal. Coba lagi beberapa saat.';
  }
}

/// Provider read-only Timeline untuk Jamaah dan Family.
final timelineProvider =
    StateNotifierProvider<TimelineNotifier, TimelineState>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return TimelineNotifier(repository);
});

// =============================================================================
// DETAIL JADWAL STATE & PROVIDER (READ-ONLY)
// =============================================================================

class ScheduleDetailState {
  final ScheduleModel? schedule;
  final bool isLoading;
  final String? errorMessage;
  final int? statusCode;

  const ScheduleDetailState({
    this.schedule,
    this.isLoading = false,
    this.errorMessage,
    this.statusCode,
  });

  ScheduleDetailState copyWith({
    ScheduleModel? schedule,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    int? statusCode,
  }) {
    return ScheduleDetailState(
      schedule: schedule ?? this.schedule,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      statusCode: clearError ? null : (statusCode ?? this.statusCode),
    );
  }
}

class ScheduleDetailNotifier extends StateNotifier<ScheduleDetailState> {
  final ScheduleRepository _repository;

  ScheduleDetailNotifier(this._repository) : super(const ScheduleDetailState());

  /// Mengambil detail jadwal spesifik berdasarkan [scheduleId].
  ///
  /// Jika [cached] disertakan, ia akan langsung digunakan sementara
  /// API mengambil data paling mutakhir dari backend.
  Future<void> fetchDetail(String scheduleId, {ScheduleModel? cached}) async {
    state = state.copyWith(
      schedule: cached ?? state.schedule,
      isLoading: true,
      clearError: true,
    );

    try {
      final response = await _repository.getScheduleDetail(scheduleId);
      state = state.copyWith(
        schedule: response.schedule,
        isLoading: false,
        clearError: true,
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapDioError(e),
        statusCode: code,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  String _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return 'Koneksi ke server gagal. Periksa jaringan Anda.';
    }

    final statusCode = e.response?.statusCode;
    if (statusCode == 401) {
      return 'Sesi Anda telah berakhir. Silakan login kembali.';
    }
    if (statusCode == 403) {
      return 'Akses ditolak. Anda tidak memiliki izin untuk melihat detail jadwal ini.';
    }
    if (statusCode == 404) {
      return 'Detail jadwal tidak ditemukan di server.';
    }

    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic> &&
        responseData['message'] is String) {
      return responseData['message'] as String;
    }

    return 'Terjadi kesalahan saat memuat detail jadwal.';
  }
}

final scheduleDetailProvider =
    StateNotifierProvider<ScheduleDetailNotifier, ScheduleDetailState>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return ScheduleDetailNotifier(repository);
});
