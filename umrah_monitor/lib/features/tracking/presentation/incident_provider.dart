import 'package:flutter_riverpod/flutter_riverpod.dart';

class IncidentModel {
  final String id;
  final String title;
  final String pilgrimName;
  final String type; // 'medical', 'sos', 'lost', 'attendance'
  final String priority; // 'critical', 'high', 'medium'
  final String time;
  final String location;
  final String status; // 'open', 'investigating', 'resolved'

  const IncidentModel({
    required this.id,
    required this.title,
    required this.pilgrimName,
    required this.type,
    required this.priority,
    required this.time,
    required this.location,
    required this.status,
  });

  IncidentModel copyWith({
    String? id,
    String? title,
    String? pilgrimName,
    String? type,
    String? priority,
    String? time,
    String? location,
    String? status,
  }) {
    return IncidentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      pilgrimName: pilgrimName ?? this.pilgrimName,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      time: time ?? this.time,
      location: location ?? this.location,
      status: status ?? this.status,
    );
  }
}

class IncidentNotifier extends StateNotifier<List<IncidentModel>> {
  IncidentNotifier()
      : super(const [
          IncidentModel(
            id: 'SOS-201',
            title: 'Darurat Medis: Kelelahan & Pusing Dilaporkan',
            pilgrimName: 'Hj. Fatimah Zahra (PL-90214)',
            type: 'medical',
            priority: 'critical',
            time: '12:05 WAS (15 menit lalu)',
            location: 'Area Bukit Safa-Marwah Lantai 2 Dekat Gate 18',
            status: 'investigating',
          ),
          IncidentModel(
            id: 'SOS-202',
            title: 'Terlepas dari Rombongan & Kehilangan Arah',
            pilgrimName: 'H. Sulaiman Rasyid (PL-88901)',
            type: 'lost',
            priority: 'high',
            time: '11:10 WAS (1 jam lalu)',
            location: 'Parkiran Bus Jabal Rahmah Area C',
            status: 'resolved',
          ),
          IncidentModel(
            id: 'SOS-203',
            title: 'Gagal Check-In Absensi di Lobi Hotel',
            pilgrimName: 'H. Budi Santoso (PL-88402)',
            type: 'attendance',
            priority: 'medium',
            time: '09:00 WAS (3 jam lalu)',
            location: 'Lobi Swissôtel Al Maqam Makkah',
            status: 'resolved',
          ),
        ]);

  void addIncident(IncidentModel incident) {
    state = [incident, ...state];
  }

  void updateIncidentStatus(String id, String newStatus) {
    state = state.map((inc) {
      if (inc.id == id) {
        return inc.copyWith(status: newStatus);
      }
      return inc;
    }).toList();
  }
}

final incidentProvider =
    StateNotifierProvider<IncidentNotifier, List<IncidentModel>>((ref) {
  return IncidentNotifier();
});
