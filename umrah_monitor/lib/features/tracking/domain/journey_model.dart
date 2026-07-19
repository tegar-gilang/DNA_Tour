class JourneyActivityState {
  final String currentActivity;
  final String currentLocation;
  final String updatedBy;
  final String lastUpdated;
  final String nextActivity;
  final String status; // 'On Going', 'Waiting', 'Completed'
  final String eta; // e.g. '15 Minutes'
  final String estimatedDuration; // e.g. '2.5 Hours'
  final double progressPercentage; // e.g. 0.45 (45%)
  final int totalPilgrims;
  final int presentCount;
  final List<JourneyLogItem> timeline;

  const JourneyActivityState({
    required this.currentActivity,
    required this.currentLocation,
    required this.updatedBy,
    required this.lastUpdated,
    required this.nextActivity,
    this.status = 'On Going',
    this.eta = '15 Minutes',
    this.estimatedDuration = '2.5 Hours',
    this.progressPercentage = 0.45,
    required this.totalPilgrims,
    required this.presentCount,
    required this.timeline,
  });

  JourneyActivityState copyWith({
    String? currentActivity,
    String? currentLocation,
    String? updatedBy,
    String? lastUpdated,
    String? nextActivity,
    String? status,
    String? eta,
    String? estimatedDuration,
    double? progressPercentage,
    int? totalPilgrims,
    int? presentCount,
    List<JourneyLogItem>? timeline,
  }) {
    return JourneyActivityState(
      currentActivity: currentActivity ?? this.currentActivity,
      currentLocation: currentLocation ?? this.currentLocation,
      updatedBy: updatedBy ?? this.updatedBy,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      nextActivity: nextActivity ?? this.nextActivity,
      status: status ?? this.status,
      eta: eta ?? this.eta,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      totalPilgrims: totalPilgrims ?? this.totalPilgrims,
      presentCount: presentCount ?? this.presentCount,
      timeline: timeline ?? this.timeline,
    );
  }
}

class JourneyLogItem {
  final String id;
  final String activity;
  final String location;
  final String time;
  final String updatedBy;
  final String attendanceStatus;

  const JourneyLogItem({
    required this.id,
    required this.activity,
    required this.location,
    required this.time,
    required this.updatedBy,
    required this.attendanceStatus,
  });
}
