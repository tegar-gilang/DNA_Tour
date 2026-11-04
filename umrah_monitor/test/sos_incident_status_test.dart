import 'dart:io' show HttpDate;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umrah_monitor/core/network/api_client.dart';
import 'package:umrah_monitor/core/storage/secure_storage.dart';
import 'package:umrah_monitor/features/tour_leader/presentation/incident_management_screen.dart';
import 'package:umrah_monitor/features/tracking/data/sos_repository.dart';
import 'package:umrah_monitor/features/tracking/presentation/incident_provider.dart';

class FakeSecureStorage extends SecureStorage {
  @override
  Future<String?> getToken() async => 'test_token_123';
}

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

    test('resolveIncident from triggered succeeds and updates status directly to resolved', () async {
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
          status: 'triggered',
        ),
      );

      // Tanpa repository — fallback lokal digunakan untuk update status.
      await notifier.resolveIncident('SOS-300');

      final result = notifier.state.incidents.firstWhere((i) => i.id == 'SOS-300');
      expect(result.status, 'resolved');
      expect(result.incidentStatus, SosIncidentStatus.resolved);
    });

    test('resolveIncident from triggered succeeds — single step directly to resolved', () async {
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
          status: 'triggered',
        ),
      );

      await notifier.resolveIncident('SOS-301');

      final result = notifier.state.incidents.firstWhere((i) => i.id == 'SOS-301');
      expect(result.status, 'resolved');
    });

    test('resolveIncident throws exception if status is not triggered (guard test)', () async {
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

      // Melempar exception karena status bukan triggered
      expect(
        () => notifier.resolveIncident('SOS-302'),
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

    test('historical acknowledged and in_action statuses are recognized without handling action', () {
      const historicalAck = IncidentModel(
        id: 'SOS-HIST-1',
        title: 'Histori Ack',
        pilgrimName: 'Budi',
        type: 'lost',
        priority: 'high',
        time: '08:00',
        location: 'Mina',
        status: 'acknowledged',
      );
      expect(historicalAck.incidentStatus, SosIncidentStatus.acknowledged);
      expect(historicalAck.incidentStatus.label, 'Diterima');

      const historicalInAction = IncidentModel(
        id: 'SOS-HIST-2',
        title: 'Histori In Action',
        pilgrimName: 'Ali',
        type: 'accident',
        priority: 'critical',
        time: '08:30',
        location: 'Arafah',
        status: 'in_action',
      );
      expect(historicalInAction.incidentStatus, SosIncidentStatus.inAction);
      expect(historicalInAction.incidentStatus.label, 'Dalam Penanganan');
    });

    test('resolveIncident when request fails does not change status to resolved', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 500,
                  data: {'message': 'Server error'},
                ),
              ),
            );
          },
        ),
      );

      final apiClient = ApiClient(customDio: dio);
      final repo = SosRepository(apiClient: apiClient, secureStorage: FakeSecureStorage());
      final notifier = IncidentNotifier(repo);

      notifier.addIncident(
        const IncidentModel(
          id: 'SOS-301-FAIL',
          title: 'Test Gagal',
          pilgrimName: 'Siti',
          type: 'lost',
          priority: 'high',
          time: '11:00',
          location: 'Madinah',
          status: 'triggered',
        ),
      );

      expect(() => notifier.resolveIncident('SOS-301-FAIL'), throwsA(isA<DioException>()));

      final result = notifier.state.incidents.firstWhere((i) => i.id == 'SOS-301-FAIL');
      expect(result.status, 'triggered');
      expect(result.incidentStatus, SosIncidentStatus.triggered);
    });
  });

  group('UI IncidentManagementScreen Widget Tests', () {
    testWidgets('Status triggered menampilkan tombol Tangani, dan tidak menampilkan tombol lama', (tester) async {
      final container = ProviderContainer(
        overrides: [
          incidentNotifierProvider.overrideWith((ref) {
            final notifier = IncidentNotifier(null, false);
            notifier.addIncident(
              const IncidentModel(
                id: 'INC-TRIG-1',
                title: 'Darurat Medis',
                pilgrimName: 'Ahmad Fauzi',
                type: 'critical',
                priority: 'critical',
                time: '10:00',
                location: 'Pelataran Tawaf',
                status: 'triggered',
              ),
            );
            return notifier;
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: IncidentManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tangani'), findsOneWidget);
      expect(find.text('Mulai Penanganan'), findsNothing);
      expect(find.text('Tandai Selesai'), findsNothing);
      expect(find.text('Selesaikan Penanganan'), findsNothing);
    });

    testWidgets('Menekan tombol Tangani memanggil resolveIncident dan mengirim status resolved', (tester) async {
      String? sentStatus;
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.method == 'GET') {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'data': [
                      {
                        'id': 'INC-TRIG-2',
                        'status': 'resolved',
                        'type': 'critical',
                        'description': 'Darurat Medis',
                        'location_name': 'Pelataran Tawaf',
                        'jamaah': {
                          'full_name': 'Ahmad Fauzi',
                        },
                      }
                    ],
                  },
                ),
              );
            }
            final data = options.data as Map?;
            sentStatus = data?['status']?.toString();
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'message': 'Status berhasil diperbarui',
                  'data': {
                    'id': 'INC-TRIG-2',
                    'status': 'resolved',
                  },
                },
              ),
            );
          },
        ),
      );

      final apiClient = ApiClient(customDio: dio);
      final repo = SosRepository(apiClient: apiClient, secureStorage: FakeSecureStorage());
      final notifier = IncidentNotifier(repo, false);
      notifier.addIncident(
        const IncidentModel(
          id: 'INC-TRIG-2',
          title: 'Darurat Medis',
          pilgrimName: 'Ahmad Fauzi',
          type: 'critical',
          priority: 'critical',
          time: '10:00',
          location: 'Pelataran Tawaf',
          status: 'triggered',
        ),
      );

      final container = ProviderContainer(
        overrides: [
          sosRepositoryProvider.overrideWithValue(repo),
          incidentNotifierProvider.overrideWith((ref) => notifier),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: IncidentManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tanganiButton = find.text('Tangani');
      expect(tanganiButton, findsOneWidget);

      await tester.tap(tanganiButton);
      await tester.pumpAndSettle();

      expect(sentStatus, 'resolved');
      expect(sentStatus, isNot('acknowledged'));
      expect(sentStatus, isNot('in_action'));
      expect(find.text('SELESAI'), findsOneWidget);
      expect(find.text('Tangani'), findsNothing);
    });

    testWidgets('Status historis acknowledged dan in_action tidak menampilkan tombol penanganan baru', (tester) async {
      final container = ProviderContainer(
        overrides: [
          incidentNotifierProvider.overrideWith((ref) {
            final notifier = IncidentNotifier(null, false);
            notifier.addIncident(
              const IncidentModel(
                id: 'INC-HIST-ACK',
                title: 'Insiden Ack',
                pilgrimName: 'Jamaah A',
                type: 'lost',
                priority: 'high',
                time: '09:00',
                location: 'Hotel',
                status: 'acknowledged',
              ),
            );
            notifier.addIncident(
              const IncidentModel(
                id: 'INC-HIST-ACT',
                title: 'Insiden In Action',
                pilgrimName: 'Jamaah B',
                type: 'medical',
                priority: 'critical',
                time: '09:30',
                location: 'Mina',
                status: 'in_action',
              ),
            );
            return notifier;
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: IncidentManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Memastikan kedua status historis dapat ditampilkan dengan baik
      expect(find.text('DITERIMA'), findsOneWidget);
      expect(find.text('DALAM PENANGANAN'), findsOneWidget);

      // Tidak ada tombol penanganan baru
      expect(find.text('Tangani'), findsNothing);
      expect(find.text('Mulai Penanganan'), findsNothing);
      expect(find.text('Tandai Selesai'), findsNothing);
      expect(find.text('Selesaikan Penanganan'), findsNothing);
    });

    testWidgets('Status resolved dan false_alarm tidak menyediakan tombol penanganan', (tester) async {
      final container = ProviderContainer(
        overrides: [
          incidentNotifierProvider.overrideWith((ref) {
            final notifier = IncidentNotifier(null, false);
            notifier.addIncident(
              const IncidentModel(
                id: 'INC-RES',
                title: 'Insiden Selesai',
                pilgrimName: 'Jamaah C',
                type: 'health',
                priority: 'high',
                time: '07:00',
                location: 'Masjidil Haram',
                status: 'resolved',
              ),
            );
            notifier.addIncident(
              const IncidentModel(
                id: 'INC-FA',
                title: 'Insiden False Alarm',
                pilgrimName: 'Jamaah D',
                type: 'health',
                priority: 'medium',
                time: '06:00',
                location: 'Hotel',
                status: 'false_alarm',
              ),
            );
            return notifier;
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: IncidentManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SELESAI'), findsOneWidget);
      expect(find.text('ALARM PALSU'), findsOneWidget);
      expect(find.text('Tangani'), findsNothing);
      expect(find.text('Mulai Penanganan'), findsNothing);
      expect(find.text('Tandai Selesai'), findsNothing);
    });
  });
}
