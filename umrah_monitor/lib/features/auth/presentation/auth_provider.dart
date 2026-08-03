import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:umrah_monitor/features/auth/domain/user_model.dart';

class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  final UserRole? selectedRole;
  final bool isLoading;
  final bool isBiometricEnabled;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.selectedRole,
    this.isLoading = false,
    this.isBiometricEnabled = true,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    UserRole? selectedRole,
    bool? isLoading,
    bool? isBiometricEnabled,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      selectedRole: selectedRole ?? this.selectedRole,
      isLoading: isLoading ?? this.isLoading,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void selectRole(UserRole role) {
    state = state.copyWith(selectedRole: role, errorMessage: null);
  }

  Future<void> login({required String id}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 600));

    final role = state.selectedRole ?? UserRole.pilgrim;
    UserModel loggedUser;
    switch (role) {
      case UserRole.pilgrim:
        loggedUser = UserModel.demoPilgrim;
        break;
      case UserRole.family:
        loggedUser = UserModel.demoFamily;
        break;
      case UserRole.tourLeader:
        loggedUser = UserModel.demoTourLeader;
        break;
    }

    state = state.copyWith(
      isAuthenticated: true,
      user: loggedUser,
      isLoading: false,
    );
  }

  Future<void> loginWithBiometrics() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 400));

    final role = state.selectedRole ?? UserRole.pilgrim;
    UserModel loggedUser;
    switch (role) {
      case UserRole.pilgrim:
        loggedUser = UserModel.demoPilgrim;
        break;
      case UserRole.family:
        loggedUser = UserModel.demoFamily;
        break;
      case UserRole.tourLeader:
        loggedUser = UserModel.demoTourLeader;
        break;
    }

    state = state.copyWith(
      isAuthenticated: true,
      user: loggedUser,
      isLoading: false,
    );
  }

  void switchRoleDirect(UserRole targetRole) {
    UserModel targetUser;
    switch (targetRole) {
      case UserRole.pilgrim:
        targetUser = UserModel.demoPilgrim;
        break;
      case UserRole.family:
        targetUser = UserModel.demoFamily;
        break;
      case UserRole.tourLeader:
        targetUser = UserModel.demoTourLeader;
        break;
    }
    state = state.copyWith(
      isAuthenticated: true,
      selectedRole: targetRole,
      user: targetUser,
    );
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
