import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/journey_model.dart';

class JourneyNotifier extends StateNotifier<JourneyActivityState> {
  JourneyNotifier()
      : super(
          const JourneyActivityState(
            currentActivity: 'Menuju Masjidil Haram',
            currentLocation: 'Area Makkah • Gerbang 1 King Abdulaziz',
            updatedBy: 'Ust. Muhammad Ridwan (TL)',
            lastUpdated: '08:20 AST',
            nextActivity: 'Mulai Tawaf & Sa\'i',
            status: 'On Going',
            eta: '15 Menit',
            estimatedDuration: '2.5 Jam',
            progressPercentage: 0.45,
            totalPilgrims: 45,
            presentCount: 45,
            timeline: [
              JourneyLogItem(
                id: 'j1',
                activity: 'Menuju Masjidil Haram',
                location: 'Area Makkah • Gerbang 1 King Abdulaziz',
                time: '08:20 AST',
                updatedBy: 'Ust. Muhammad Ridwan (TL)',
                attendanceStatus: 'Hadir (45/45 Tersinkron)',
              ),
              JourneyLogItem(
                id: 'j2',
                activity: 'Hotel Check Out & Assembly',
                location: 'Swissôtel Al Maqam Makkah Lobby',
                time: '07:30 AST',
                updatedBy: 'Ust. Muhammad Ridwan (TL)',
                attendanceStatus: 'Present (45/45 Synced)',
              ),
              JourneyLogItem(
                id: 'j3',
                activity: 'Fajr Congregational Prayer',
                location: 'Masjidil Haram Mataf Floor 1',
                time: '04:18 AST',
                updatedBy: 'Ust. Muhammad Ridwan (TL)',
                attendanceStatus: 'Present (45/45 Synced)',
              ),
            ],
          ),
        );

  void updateJourneyStatus({
    required String activity,
    required String location,
    required String nextActivity,
    required String updatedBy,
    String status = 'On Going',
    String eta = '10 Minutes',
    String estimatedDuration = '1.5 Hours',
  }) {
    final nowTime = _formatCurrentTimeAST();
    final newLog = JourneyLogItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      activity: activity,
      location: location,
      time: nowTime,
      updatedBy: updatedBy,
      attendanceStatus: 'Present (45/45 Auto-Synced)',
    );

    state = state.copyWith(
      currentActivity: activity,
      currentLocation: location,
      nextActivity: nextActivity,
      lastUpdated: nowTime,
      updatedBy: updatedBy,
      status: status,
      eta: eta,
      estimatedDuration: estimatedDuration,
      progressPercentage: (state.progressPercentage + 0.09).clamp(0.0, 1.0),
      presentCount: state.totalPilgrims, // 100% attendance synced automatically
      timeline: [newLog, ...state.timeline],
    );
  }

  String _formatCurrentTimeAST() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute AST';
  }
}

final journeyProvider = StateNotifierProvider<JourneyNotifier, JourneyActivityState>((ref) {
  return JourneyNotifier();
});
