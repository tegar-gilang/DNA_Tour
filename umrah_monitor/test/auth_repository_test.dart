import 'package:flutter_test/flutter_test.dart';

import 'package:umrah_monitor/core/network/api_client.dart';
import 'package:umrah_monitor/core/storage/secure_storage.dart';
import 'package:umrah_monitor/features/auth/data/auth_repository.dart';

void main() {
  test('Login Jamaah menggunakan API Laravel', () async {
    final apiClient = ApiClient();
    final secureStorage = SecureStorage();

    final repository = AuthRepository(
      apiClient: apiClient,
      secureStorage: secureStorage,
    );

    final result = await repository.loginJamaah('JAMAAH001');

    print('MESSAGE: ${result.message}');
    print('TOKEN: ${result.token}');
    print('JAMAAH ID: ${result.jamaah.id}');
    print('LOGIN ID: ${result.jamaah.loginId}');
    print('NAMA: ${result.jamaah.fullName}');

    expect(result.token, isNotEmpty);
    expect(result.jamaah.loginId, 'JAMAAH001');
  });
}
