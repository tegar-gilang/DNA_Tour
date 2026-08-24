class PilgrimManagementModel {
  final String id;
  final String name;
  final String passportNumber;
  final String groupName;
  final String roomNumber;
  final String gender;
  final int age;
  final String phone;
  final String status; // 'Hadir', 'Dalam Perjalanan', 'Di Hotel', 'Perlu Perhatian'
  final String healthStatus; // 'Sehat', 'Kelelahan', 'Perlu Obat'
  final String avatarUrl;
  final String lastLocation;

  const PilgrimManagementModel({
    required this.id,
    required this.name,
    required this.passportNumber,
    required this.groupName,
    required this.roomNumber,
    required this.gender,
    required this.age,
    required this.phone,
    required this.status,
    required this.healthStatus,
    required this.avatarUrl,
    required this.lastLocation,
  });

  PilgrimManagementModel copyWith({
    String? id,
    String? name,
    String? passportNumber,
    String? groupName,
    String? roomNumber,
    String? gender,
    int? age,
    String? phone,
    String? status,
    String? healthStatus,
    String? avatarUrl,
    String? lastLocation,
  }) {
    return PilgrimManagementModel(
      id: id ?? this.id,
      name: name ?? this.name,
      passportNumber: passportNumber ?? this.passportNumber,
      groupName: groupName ?? this.groupName,
      roomNumber: roomNumber ?? this.roomNumber,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      healthStatus: healthStatus ?? this.healthStatus,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastLocation: lastLocation ?? this.lastLocation,
    );
  }
}
