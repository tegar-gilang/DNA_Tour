enum UserRole {
  pilgrim,
  family,
  tourLeader;

  String get displayName {
    switch (this) {
      case UserRole.pilgrim:
        return 'Jamaah Umrah';
      case UserRole.family:
        return 'Keluarga Pemantau';
      case UserRole.tourLeader:
        return 'Pembimbing (Mutawif)';
    }
  }

  String get displayNameID {
    switch (this) {
      case UserRole.pilgrim:
        return 'Jamaah Umrah';
      case UserRole.family:
        return 'Keluarga Pemantau';
      case UserRole.tourLeader:
        return 'Pembimbing (Mutawif)';
    }
  }

  String get description {
    switch (this) {
      case UserRole.pilgrim:
        return 'Saya peserta ibadah Umrah yang sedang menjalankan ibadah di Tanah Suci.';
      case UserRole.family:
        return 'Saya ingin memantau dan memastikan keamanan keluarga dari tanah air.';
      case UserRole.tourLeader:
        return 'Saya pembimbing, mutawif, atau pengelola kloter jamaah Umrah.';
    }
  }

  String get descriptionID {
    switch (this) {
      case UserRole.pilgrim:
        return 'Saya peserta ibadah Umrah yang sedang menjalankan ibadah di Tanah Suci.';
      case UserRole.family:
        return 'Saya ingin memantau dan memastikan keamanan keluarga dari tanah air.';
      case UserRole.tourLeader:
        return 'Saya pembimbing, mutawif, atau pengelola kloter jamaah Umrah.';
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String avatarUrl;
  final String passportNumber;
  final String visaNumber;
  final String groupCode;
  final String hotelName;
  final String busNumber;
  final int batteryLevel;
  final bool isOnline;
  final String? linkedPilgrimId;
  final String phone;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarUrl,
    required this.passportNumber,
    required this.visaNumber,
    required this.groupCode,
    required this.hotelName,
    required this.busNumber,
    this.batteryLevel = 88,
    this.isOnline = true,
    this.linkedPilgrimId,
    required this.phone,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? avatarUrl,
    String? passportNumber,
    String? visaNumber,
    String? groupCode,
    String? hotelName,
    String? busNumber,
    int? batteryLevel,
    bool? isOnline,
    String? linkedPilgrimId,
    String? phone,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      passportNumber: passportNumber ?? this.passportNumber,
      visaNumber: visaNumber ?? this.visaNumber,
      groupCode: groupCode ?? this.groupCode,
      hotelName: hotelName ?? this.hotelName,
      busNumber: busNumber ?? this.busNumber,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isOnline: isOnline ?? this.isOnline,
      linkedPilgrimId: linkedPilgrimId ?? this.linkedPilgrimId,
      phone: phone ?? this.phone,
    );
  }

  // Pre-configured demo users for rapid role verification
  static const UserModel demoPilgrim = UserModel(
    id: 'PL-88210',
    name: 'H. Ahmad Zaki Al-Farizi',
    email: 'ahmad.zaki@email.com',
    role: UserRole.pilgrim,
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    passportNumber: 'A9284192B',
    visaNumber: 'VS-2026-9921',
    groupCode: 'Kloter 4 Al-Barakah',
    hotelName: 'Swissôtel Al Maqam Makkah',
    busNumber: 'Bus #08 Al-Safwa',
    batteryLevel: 86,
    phone: '+62 812-3456-7890',
  );

  static const UserModel demoFamily = UserModel(
    id: 'FM-10294',
    name: 'Siti Rahma Al-Farizi',
    email: 'siti.rahma@email.com',
    role: UserRole.family,
    avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
    passportNumber: 'C1029384E',
    visaNumber: 'N/A',
    groupCode: 'Kloter 4 Al-Barakah',
    hotelName: 'Swissôtel Al Maqam Makkah',
    busNumber: 'Bus #08 Al-Safwa',
    batteryLevel: 94,
    linkedPilgrimId: 'PL-88210',
    phone: '+62 813-9876-5432',
  );

  static const UserModel demoTourLeader = UserModel(
    id: 'TL-55012',
    name: 'Ust. H. Muhammad Ridwan, Lc.',
    email: 'ridwan.muthawif@email.com',
    role: UserRole.tourLeader,
    avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
    passportNumber: 'TL9910283',
    visaNumber: 'VS-2026-1002',
    groupCode: 'Kloter 4 Al-Barakah (45 Pilgrims)',
    hotelName: 'Swissôtel Al Maqam Makkah',
    busNumber: 'Bus #08 Al-Safwa',
    batteryLevel: 91,
    phone: '+966 50 123 4567',
  );
}
