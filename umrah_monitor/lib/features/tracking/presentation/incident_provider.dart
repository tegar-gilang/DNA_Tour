import 'dart:io' show HttpDate;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/sos_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';

enum SosIncidentStatus {
  triggered,
  acknowledged,
  inAction,
  resolved,
  falseAlarm;

  String get backendValue {
    switch (this) {
      case SosIncidentStatus.triggered:
        return 'triggered';
      case SosIncidentStatus.acknowledged:
        return 'acknowledged';
      case SosIncidentStatus.inAction:
        return 'in_action';
      case SosIncidentStatus.resolved:
        return 'resolved';
      case SosIncidentStatus.falseAlarm:
        return 'false_alarm';
    }
  }

  String get label {
    switch (this) {
      case SosIncidentStatus.triggered:
        return 'Menunggu Konfirmasi';
      case SosIncidentStatus.acknowledged:
        return 'Diterima';
      case SosIncidentStatus.inAction:
        return 'Dalam Penanganan';
      case SosIncidentStatus.resolved:
        return 'Selesai';
      case SosIncidentStatus.falseAlarm:
        return 'Alarm Palsu';
    }
  }

  static SosIncidentStatus fromString(String? value) {
    switch (value) {
      case 'triggered':
      case 'open':
        return SosIncidentStatus.triggered;
      case 'acknowledged':
        return SosIncidentStatus.acknowledged;
      case 'in_action':
      case 'investigating':
        return SosIncidentStatus.inAction;
      case 'resolved':
        return SosIncidentStatus.resolved;
      case 'false_alarm':
        return SosIncidentStatus.falseAlarm;
      default:
        return SosIncidentStatus.triggered;
    }
  }
}

class IncidentModel {
  final String id;
  final String title;
  final String pilgrimName;
  final String type; // 'health', 'lost', 'accident', 'critical', etc.
  final String priority; // 'critical', 'high', 'medium'
  final String time;
  final String location;
  final String status; // 'triggered', 'acknowledged', 'in_action', 'resolved', 'false_alarm'

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

  SosIncidentStatus get incidentStatus => SosIncidentStatus.fromString(status);

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    final jamaah = json['jamaah'] is Map ? json['jamaah'] as Map<String, dynamic> : null;
    final kloter = json['kloter'] is Map ? json['kloter'] as Map<String, dynamic> : null;

    final pilgrimName = jamaah?['full_name']?.toString() ?? 'Jamaah (Tidak diketahui)';
    final locationName = json['location_name']?.toString() ??
        (kloter != null ? kloter['name']?.toString() ?? 'Area Jamaah' : 'Area Makkah/Madinah');
    final desc = json['description']?.toString();
    final type = json['type']?.toString() ?? 'critical';

    String title;
    if (desc != null && desc.trim().isNotEmpty) {
      title = desc.trim();
    } else {
      title = switch (type) {
        'health' => 'Darurat Medis / Kesehatan',
        'lost' => 'Tersesat / Terpisah Rombongan',
        'accident' => 'Kecelakaan / Terjatuh',
        _ => 'Laporan Darurat SOS',
      };
    }

    String priority;
    if (type == 'health' || type == 'critical') {
      priority = 'critical';
    } else if (type == 'lost' || type == 'accident') {
      priority = 'high';
    } else {
      priority = 'medium';
    }

    String timeFormatted = 'Baru Saja';
    final triggeredAtStr = json['triggered_at']?.toString();
    if (triggeredAtStr != null) {
      final dt = DateTime.tryParse(triggeredAtStr);
      if (dt != null) {
        final local = dt.toLocal();
        final hh = local.hour.toString().padLeft(2, '0');
        final mm = local.minute.toString().padLeft(2, '0');
        timeFormatted = '$hh:$mm';
      }
    }

    return IncidentModel(
      id: json['id']?.toString() ?? '',
      title: title,
      pilgrimName: pilgrimName,
      type: type,
      priority: priority,
      time: timeFormatted,
      location: locationName,
      status: json['status']?.toString() ?? 'triggered',
    );
  }

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

class IncidentState {
  final List<IncidentModel> incidents;
  final bool isLoading;
  final String? errorMessage;

