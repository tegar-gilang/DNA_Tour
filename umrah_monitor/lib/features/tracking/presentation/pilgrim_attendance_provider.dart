import 'package:flutter_riverpod/flutter_riverpod.dart';

class PilgrimItemModel {
  final String id;
  final String name;
  final String passport;
  final String status; // 'checked_in', 'pending', 'missing'
  final int battery;
  final String location;
  final String lastSeen;
  final String health;
  final String phone;

  const PilgrimItemModel({
    required this.id,
    required this.name,
    required this.passport,
    required this.status,
    required this.battery,
    required this.location,
    required this.lastSeen,
    required this.health,
    required this.phone,
  });

  PilgrimItemModel copyWith({
    String? id,
    String? name,
    String? passport,
    String? status,
    int? battery,
    String? location,
    String? lastSeen,
    String? health,
    String? phone,
  }) {
    return PilgrimItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      passport: passport ?? this.passport,
      status: status ?? this.status,
      battery: battery ?? this.battery,
      location: location ?? this.location,
      lastSeen: lastSeen ?? this.lastSeen,
      health: health ?? this.health,
      phone: phone ?? this.phone,
    );
  }
}

class PilgrimAttendanceNotifier extends StateNotifier<List<PilgrimItemModel>> {
  PilgrimAttendanceNotifier()
      : super(const [
          PilgrimItemModel(
            id: 'PL-88210',
            name: 'H. Ahmad Zaki Al-Farizi',
            passport: 'A9284192B',
            status: 'pending',
            battery: 86,
            location: 'Menunggu Absen (Belum Check-In)',
            lastSeen: 'Belum Absen Hari Ini',
            health: 'Sehat & Bugar',
            phone: '+62 812-3456-7890',
          ),
          PilgrimItemModel(
            id: 'PL-90214',
            name: 'Hj. Fatimah Zahra',
            passport: 'C8810293X',
            status: 'missing',
            battery: 42,
            location: 'Di Luar Jangkauan (Area Bukit Safa Lantai 2)',
            lastSeen: 'Belum Absen Hari Ini',
            health: 'Melaporkan Kelelahan & Pusing',
            phone: '+62 813-1122-3344',
          ),
          PilgrimItemModel(
            id: 'PL-88402',
            name: 'H. Budi Santoso',
            passport: 'A1029384Z',
            status: 'pending',
            battery: 64,
            location: 'Di Luar Jangkauan (Radius 2.5 KM dari Ka\'bah)',
            lastSeen: 'Belum Absen Hari Ini',
            health: 'Sehat & Bugar',
            phone: '+62 811-9988-7766',
          ),
          PilgrimItemModel(
            id: 'PL-88511',
            name: 'Hj. Nurul Huda',
            passport: 'B9910293Y',
            status: 'checked_in',
            battery: 92,
            location: 'Masjidil Haram Gerbang 1 King Abdulaziz',
            lastSeen: '1 menit lalu',
            health: 'Sehat & Bugar',
            phone: '+62 812-5544-3322',
          ),
          PilgrimItemModel(
            id: 'PL-88620',
            name: 'H. Ilham Akbar',
            passport: 'A7710293W',
            status: 'checked_in',
            battery: 78,
            location: 'Kamar 1408 Swissôtel Al Maqam',
            lastSeen: '10 menit lalu',
            health: 'Sehat & Bugar',
            phone: '+62 813-8877-6655',
          ),
        ]);

  void recordCheckIn({
    required String pilgrimId,
    required String pilgrimName,
    required String location,
    required int battery,
  }) {
    final nowTime = _formatCurrentTime();
    final index = state.indexWhere((p) => p.id == pilgrimId);

    if (index != -1) {
      final updatedList = List<PilgrimItemModel>.from(state);
      updatedList[index] = updatedList[index].copyWith(
        status: 'checked_in',
        location: location,
        lastSeen: 'Absen Baru Saja ($nowTime)',
        battery: battery,
      );
      state = updatedList;
    } else {
      final newPilgrim = PilgrimItemModel(
        id: pilgrimId,
        name: pilgrimName,
        passport: 'A9281029B',
        status: 'checked_in',
        battery: battery,
        location: location,
        lastSeen: 'Absen Baru Saja ($nowTime)',
        health: 'Sehat & Bugar',
        phone: '+62 812-3456-7890',
      );
      state = [newPilgrim, ...state];
    }
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute WAS';
  }
}

final pilgrimAttendanceProvider =
    StateNotifierProvider<PilgrimAttendanceNotifier, List<PilgrimItemModel>>((ref) {
  return PilgrimAttendanceNotifier();
});
