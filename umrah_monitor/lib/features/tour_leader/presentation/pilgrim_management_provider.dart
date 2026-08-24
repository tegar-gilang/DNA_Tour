import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/pilgrim_management_model.dart';

class PilgrimManagementNotifier extends StateNotifier<List<PilgrimManagementModel>> {
  PilgrimManagementNotifier()
      : super(const [
          PilgrimManagementModel(
            id: 'PL-90210',
            name: 'H. Ahmad Zaki Al-Farizi',
            passportNumber: 'A12345678',
            groupName: 'Kloter 4 VIP',
            roomNumber: '1408 Swissôtel',
            gender: 'Pria',
            age: 48,
            phone: '+62 812-3456-7890',
            status: 'Hadir',
            healthStatus: 'Sehat',
            avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
            lastLocation: 'Pelataran Tawaf Masjidil Haram',
          ),
          PilgrimManagementModel(
            id: 'PL-90211',
            name: 'Hj. Siti Rahma',
            passportNumber: 'A87654321',
            groupName: 'Kloter 4 VIP',
            roomNumber: '1408 Swissôtel',
            gender: 'Wanita',
            age: 45,
            phone: '+62 811-9988-7766',
            status: 'Hadir',
            healthStatus: 'Sehat',
            avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
            lastLocation: 'Bukit Shafa Area Sa\'i',
          ),
          PilgrimManagementModel(
            id: 'PL-90214',
            name: 'Hj. Fatimah Zahra',
            passportNumber: 'B99887766',
            groupName: 'Kloter 4 VIP',
            roomNumber: '1402 Swissôtel',
            gender: 'Wanita',
            age: 62,
            phone: '+62 813-1122-3344',
            status: 'Perlu Perhatian',
            healthStatus: 'Kelelahan',
            avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
            lastLocation: 'Pos Kesehatan Safa-Marwah Gate 18',
          ),
          PilgrimManagementModel(
            id: 'PL-88901',
            name: 'H. Sulaiman Rasyid',
            passportNumber: 'C11223344',
            groupName: 'Kloter 4 VIP',
            roomNumber: '1402 Swissôtel',
            gender: 'Pria',
            age: 58,
            phone: '+62 815-5566-7788',
            status: 'Di Hotel',
            healthStatus: 'Sehat',
            avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
            lastLocation: 'Lobi Swissôtel Al Maqam',
          ),
          PilgrimManagementModel(
            id: 'PL-88402',
            name: 'H. Budi Santoso',
            passportNumber: 'D55667788',
            groupName: 'Kloter 4 VIP',
            roomNumber: '1405 Swissôtel',
            gender: 'Pria',
            age: 51,
            phone: '+62 817-8899-0011',
            status: 'Dalam Perjalanan',
            healthStatus: 'Sehat',
            avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
            lastLocation: 'Menuju Masjidil Haram (Pintu 1)',
          ),
        ]);

  void updatePilgrimStatus(String id, String newStatus) {
    state = state.map((p) {
      if (p.id == id) {
        return p.copyWith(status: newStatus);
      }
      return p;
    }).toList();
  }

  void updatePilgrimHealth(String id, String newHealthStatus) {
    state = state.map((p) {
      if (p.id == id) {
        return p.copyWith(healthStatus: newHealthStatus);
      }
      return p;
    }).toList();
  }

  void addPilgrim(PilgrimManagementModel pilgrim) {
    state = [pilgrim, ...state];
  }
}

final pilgrimManagementProvider =
    StateNotifierProvider<PilgrimManagementNotifier, List<PilgrimManagementModel>>((ref) {
  return PilgrimManagementNotifier();
});
