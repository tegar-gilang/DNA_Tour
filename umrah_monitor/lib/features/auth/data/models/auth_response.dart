import 'jamaah_model.dart';

class LoginResponse {
  final String message;
  final String token;
  final JamaahModel jamaah;

  const LoginResponse({
    required this.message,
    required this.token,
    required this.jamaah,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] as String,
      token: json['token'] as String,
      jamaah: JamaahModel.fromJson(json['jamaah'] as Map<String, dynamic>),
    );
  }
}

class MeResponse {
  final JamaahModel jamaah;

  const MeResponse({required this.jamaah});

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    return MeResponse(
      jamaah: JamaahModel.fromJson(json['jamaah'] as Map<String, dynamic>),
    );
  }
}
