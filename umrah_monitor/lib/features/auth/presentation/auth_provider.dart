import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:umrah_monitor/features/auth/data/auth_repository.dart';
import 'package:umrah_monitor/features/auth/data/models/jamaah_model.dart';
import 'package:umrah_monitor/features/auth/data/models/tour_leader_model.dart';
import 'package:umrah_monitor/features/auth/domain/user_model.dart';
import 'package:umrah_monitor/core/network/api_client.dart';
import 'package:umrah_monitor/core/storage/secure_storage.dart';
import 'package:umrah_monitor/core/services/firebase_messaging_service.dart';

class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  final JamaahModel? jamaah;
  final TourLeaderAuthModel? tourLeader;
  final UserRole? selectedRole;
  final bool isLoading;
  final bool isSessionRestored;
  final bool isBiometricEnabled;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.jamaah,
    this.tourLeader,
    this.selectedRole,
    this.isLoading = false,
    this.isSessionRestored = false,
    this.isBiometricEnabled = true,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    bool clearUser = false,
    JamaahModel? jamaah,
    bool clearJamaah = false,
    TourLeaderAuthModel? tourLeader,
    bool clearTourLeader = false,
    UserRole? selectedRole,
    bool? isLoading,
    bool? isSessionRestored,
    bool? isBiometricEnabled,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: clearUser ? null : (user ?? this.user),
      jamaah: clearJamaah ? null : (jamaah ?? this.jamaah),
      tourLeader: clearTourLeader ? null : (tourLeader ?? this.tourLeader),
      selectedRole: selectedRole ?? this.selectedRole,
      isLoading: isLoading ?? this.isLoading,
      isSessionRestored: isSessionRestored ?? this.isSessionRestored,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;

  AuthNotifier({required this.authRepository}) : super(const AuthState());

  void selectRole(UserRole role) {
    state = state.copyWith(selectedRole: role, errorMessage: null);
  }

  /// Memulihkan sesi pengguna saat aplikasi dimulai (Splash Screen)
  Future<void> restoreSession() async {
    final token = await authRepository.secureStorage.getToken();
    if (token == null || token.isEmpty) {
      state = state.copyWith(isSessionRestored: true);
      return;
    }

    final storedRole = await authRepository.secureStorage.getRole();

    try {
      if (storedRole == 'tour_leader') {
        try {
          final tlResponse = await authRepository.getTourLeaderMe();
          state = state.copyWith(
            isAuthenticated: true,
            tourLeader: tlResponse.tourLeader,
            selectedRole: UserRole.tourLeader,
            clearJamaah: true,
            clearUser: true,
            isSessionRestored: true,
            errorMessage: null,
          );
          return;
        } on DioException catch (e) {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionError) {
            // Gangguan jaringan: jangan hapus token, tandai belum terautentikasi di memori sementara
            state = state.copyWith(isSessionRestored: true);
            return;
          }
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            await authRepository.secureStorage.deleteToken();
            state = state.copyWith(
              isAuthenticated: false,
              clearTourLeader: true,
              clearJamaah: true,
              clearUser: true,
              isSessionRestored: true,
            );
            return;
          }
        }
      } else if (storedRole == 'family') {
        try {
          final familyResponse = await authRepository.getFamilyMe();
          state = state.copyWith(
            isAuthenticated: true,
            jamaah: familyResponse.jamaah,
            selectedRole: UserRole.family,
            clearTourLeader: true,
            clearUser: true,
            isSessionRestored: true,
            errorMessage: null,
          );
          return;
        } on DioException catch (e) {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionError) {
            state = state.copyWith(isSessionRestored: true);
            return;
          }
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            await authRepository.secureStorage.deleteToken();
            state = state.copyWith(
              isAuthenticated: false,
              clearTourLeader: true,
              clearJamaah: true,
              clearUser: true,
              isSessionRestored: true,
            );
            return;
          }
        }
      } else {
        // Default / 'pilgrim'
        try {
          final jamaahResponse = await authRepository.getJamaahMe();
          state = state.copyWith(
            isAuthenticated: true,
            jamaah: jamaahResponse.jamaah,
            selectedRole: UserRole.pilgrim,
            clearTourLeader: true,
            clearUser: true,
            isSessionRestored: true,
            errorMessage: null,
          );
          return;
        } on DioException catch (e) {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionError) {
            state = state.copyWith(isSessionRestored: true);
            return;
          }
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            await authRepository.secureStorage.deleteToken();
            state = state.copyWith(
              isAuthenticated: false,
              clearTourLeader: true,
              clearJamaah: true,
              clearUser: true,
              isSessionRestored: true,
            );
            return;
          }
        }
      }

      state = state.copyWith(isSessionRestored: true);
    } catch (_) {
      state = state.copyWith(isSessionRestored: true);
    }
  }

  Future<void> _registerFcmTokenSafely() async {
    try {
      final messagingService = FirebaseMessagingService();
      final fcmToken = await messagingService.getToken();

      if (fcmToken == null || fcmToken.isEmpty) {
        print('FCM token belum tersedia.');
        return;
      }

      await authRepository.registerDeviceToken(
        fcmToken: fcmToken,
        platform: Platform.isIOS ? 'ios' : 'android',
      );

      print('Registrasi FCM token berhasil.');
    } catch (e) {
      // Kegagalan FCM tidak boleh menggagalkan login.
      print('Registrasi FCM belum berhasil: $e');
    }
  }

  Future<void> login({required String id}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final role = state.selectedRole ?? UserRole.pilgrim;

      // ==========================================
      // JAMAAH LOGIN
      // ==========================================
      if (role == UserRole.pilgrim) {
        final response = await authRepository.loginJamaah(id);
        await _registerFcmTokenSafely();

        state = state.copyWith(
          isAuthenticated: true,
          jamaah: response.jamaah,
          clearTourLeader: true,
          clearUser: true,
          selectedRole: UserRole.pilgrim,
          isLoading: false,
          errorMessage: null,
        );
      }
      // ==========================================
      // FAMILY LOGIN
      // ==========================================
      else if (role == UserRole.family) {
        final response = await authRepository.loginFamily(id);
        await _registerFcmTokenSafely();

        state = state.copyWith(
          isAuthenticated: true,
          jamaah: response.jamaah,
          clearTourLeader: true,
          clearUser: true,
          selectedRole: UserRole.family,
          isLoading: false,
          errorMessage: null,
        );
      }
      // ==========================================
      // TOUR LEADER LOGIN
      // ==========================================
      else if (role == UserRole.tourLeader) {
        final response = await authRepository.loginTourLeader(id);
        // Backend POST /device-tokens terverifikasi mendukung ability 'tour_leader'
        await _registerFcmTokenSafely();

        state = state.copyWith(
          isAuthenticated: true,
          tourLeader: response.tourLeader,
          clearJamaah: true,
          clearUser: true,
          selectedRole: UserRole.tourLeader,
          isLoading: false,
          errorMessage: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        clearJamaah: true,
        clearTourLeader: true,
        clearUser: true,
        isLoading: false,
        errorMessage: _getErrorMessage(e, state.selectedRole),
      );
    }
  }

  Future<void> loginWithBiometrics() async {
    state = state.copyWith(
      isLoading: false,
      errorMessage: 'Login biometrik belum terhubung ke backend.',
    );
  }

  void switchRoleDirect(UserRole targetRole) {
    state = state.copyWith(
      isAuthenticated: false,
      selectedRole: targetRole,
      clearJamaah: true,
      clearTourLeader: true,
      clearUser: true,
      errorMessage: null,
    );
  }

  Future<void> logout() async {
    final activeRole = state.selectedRole;
    final isTourLeader = activeRole == UserRole.tourLeader || state.tourLeader != null;
    try {
      if (isTourLeader) {
        await authRepository.logoutTourLeader();
      } else {
        await authRepository.logout();
      }
    } catch (_) {
      // Token tetap akan dihapus di authRepository (finally block).
    } finally {
      await authRepository.secureStorage.deleteToken();
    }

    state = const AuthState(isSessionRestored: true);
  }

  String _getErrorMessage(Object error, UserRole? role) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Koneksi ke server gagal. Periksa jaringan Anda.';
      }
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic> && responseData['message'] is String) {
        return responseData['message'] as String;
      }
      if (error.response?.statusCode == 401) {
        if (role == UserRole.tourLeader) {
          return 'Tour Leader tidak ditemukan atau status akun tidak aktif.';
        }
        return 'ID tidak ditemukan atau akun tidak aktif.';
      }
    }
    if (role == UserRole.tourLeader) {
      return 'Login gagal. Periksa ID Tour Leader dan koneksi ke server.';
    }
    return 'Login gagal. Periksa ID dan koneksi ke server.';
  }
}

// ======================================================
// AUTH REPOSITORY PROVIDER
// ======================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(apiClient: ApiClient(), secureStorage: SecureStorage());
});

// ======================================================
// AUTH PROVIDER
// ======================================================

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(authRepository: ref.read(authRepositoryProvider));
});
