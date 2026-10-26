/// Schedule model sesuai kontrak API backend Stage 2.
///
/// Field-field opsional (boleh null) mencerminkan bahwa backend bisa
/// mengembalikan nilai null untuk field yang belum diisi.
/// Parsing selalu dilakukan terhadap field yang benar-benar ada di JSON;
/// tidak ada asumsi nama field.
class ScheduleModel {
  final String id;
  final String title;
  final String? category;
  final String? location;
  final String? description;
  final String? pic;

  /// ISO 8601 datetime string, misalnya "2026-07-14T06:00:00.000000Z".
  final String startTime;

  /// ISO 8601 datetime string; null jika belum diisi.
  final String? endTime;

  /// Waktu selesai efektif yang diperhitungkan backend (memperhitungkan
  /// perpanjangan otomatis, override manual, dll.).  Null jika tidak disediakan.
  final String? effectiveEndTime;

  /// Status pelaksanaan: 'upcoming' | 'in_progress' | 'completed'.
  final String status;

  /// Mode status: 'auto' | 'manual'.
  final String statusMode;

  /// Status reminder: 'draft' | 'published'.
  final String reminderStatus;

  /// Waktu siaran; null jika belum pernah disiarkan.
  final String? broadcastedAt;

  const ScheduleModel({
    required this.id,
    required this.title,
    this.category,
    this.location,
    this.description,
    this.pic,
    required this.startTime,
    this.endTime,
    this.effectiveEndTime,
    required this.status,
    required this.statusMode,
    required this.reminderStatus,
    this.broadcastedAt,
  });

  /// Membuat [ScheduleModel] dari JSON backend.
  ///
  /// Menggunakan pemetaan field aktual hasil verifikasi kontrak Stage 2.
  /// Field yang boleh null tidak diwajibkan agar parsing tidak crash.
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString(),
      location: json['location']?.toString(),
      description: (json['description'] ?? json['keterangan'])?.toString(),
      pic: json['pic']?.toString(),
      startTime: (json['start_time'] ??
              (json['date'] != null && json['time'] != null
                  ? '${json['date']}T${json['time']}'
                  : json['date'] ?? json['time'] ?? ''))
          .toString(),
      endTime: json['end_time']?.toString(),
      effectiveEndTime: (json['effective_end_datetime'] ??
              json['effective_end_time'] ??
              json['inferred_end_time'])
          ?.toString(),
      status: json['status']?.toString() ?? 'upcoming',
      statusMode: json['status_mode']?.toString() ?? 'auto',
      reminderStatus: json['reminder_status']?.toString() ?? 'draft',
      broadcastedAt: json['broadcasted_at']?.toString(),
    );
  }

  /// Mengonversi [ScheduleModel] ke Map untuk payload POST/PATCH.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (category != null) 'category': category,
      if (location != null) 'location': location,
      if (description != null) 'description': description,
      if (pic != null) 'pic': pic,
      'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (effectiveEndTime != null) 'effective_end_time': effectiveEndTime,
      'status': status,
      'status_mode': statusMode,
      'reminder_status': reminderStatus,
      if (broadcastedAt != null) 'broadcasted_at': broadcastedAt,
    };
  }

  ScheduleModel copyWith({
    String? id,
    String? title,
    String? category,
    String? location,
    String? description,
    String? pic,
    String? startTime,
    String? endTime,
    bool clearEndTime = false,
    String? effectiveEndTime,
    bool clearEffectiveEndTime = false,
    String? status,
    String? statusMode,
    String? reminderStatus,
    String? broadcastedAt,
    bool clearBroadcastedAt = false,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      location: location ?? this.location,
      description: description ?? this.description,
      pic: pic ?? this.pic,
      startTime: startTime ?? this.startTime,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      effectiveEndTime: clearEffectiveEndTime
          ? null
          : (effectiveEndTime ?? this.effectiveEndTime),
      status: status ?? this.status,
      statusMode: statusMode ?? this.statusMode,
      reminderStatus: reminderStatus ?? this.reminderStatus,
      broadcastedAt: clearBroadcastedAt
          ? null
          : (broadcastedAt ?? this.broadcastedAt),
    );
  }
}

/// Response wrapper untuk endpoint GET /api/schedules.
class ScheduleListResponse {
  final List<ScheduleModel> schedules;
  final int? total;

  const ScheduleListResponse({
    required this.schedules,
    this.total,
  });

  factory ScheduleListResponse.fromJson(Map<String, dynamic> json) {
    // Backend bisa mengembalikan: { data: [...] } atau { data: { data: [...] } }
    final rawData = json['data'];
    List<dynamic> list = [];

    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map) {
      final inner = rawData['data'];
      if (inner is List) {
        list = inner;
      }
    }

    final schedules = list
        .whereType<Map<String, dynamic>>()
        .map((e) => ScheduleModel.fromJson(e))
        .toList();

    int? total;
    if (rawData is Map) {
      final rawTotal = rawData['total'];
      if (rawTotal is int) {
        total = rawTotal;
      } else if (rawTotal is num) {
        total = rawTotal.toInt();
      } else if (rawTotal is String) {
        total = int.tryParse(rawTotal);
      }
    }

    return ScheduleListResponse(schedules: schedules, total: total);
  }
}

/// Response wrapper untuk endpoint POST /api/schedules dan
/// GET/PATCH /api/schedules/{id}.
class ScheduleSingleResponse {
  final ScheduleModel schedule;
  final String? message;

  const ScheduleSingleResponse({
    required this.schedule,
    this.message,
  });

  factory ScheduleSingleResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final Map<String, dynamic> scheduleJson;

    if (rawData is Map<String, dynamic>) {
      scheduleJson = rawData;
    } else {
      // Fallback: coba parse root sebagai schedule langsung
      scheduleJson = json;
    }

    return ScheduleSingleResponse(
      schedule: ScheduleModel.fromJson(scheduleJson),
      message: json['message']?.toString(),
    );
  }
}

/// Response wrapper untuk POST /api/schedules/{id}/broadcast.
class BroadcastResponse {
  final String? message;
  final String? reminderStatus;
  final int? notificationsProcessed;
  final String? broadcastedAt;

  const BroadcastResponse({
    this.message,
    this.reminderStatus,
    this.notificationsProcessed,
    this.broadcastedAt,
  });

  factory BroadcastResponse.fromJson(Map<String, dynamic> json) {
    // Backend mungkin mengembalikan field di root atau di dalam 'data'
    final root = json;
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    final int? notifCount;
    final rawCount =
        data['notifications_processed'] ?? root['notifications_processed'];
    if (rawCount is int) {
      notifCount = rawCount;
    } else if (rawCount is num) {
      notifCount = rawCount.toInt();
    } else if (rawCount is String) {
      notifCount = int.tryParse(rawCount);
    } else {
      notifCount = null;
    }

    return BroadcastResponse(
      message: root['message']?.toString(),
      reminderStatus:
          (data['reminder_status'] ?? root['reminder_status'])?.toString(),
      notificationsProcessed: notifCount,
      broadcastedAt:
          (data['broadcasted_at'] ?? root['broadcasted_at'])?.toString(),
    );
  }
}
