import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../data/notification_repository.dart';
import '../domain/notification_model.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? errorMessage;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository? _repository;

  NotificationNotifier([this._repository, bool autoFetch = false])
      : super(const NotificationState()) {
    if (_repository != null && autoFetch) {
      fetchNotifications();
    }
  }

  Future<void> fetchNotifications() async {
    if (_repository == null) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final res = await _repository.getNotifications();
      final dataField = res['data'];

      List<dynamic> listRaw = [];
      if (dataField is Map && dataField['data'] is List) {
        listRaw = dataField['data'] as List;
      } else if (dataField is List) {
        listRaw = dataField;
      }

      final parsed = listRaw
          .whereType<Map<String, dynamic>>()
          .map((item) => NotificationModel.fromJson(item))
          .toList();

      // Gunakan merge agar notifikasi lokal sementara tidak hilang
      _mergeBackendNotifications(parsed);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat notifikasi: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }

  Future<void> markAsRead(String id) async {
    // Optimistic update
    final previous = state.notifications;
    final updated = previous.map((item) {
      if (item.id == id) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();

    state = state.copyWith(notifications: updated);

    if (_repository != null) {
      try {
        await _repository.markAsRead(id);
      } catch (_) {
        // Rollback jika gagal
        state = state.copyWith(notifications: previous);
      }
    }
  }

  void addNotificationIfAbsent(NotificationModel item) {
    // Guard: jangan tambahkan jika id kosong (fallback FCM messageId yang tidak stabil)
    if (item.id.isEmpty) return;

    // Cegah duplikasi berdasarkan ID yang stabil
    final exists = state.notifications.any((n) => n.id == item.id);
    if (!exists) {
      state = state.copyWith(
        notifications: [item, ...state.notifications],
      );
    }
  }

  /// Gabungkan hasil fetch backend ke state yang sudah ada.
  /// Notifikasi lokal (optimistic dari FCM) dipertahankan jika belum ada
  /// di backend (job masih pending), sehingga UI tidak kosong sesaat.
  void _mergeBackendNotifications(List<NotificationModel> fetched) {
    final existingIds = fetched.map((n) => n.id).toSet();
    // Pertahankan notifikasi lokal yang belum ada di backend
    final localOnly = state.notifications
        .where((n) => !existingIds.contains(n.id))
        .toList();
    // Backend menjadi sumber kebenaran; lokal hanya sebagai pelengkap sementara
    state = state.copyWith(
      notifications: [...fetched, ...localOnly],
      isLoading: false,
      clearError: true,
    );
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(
    apiClient: ApiClient(),
    secureStorage: SecureStorage(),
  );
});

final notificationNotifierProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repo, true);
});

final notificationProvider = Provider<List<NotificationModel>>((ref) {
  return ref.watch(notificationNotifierProvider).notifications;
});
