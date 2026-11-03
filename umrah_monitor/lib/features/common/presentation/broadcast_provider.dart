import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/broadcast_repository.dart';
import '../../../core/providers/api_providers.dart';
import '../domain/broadcast_model.dart';

enum BroadcastStatus { idle, loading, success, empty, error }

class BroadcastState {
  final BroadcastStatus status;
  final List<Broadcast> items;
  final String? errorMessage;

  const BroadcastState({
    this.status = BroadcastStatus.idle,
    this.items = const [],
    this.errorMessage,
  });

  BroadcastState copyWith({
    BroadcastStatus? status,
    List<Broadcast>? items,
    String? errorMessage,
  }) {
    return BroadcastState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }
}

class BroadcastNotifier extends StateNotifier<BroadcastState> {
  final BroadcastRepository _repository;

  BroadcastNotifier(this._repository) : super(const BroadcastState());

  Future<void> load() async {
    state = state.copyWith(status: BroadcastStatus.loading);
    try {
      final data = await _repository.getBroadcasts();
      if (data.isEmpty) {
        state = state.copyWith(status: BroadcastStatus.empty);
      } else {
        state = state.copyWith(status: BroadcastStatus.success, items: data);
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final serverMessage = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] as String?)
          : null;

      String message;
      if (statusCode == 403) {
        message = serverMessage ??
            'Akses pengumuman keluarga belum aktif. Silakan hubungi admin travel.';
      } else if (statusCode == 401) {
        message = 'Sesi tidak valid. Silakan login kembali.';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        message = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      } else {
        message = serverMessage ?? 'Gagal memuat pengumuman. Silakan coba beberapa saat lagi.';
      }

      state = state.copyWith(status: BroadcastStatus.error, errorMessage: message);
    } catch (e) {
      final text = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      state = state.copyWith(status: BroadcastStatus.error, errorMessage: text);
    }
  }

  Future<void> refresh() async => load();
}

final broadcastRepositoryProvider = Provider<BroadcastRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return BroadcastRepository(apiClient: apiClient, secureStorage: secureStorage);
});

final broadcastProvider = StateNotifierProvider<BroadcastNotifier, BroadcastState>((ref) {
  final repository = ref.watch(broadcastRepositoryProvider);
  return BroadcastNotifier(repository);
});