  const IncidentState({
    this.incidents = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  IncidentState copyWith({
    List<IncidentModel>? incidents,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return IncidentState(
      incidents: incidents ?? this.incidents,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class IncidentNotifier extends StateNotifier<IncidentState> {
  final SosRepository? _sosRepository;

  IncidentNotifier([this._sosRepository, bool autoFetch = false]) : super(const IncidentState()) {
    if (_sosRepository != null && autoFetch) {
      fetchIncidents();
    }
  }

  Future<void> fetchIncidents() async {
    if (_sosRepository == null) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final res = await _sosRepository.getIncidents();
      final dataField = res['data'];

      List<dynamic> listRaw = [];
      if (dataField is Map && dataField['data'] is List) {
        listRaw = dataField['data'] as List;
      } else if (dataField is List) {
        listRaw = dataField;
      }

      final parsed = listRaw
          .whereType<Map<String, dynamic>>()
          .map((item) => IncidentModel.fromJson(item))
          .toList();

      state = state.copyWith(
        incidents: parsed,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat daftar insiden: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }

  Future<void> updateIncidentStatus(
    String id,
    String newStatus, {
    String? reason,
  }) async {
    final backendStatus = SosIncidentStatus.fromString(newStatus).backendValue;

    if (_sosRepository != null) {
      try {
        final response = await _sosRepository.updateIncidentStatus(
          id: id,
          status: backendStatus,
          reason: reason,
        );
        // Gunakan status dari response server sebagai sumber kebenaran.
        // Jika response menyediakan status yang dapat diparsing, gunakan itu
        // untuk update lokal yang cepat.  Kemudian lakukan re-fetch ringan
        // agar seluruh daftar tersinkron dengan backend.
        final serverStatus = (response['data'] is Map)
            ? (response['data'] as Map<String, dynamic>)['status']?.toString()
            : null;
        final confirmedStatus = serverStatus ?? backendStatus;

        // Perbarui status lokal segera agar UI responsif.
        final updated = state.incidents.map((inc) {
          if (inc.id == id) {
            return inc.copyWith(status: confirmedStatus);
          }
          return inc;
        }).toList();
        state = state.copyWith(incidents: updated);

        // Lakukan re-fetch di background untuk memastikan seluruh daftar
        // (termasuk field lain seperti acknowledged_at, resolved_at) sesuai
        // dengan backend. Tidak menunggu hasilnya agar UI tetap responsif.
        // Jika re-fetch gagal, data lokal yang sudah diperbarui di atas
        // tetap dipertahankan.
        _refreshInBackground();
        return;
      } catch (e) {
        rethrow;
      }
    }

    // Fallback (tanpa repository, misal dalam test lokal)
    final updated = state.incidents.map((inc) {
      if (inc.id == id) {
        return inc.copyWith(status: backendStatus);
      }
      return inc;
    }).toList();
    state = state.copyWith(incidents: updated);
  }

  /// Melakukan re-fetch daftar insiden di background tanpa memblokir caller.
  /// Kegagalan re-fetch diabaikan — data lokal yang sudah diperbarui tetap valid.
  void _refreshInBackground() {
    fetchIncidents().catchError((_) {
      // Gagal silent — UI tetap menggunakan data lokal yang sudah diperbarui.
    });
  }

  /// Menyelesaikan insiden yang sudah berstatus [in_action] dengan mengirim
  /// tepat satu PATCH ke backend menuju status [resolved].
  ///
  /// Hanya boleh dipanggil ketika status insiden adalah `in_action`.
  /// Jika status bukan `in_action`, operasi dihentikan dan exception dilempar.
  /// Tidak melakukan retry otomatis maupun transisi perantara.
  Future<void> completeIncident(String id) async {
    // Baca status terkini dari state lokal sebagai validasi awal.
    // Backend tetap menjadi otoritas akhir atas transisi yang valid.
    final incident = state.incidents.firstWhere(
      (i) => i.id == id,
      orElse: () => throw Exception('Insiden tidak ditemukan dalam daftar.'),
    );
    final current = SosIncidentStatus.fromString(incident.status);

    if (current != SosIncidentStatus.inAction) {
      throw Exception(
        'Insiden harus berstatus "Dalam Penanganan" sebelum dapat diselesaikan. '
        'Status saat ini: ${current.label}.',
      );
    }

    // Satu PATCH menuju resolved — tidak ada transisi perantara.
    await updateIncidentStatus(id, 'resolved');
  }

  /// Mengubah status insiden ke [nextStatus] dengan mengirim tepat satu PATCH
  /// ke backend.
  ///
  /// Hanya boleh dipanggil untuk satu langkah transisi.
  /// Jika status lokal tidak sesuai, backend yang akan menolak (HTTP 422).
  Future<void> startHandlingIncident(String id) async {
    final incident = state.incidents.firstWhere(
      (i) => i.id == id,
      orElse: () => throw Exception('Insiden tidak ditemukan dalam daftar.'),
    );
    final current = SosIncidentStatus.fromString(incident.status);

    final String targetStatus;
    switch (current) {
      case SosIncidentStatus.triggered:
        // Transisi wajib: triggered → acknowledged
        targetStatus = 'acknowledged';
      case SosIncidentStatus.acknowledged:
        // Transisi lanjutan: acknowledged → in_action
        targetStatus = 'in_action';
      case SosIncidentStatus.inAction:
      case SosIncidentStatus.resolved:
      case SosIncidentStatus.falseAlarm:
        throw Exception(
          'Tidak dapat memulai penanganan dari status: ${current.label}.',
        );
    }

    // Satu PATCH per penekanan tombol.
    await updateIncidentStatus(id, targetStatus);
  }

  /// Mengekstrak pesan error yang aman dari DioException untuk ditampilkan
  /// ke pengguna. Tidak menyertakan stack trace atau detail internal.
  ///
  /// Untuk HTTP 429, membaca header [Retry-After] jika tersedia dan
  /// menampilkan durasi tunggu dalam detik kepada pengguna.
  static String extractSafeErrorMessage(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final body = error.response?.data;
      final serverMessage = (body is Map) ? body['message']?.toString() : null;

      switch (status) {
        case 422:
          return serverMessage != null
              ? 'Gagal: $serverMessage'
              : 'Permintaan tidak valid. Pastikan status insiden masih dapat diubah.';
        case 429:
          // Baca header Retry-After untuk menampilkan durasi tunggu yang akurat.
          final retryAfterSeconds = parseRetryAfterSeconds(
            error.response?.headers.value('retry-after'),
          );
          if (retryAfterSeconds != null && retryAfterSeconds > 0) {
            return 'Permintaan terlalu sering. Coba lagi dalam $retryAfterSeconds detik.';
          }
          return 'Permintaan terlalu sering. Tunggu sebentar dan coba lagi.';
        case 401:
          return 'Sesi tidak valid. Silakan login kembali.';
        case 403:
          return 'Anda tidak memiliki akses untuk mengubah status insiden ini.';
        case null:
          return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
        default:
          return 'Terjadi kesalahan (HTTP $status). Coba lagi.';
      }
    }
    if (error is Exception) {
      final msg = error.toString().replaceFirst('Exception: ', '');
      // Jangan tampilkan pesan yang terlalu teknis
      if (msg.length > 100) return 'Terjadi kesalahan. Coba lagi.';
      return msg;
    }
    return 'Terjadi kesalahan yang tidak terduga. Coba lagi.';
  }

  /// Mem-parsing nilai header [Retry-After] menjadi jumlah detik.
  ///
  /// Mendukung dua format:
  /// - Bilangan bulat (detik): `"30"`
  /// - Tanggal HTTP (RFC 7231): `"Tue, 20 Oct 2026 07:00:00 GMT"`
  ///
  /// Mengembalikan [null] jika header kosong, tidak valid, atau durasi negatif.
  static int? parseRetryAfterSeconds(String? headerValue) {
    if (headerValue == null || headerValue.trim().isEmpty) return null;

    // Coba parse sebagai integer (detik)
    final asInt = int.tryParse(headerValue.trim());
    if (asInt != null) {
      return asInt > 0 ? asInt : null;
    }

    // Coba parse sebagai tanggal HTTP (RFC 7231)
    try {
      final retryAt = HttpDate.parse(headerValue.trim());
      final secondsUntil = retryAt.difference(DateTime.now().toUtc()).inSeconds;
      return secondsUntil > 0 ? secondsUntil : null;
    } catch (_) {
      return null;
    }
  }

  void addIncident(IncidentModel incident) {
    state = state.copyWith(
      incidents: [incident, ...state.incidents],
    );
  }
}

final sosRepositoryProvider = Provider<SosRepository>((ref) {
  return SosRepository(
    apiClient: ApiClient(),
    secureStorage: SecureStorage(),
  );
});

final incidentNotifierProvider =
    StateNotifierProvider<IncidentNotifier, IncidentState>((ref) {
  final repo = ref.watch(sosRepositoryProvider);
  return IncidentNotifier(repo, true);
});

final incidentProvider = Provider<List<IncidentModel>>((ref) {
  return ref.watch(incidentNotifierProvider).incidents;
});
