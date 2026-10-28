class TourLeaderKloterModel {
  final String id;
  final String name;
  final String code;

  const TourLeaderKloterModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory TourLeaderKloterModel.fromJson(Map<String, dynamic> json) {
    return TourLeaderKloterModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
    );
  }
}

class TourLeaderAuthModel {
  final String id;
  final String loginId;
  final String fullName;
  final String? certificationNumber;
  final String? phone;
  final String status;
  final dynamic experience;
  final dynamic performance;
  final List<TourLeaderKloterModel> kloters;

  const TourLeaderAuthModel({
    required this.id,
    required this.loginId,
    required this.fullName,
    this.certificationNumber,
    this.phone,
    required this.status,
    this.experience,
    this.performance,
    this.kloters = const [],
  });

  factory TourLeaderAuthModel.fromJson(Map<String, dynamic> json) {
    var rawKloters = json['kloters'];
    List<TourLeaderKloterModel> parsedKloters = [];
    if (rawKloters is List) {
      parsedKloters = rawKloters
          .whereType<Map<String, dynamic>>()
          .map((k) => TourLeaderKloterModel.fromJson(k))
          .toList();
    }

    return TourLeaderAuthModel(
      id: json['id'] as String,
      loginId: json['login_id'] as String,
      fullName: json['full_name'] as String,
      certificationNumber: json['certification_number'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String,
      experience: json['experience'],
      performance: json['performance'],
      kloters: parsedKloters,
    );
  }
}
