import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:umrah_monitor/features/auth/data/auth_repository.dart';
import 'package:umrah_monitor/features/auth/data/models/jamaah_model.dart';
import 'package:umrah_monitor/features/auth/domain/user_model.dart';
import 'package:umrah_monitor/core/network/api_client.dart';
import 'package:umrah_monitor/core/storage/secure_storage.dart';
import 'package:umrah_monitor/core/services/firebase_messaging_service.dart';

class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  final JamaahModel? jamaah;
  final UserRole? selectedRole;
  final bool isLoading;
  final bool isBiometricEnabled;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.jamaah,
    this.selectedRole,
    this.isLoading = false,
    this.isBiometricEnabled = true,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    JamaahModel? jamaah,
    UserRole? selectedRole,
    bool? isLoading,
    bool? isBiometricEnabled,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      jamaah: jamaah ?? this.jamaah,
      selectedRole: selectedRole ?? this.selectedRole,
      isLoading: isLoading ?? this.isLoading,
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
        platform: 'android',
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
      print('================ AUTH LOGIN ================');
      print('Login ID: $id');

      final role = state.selectedRole ?? UserRole.pilgrim;

      print('Selected Role: $role');

      // ==========================================
      // JAMAAH LOGIN
      // ==========================================
      if (role == UserRole.pilgrim) {
        print('Calling API: POST /jamaah/login');

        final response = await authRepository.loginJamaah(id);
        await _registerFcmTokenSafely();

        print('API LOGIN SUCCESS');
        print('Jamaah ID: ${response.jamaah.loginId}');
        print('Jamaah Name: ${response.jamaah.fullName}');

        state = state.copyWith(
          isAuthenticated: true,
          jamaah: response.jamaah,
          selectedRole: UserRole.pilgrim,
          isLoading: false,
          errorMessage: null,
        );

        print('AuthState jamaah berhasil diisi.');
      }
      // ==========================================
      // FAMILY LOGIN
      // ==========================================
      else if (role == UserRole.family) {
        print('Calling API: POST /family/login');

        final response = await authRepository.loginFamily(id);
        await _registerFcmTokenSafely();

        print('API LOGIN SUCCESS');
        print('Jamaah ID: ${response.jamaah.loginId}');
        print('Jamaah Name: ${response.jamaah.fullName}');

        state = state.copyWith(
          isAuthenticated: true,
          jamaah: response.jamaah,
          selectedRole: UserRole.family,
          isLoading: false,
          errorMessage: null,
        );

        print('AuthState jamaah berhasil diisi.');
      }
      // ==========================================
      // TOUR LEADER
      // ==========================================
      else {
        print('Tour Leader login belum tersedia.');

        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Login Tour Leader belum tersedia.',
        );
      }

      print('============================================');
    } catch (e) {
      print('================ AUTH LOGIN ERROR ================');
      print(e);
      print('===================================================');

      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        errorMessage: _getErrorMessage(e),
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
    if (targetRole == UserRole.tourLeader) {
      state = state.copyWith(
        isAuthenticated: false,
        selectedRole: targetRole,
        errorMessage: 'Login Tour Leader belum tersedia.',
      );

      return;
    }

    state = state.copyWith(
      isAuthenticated: false,
      selectedRole: targetRole,
      errorMessage: null,
    );
  }

  Future<void> logout() async {
    try {
      await authRepository.logout();
    } catch (_) {
      // Token tetap akan dihapus oleh AuthRepository.
    }

    state = const AuthState();
  }

  String _getErrorMessage(Object error) {
    return 'Login gagal. Periksa JAMAAH ID dan koneksi ke server.';
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
