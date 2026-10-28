import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../data/broadcast_repository.dart';

class BroadcastFormState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final BroadcastResult? lastResult;

  const BroadcastFormState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.lastResult,
  });

  BroadcastFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    BroadcastResult? lastResult,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return BroadcastFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      lastResult: lastResult ?? this.lastResult,
    );
  }
}

class BroadcastNotifier extends StateNotifier<BroadcastFormState> {
  final BroadcastRepository _repository;
  static const _uuid = Uuid();
  String _currentIdempotencyKey;

  BroadcastNotifier(this._repository)
      : _currentIdempotencyKey = _uuid.v4(),
        super(const BroadcastFormState());

  String get currentIdempotencyKey => _currentIdempotencyKey;

  void resetKey() {
    _currentIdempotencyKey = _uuid.v4();
  }

  Future<bool> sendBroadcast(CreateBroadcastPayload payload) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);

    try {
      final result = await _repository.createBroadcast(
        payload: payload,
        idempotencyKey: _currentIdempotencyKey,
      );

      // Siapkan idempotency key baru untuk siaran berikutnya setelah berhasil
      resetKey();

      state = state.copyWith(
        isLoading: false,
        successMessage: result.message,
        lastResult: result,
      );
      return true;
    } catch (e) {
      // Pertahankan idempotency key yang sama agar percobaan ulang operasi yang sama
      // akibat gangguan jaringan bersifat idempotent di backend
      String msg = e.toString().replaceFirst('Exception: ', '');
      if (e is DioException && e.response?.data is Map) {
        final data = e.response!.data as Map;
        if (data['message'] != null) {
          msg = data['message'].toString();
        }
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: msg,
      );
      return false;
    }
  }
}

final broadcastRepositoryProvider = Provider<BroadcastRepository>((ref) {
  return BroadcastRepository(
    apiClient: ApiClient(),
    secureStorage: SecureStorage(),
  );
});

final broadcastProvider =
    StateNotifierProvider<BroadcastNotifier, BroadcastFormState>((ref) {
  final repo = ref.watch(broadcastRepositoryProvider);
  return BroadcastNotifier(repo);
});
