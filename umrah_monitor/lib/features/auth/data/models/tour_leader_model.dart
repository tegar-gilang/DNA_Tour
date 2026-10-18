class TourLeaderAuthModel {
  final String id;
  final String loginId;
  final String fullName;
  final String? certificationNumber;
  final String? phone;
  final String status;
  final dynamic experience;
  final dynamic performance;

  const TourLeaderAuthModel({
    required this.id,
    required this.loginId,
    required this.fullName,
    this.certificationNumber,
    this.phone,
    required this.status,
    this.experience,
    this.performance,
  });

  factory TourLeaderAuthModel.fromJson(Map<String, dynamic> json) {
    return TourLeaderAuthModel(
      id: json['id'] as String,
      loginId: json['login_id'] as String,
      fullName: json['full_name'] as String,
      certificationNumber: json['certification_number'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String,
      experience: json['experience'],
      performance: json['performance'],
    );
  }
}
