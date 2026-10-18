import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import 'models/auth_response.dart';

class AuthRepository {
  final ApiClient apiClient;
  final SecureStorage secureStorage;

  AuthRepository({required this.apiClient, required this.secureStorage});

  Future<LoginResponse> loginJamaah(String loginId) async {
    final response = await apiClient.dio.post(
      '/jamaah/login',
      data: {'login_id': loginId},
    );

    final loginResponse = LoginResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    await secureStorage.saveToken(loginResponse.token);
    await secureStorage.saveRole('pilgrim');

    return loginResponse;
  }

  Future<LoginResponse> loginFamily(String loginId) async {
    final response = await apiClient.dio.post(
      '/family/login',
      data: {'login_id': loginId},
    );

    final loginResponse = LoginResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    await secureStorage.saveToken(loginResponse.token);
    await secureStorage.saveRole('family');

    return loginResponse;
  }

  Future<MeResponse> getJamaahMe() async {
    final token = await secureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan.');
    }

    final response = await apiClient.dio.get(
      '/jamaah/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return MeResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<MeResponse> getFamilyMe() async {
    final token = await secureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan.');
    }

    final response = await apiClient.dio.get(
      '/family/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return MeResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TourLeaderLoginResponse> loginTourLeader(String loginId) async {
    final response = await apiClient.dio.post(
      '/tour-leader/login',
      data: {'login_id': loginId},
    );

    final loginResponse = TourLeaderLoginResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    await secureStorage.saveToken(loginResponse.token);
    await secureStorage.saveRole('tour_leader');

    return loginResponse;
  }

  Future<TourLeaderMeResponse> getTourLeaderMe() async {
    final token = await secureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan.');
    }

    final response = await apiClient.dio.get(
      '/tour-leader/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return TourLeaderMeResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logoutTourLeader() async {
    final token = await secureStorage.getToken();

    if (token != null && token.isNotEmpty) {
      try {
        await apiClient.dio.post(
          '/tour-leader/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } finally {
        await secureStorage.deleteToken();
      }
    } else {
      await secureStorage.deleteToken();
    }
  }


  Future<void> logout() async {
    final token = await secureStorage.getToken();

    if (token != null && token.isNotEmpty) {
      try {
        await apiClient.dio.post(
          '/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } finally {
        await secureStorage.deleteToken();
      }
    } else {
      await secureStorage.deleteToken();
    }
  }
}
