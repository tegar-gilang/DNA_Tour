import 'dart:io' show HttpDate;
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umrah_monitor/features/tracking/presentation/incident_provider.dart';

void main() {
  group('SosIncidentStatus Enum & Mapping Tests', () {
    test('backendValue matches API technical status strings', () {
      expect(SosIncidentStatus.triggered.backendValue, 'triggered');
      expect(SosIncidentStatus.acknowledged.backendValue, 'acknowledged');
      expect(SosIncidentStatus.inAction.backendValue, 'in_action');
      expect(SosIncidentStatus.resolved.backendValue, 'resolved');
      expect(SosIncidentStatus.falseAlarm.backendValue, 'false_alarm');
    });

    test('label matches user-facing Indonesian translations', () {
      expect(SosIncidentStatus.triggered.label, 'Menunggu Konfirmasi');
      expect(SosIncidentStatus.acknowledged.label, 'Diterima');
      expect(SosIncidentStatus.inAction.label, 'Dalam Penanganan');
      expect(SosIncidentStatus.resolved.label, 'Selesai');
      expect(SosIncidentStatus.falseAlarm.label, 'Alarm Palsu');
    });

    test('fromString safely maps legacy and backend values', () {
      expect(SosIncidentStatus.fromString('triggered'), SosIncidentStatus.triggered);
      expect(SosIncidentStatus.fromString('open'), SosIncidentStatus.triggered);
      expect(SosIncidentStatus.fromString('acknowledged'), SosIncidentStatus.acknowledged);
      expect(SosIncidentStatus.fromString('in_action'), SosIncidentStatus.inAction);
      expect(SosIncidentStatus.fromString('investigating'), SosIncidentStatus.inAction);
      expect(SosIncidentStatus.fromString('resolved'), SosIncidentStatus.resolved);
      expect(SosIncidentStatus.fromString('false_alarm'), SosIncidentStatus.falseAlarm);
      expect(SosIncidentStatus.fromString('unknown_status'), SosIncidentStatus.triggered);
      expect(SosIncidentStatus.fromString(null), SosIncidentStatus.triggered);
    });

    test('IncidentModel incidentStatus getter resolves properly', () {
      const incident = IncidentModel(
        id: 'INC-001',
        title: 'Medis',
        pilgrimName: 'Ahmad',
        type: 'medical',
        priority: 'critical',
        time: '10:00',
        location: 'Makkah',
        status: 'in_action',
      );
      expect(incident.incidentStatus, SosIncidentStatus.inAction);
      expect(incident.incidentStatus.label, 'Dalam Penanganan');
    });

    test('IncidentModel.fromJson parses backend API response properly', () {
      final json = {
        'id': '01a0f64b-7cc9-70f9-92ea-7d694ac62a09',
        'jamaah_id': '01a0eb0d-b4c3-718c-a3ee-781ed8d86472',
        'kloter_id': '01a0ec5f-79b3-71bd-94e5-205ea4bf5dd5',
        'latitude': '-6.2000000',
        'longitude': '106.8000000',
        'status': 'triggered',
        'triggered_at': '2026-10-01T07:08:57.000000Z',
        'type': 'critical',
        'description': 'Laporan darurat sesak nafas',
        'location_name': 'Pelataran Safa Marwah',
        'jamaah': {
          'id': '01a0eb0d-b4c3-718c-a3ee-781ed8d86472',
          'full_name': 'Ahmad Fauzi',
          'phone': '081234567890',
        },
        'kloter': {
          'id': '01a0ec5f-79b3-71bd-94e5-205ea4bf5dd5',
          'name': 'Kloter 1 Jakarta',
        },
      };

      final incident = IncidentModel.fromJson(json);
      expect(incident.id, '01a0f64b-7cc9-70f9-92ea-7d694ac62a09');
      expect(incident.title, 'Laporan darurat sesak nafas');
      expect(incident.pilgrimName, 'Ahmad Fauzi');
      expect(incident.priority, 'critical');
      expect(incident.location, 'Pelataran Safa Marwah');
      expect(incident.status, 'triggered');
      expect(incident.incidentStatus, SosIncidentStatus.triggered);
    });

    test('IncidentNotifier updates status using backend value (no repository)', () {
      final notifier = IncidentNotifier();
      notifier.addIncident(
        const IncidentModel(
          id: 'SOS-201',
          title: 'Darurat Medis',
          pilgrimName: 'Hj. Fatimah',
          type: 'medical',
          priority: 'critical',
          time: '12:00',
          location: 'Safa Marwah',
          status: 'triggered',
        ),
      );
      notifier.updateIncidentStatus('SOS-201', 'resolved');
      final updated = notifier.state.incidents.firstWhere((inc) => inc.id == 'SOS-201');
      expect(updated.status, 'resolved');
      expect(updated.incidentStatus, SosIncidentStatus.resolved);
    });

    test('completeIncident from in_action succeeds (correct P0 behaviour)', () async {
      final notifier = IncidentNotifier();
      notifier.addIncident(
        const IncidentModel(
          id: 'SOS-300',
          title: 'Test Darurat',
          pilgrimName: 'Ahmad',
          type: 'health',
          priority: 'critical',
          time: '10:00',
          location: 'Makkah',
          status: 'in_action',
        ),
      );

      // Tanpa repository — fallback lokal digunakan untuk update status.
      await notifier.completeIncident('SOS-300');

      final result = notifier.state.incidents.firstWhere((i) => i.id == 'SOS-300');
      expect(result.status, 'resolved');
      expect(result.incidentStatus, SosIncidentStatus.resolved);
    });

    test('completeIncident from in_action succeeds — skips multi-step (P0 guard)', () async {
      final notifier = IncidentNotifier();
      notifier.addIncident(
        const IncidentModel(
          id: 'SOS-301',
          title: 'Test',
          pilgrimName: 'Siti',
          type: 'lost',
          priority: 'high',
          time: '11:00',
          location: 'Madinah',
          status: 'in_action',
        ),
      );

      await notifier.completeIncident('SOS-301');

      final result = notifier.state.incidents.firstWhere((i) => i.id == 'SOS-301');
      expect(result.status, 'resolved');
    });

    test('completeIncident throws exception if status is not in_action (guard test)', () async {
      final notifier = IncidentNotifier();
      notifier.addIncident(
        const IncidentModel(
          id: 'SOS-302',
          title: 'Sudah Selesai',
          pilgrimName: 'Umar',
          type: 'health',
          priority: 'critical',
          time: '09:00',
          location: 'Makkah',
          status: 'resolved',
        ),
      );

      // Melempar exception karena status bukan in_action
      expect(
        () => notifier.completeIncident('SOS-302'),
        throwsA(isA<Exception>()),
      );
    });

    test('extractSafeErrorMessage returns safe message for HTTP 422', () {
      final options = RequestOptions(path: '/sos-incidents/id/status');
      final error = DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 422,
          data: {
            'message': 'Transisi status SOS tidak diizinkan.',
            'current_status': 'triggered',
            'requested_status': 'resolved',
          },
        ),
      );

      final msg = IncidentNotifier.extractSafeErrorMessage(error);
      expect(msg, contains('Transisi status SOS tidak diizinkan.'));
      expect(msg, isNot(contains('stack')));
    });

    test('extractSafeErrorMessage returns safe message for HTTP 429 without Retry-After', () {
      final options = RequestOptions(path: '/sos-incidents/id/status');
      final error = DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 429,
          data: {},
        ),
      );

      final msg = IncidentNotifier.extractSafeErrorMessage(error);
      expect(msg, contains('Permintaan terlalu sering'));
    });

    test('extractSafeErrorMessage returns wait time for HTTP 429 with integer Retry-After', () {
      final options = RequestOptions(path: '/sos-incidents/id/status');
      final error = DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 429,
          headers: Headers.fromMap({
            'retry-after': ['45'],
          }),
          data: {},
        ),
      );

      final msg = IncidentNotifier.extractSafeErrorMessage(error);
      expect(msg, 'Permintaan terlalu sering. Coba lagi dalam 45 detik.');
    });

    test('parseRetryAfterSeconds parses integer, valid HTTP date, and ignores invalid/negative', () {
      expect(IncidentNotifier.parseRetryAfterSeconds('30'), 30);
      expect(IncidentNotifier.parseRetryAfterSeconds(' 60 '), 60);
      expect(IncidentNotifier.parseRetryAfterSeconds('0'), isNull);
      expect(IncidentNotifier.parseRetryAfterSeconds('-10'), isNull);
      expect(IncidentNotifier.parseRetryAfterSeconds(''), isNull);
      expect(IncidentNotifier.parseRetryAfterSeconds(null), isNull);
      expect(IncidentNotifier.parseRetryAfterSeconds('invalid_value'), isNull);

      // Future HTTP date
      final futureDate = DateTime.now().toUtc().add(const Duration(seconds: 120));
      final httpDateStr = HttpDate.format(futureDate);
      final parsedSeconds = IncidentNotifier.parseRetryAfterSeconds(httpDateStr);
      expect(parsedSeconds, isNotNull);
      expect(parsedSeconds! >= 115 && parsedSeconds <= 125, isTrue);

      // Past HTTP date
      final pastDate = DateTime.now().toUtc().subtract(const Duration(seconds: 60));
      final pastHttpDateStr = HttpDate.format(pastDate);
      expect(IncidentNotifier.parseRetryAfterSeconds(pastHttpDateStr), isNull);
    });

    test('extractSafeErrorMessage handles network error gracefully', () {
      final options = RequestOptions(path: '/sos-incidents/id/status');
      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'Connection refused',
      );

      final msg = IncidentNotifier.extractSafeErrorMessage(error);
      expect(msg, contains('koneksi internet'));
    });
  });
}
