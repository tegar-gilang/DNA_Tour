import 'package:dio/dio.dart';

class ApiClient {
  late final Dio dio;

  /// [baseUrl] defaults to the Android Emulator loopback address.
  /// Override for integration tests running on Windows/desktop.
  ///
  /// [customDio] allows injecting a pre-configured [Dio] instance.
  /// When provided, [baseUrl] is ignored.
  /// This makes the class testable without altering production behaviour.
  ApiClient({String? baseUrl, Dio? customDio}) {
    if (customDio != null) {
      dio = customDio;
    } else {
      dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? 'http://10.0.2.2:8000/api',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
    }
  }
}
