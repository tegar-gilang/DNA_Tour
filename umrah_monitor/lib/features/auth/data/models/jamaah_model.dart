class JamaahModel {
  final String id;
  final String loginId;
  final String fullName;
  final String phone;
  final ProfileModel profile;
  final JourneyModel journey;

  const JamaahModel({
    required this.id,
    required this.loginId,
    required this.fullName,
    required this.phone,
    required this.profile,
    required this.journey,
  });

  factory JamaahModel.fromJson(Map<String, dynamic> json) {
    return JamaahModel(
      id: json['id'] as String,
      loginId: json['login_id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      profile: ProfileModel.fromJson(json['profile'] as Map<String, dynamic>),
      journey: JourneyModel.fromJson(json['journey'] as Map<String, dynamic>),
    );
  }
}

class ProfileModel {
  final String? birthDate;
  final String? gender;
  final String? nationality;
  final String? passportNumber;
  final String? visaNumber;

  const ProfileModel({
    this.birthDate,
    this.gender,
    this.nationality,
    this.passportNumber,
    this.visaNumber,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      birthDate: json['birth_date'] as String?,
      gender: json['gender'] as String?,
      nationality: json['nationality'] as String?,
      passportNumber: json['passport_number'] as String?,
      visaNumber: json['visa_number'] as String?,
    );
  }
}

class JourneyModel {
  final PackageModel? package;
  final KloterModel? kloter;
  final HotelModel? hotel;
  final TourLeaderModel? tourLeader;
  final MutawifModel? mutawif;

  const JourneyModel({
    this.package,
    this.kloter,
    this.hotel,
    this.tourLeader,
    this.mutawif,
  });

  factory JourneyModel.fromJson(Map<String, dynamic> json) {
    return JourneyModel(
      package: json['package'] != null
          ? PackageModel.fromJson(json['package'] as Map<String, dynamic>)
          : null,
      kloter: json['kloter'] != null
          ? KloterModel.fromJson(json['kloter'] as Map<String, dynamic>)
          : null,
      hotel: json['hotel'] != null
          ? HotelModel.fromJson(json['hotel'] as Map<String, dynamic>)
          : null,
      tourLeader: json['tour_leader'] != null
          ? TourLeaderModel.fromJson(
              json['tour_leader'] as Map<String, dynamic>,
            )
          : null,
      mutawif: json['mutawif'] != null
          ? MutawifModel.fromJson(json['mutawif'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PackageModel {
  final String id;
  final String name;
  final String category;

  const PackageModel({
    required this.id,
    required this.name,
    required this.category,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
    );
  }
}

class KloterModel {
  final String id;
  final String code;
  final String? departureDate;
  final String? returnDate;
  final String status;

  const KloterModel({
    required this.id,
    required this.code,
    this.departureDate,
    this.returnDate,
    required this.status,
  });

  factory KloterModel.fromJson(Map<String, dynamic> json) {
    return KloterModel(
      id: json['id'] as String,
      code: json['code'] as String,
      departureDate: json['departure_date'] as String?,
      returnDate: json['return_date'] as String?,
      status: json['status'] as String,
    );
  }
}

class HotelModel {
  final dynamic makkah;
  final dynamic madinah;

  const HotelModel({this.makkah, this.madinah});

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(makkah: json['makkah'], madinah: json['madinah']);
  }
}

class TourLeaderModel {
  final String id;
  final String fullName;
  final String phone;

  const TourLeaderModel({
    required this.id,
    required this.fullName,
    required this.phone,
  });

  factory TourLeaderModel.fromJson(Map<String, dynamic> json) {
    return TourLeaderModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
    );
  }
}

class MutawifModel {
  final String? id;
  final String? fullName;
  final String? phone;

  const MutawifModel({this.id, this.fullName, this.phone});

  factory MutawifModel.fromJson(Map<String, dynamic> json) {
    return MutawifModel(
      id: json['id'] as String?,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
    );
  }
}
