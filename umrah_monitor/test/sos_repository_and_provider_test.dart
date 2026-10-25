import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umrah_monitor/core/network/api_client.dart';
import 'package:umrah_monitor/core/storage/secure_storage.dart';
import 'package:umrah_monitor/features/tracking/data/sos_repository.dart';
import 'package:umrah_monitor/features/tracking/presentation/incident_provider.dart';

class FakeSecureStorage extends SecureStorage {
  String? fakeToken = 'valid_sanctum_token_123';

  @override
  Future<String?> getToken() async => fakeToken;
}

void main() {
  group('SosRepository & IncidentNotifier Real API Integration Tests', () {
    late FakeSecureStorage storage;

    setUp(() {
      storage = FakeSecureStorage();
    });

    test('getIncidents calls /sos-incidents with Sanctum Bearer token and parses payload', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/sos-incidents');
            expect(options.headers['Authorization'], 'Bearer valid_sanctum_token_123');
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'message': 'SOS incidents retrieved successfully',
                  'data': {
                    'current_page': 1,
                    'data': [
                      {
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
                      }
                    ],
                  },
                },
              ),
            );
          },
        ),
      );

      final apiClient = ApiClient(customDio: dio);
      final repo = SosRepository(apiClient: apiClient, secureStorage: storage);

      final res = await repo.getIncidents();
      expect(res['message'], 'SOS incidents retrieved successfully');
      expect(res['data'], isA<Map>());

      final notifier = IncidentNotifier(repo);
      await notifier.fetchIncidents();

      expect(notifier.state.isLoading, false);
      expect(notifier.state.errorMessage, isNull);
      expect(notifier.state.incidents.length, 1);
      final first = notifier.state.incidents.first;
      expect(first.id, '01a0f64b-7cc9-70f9-92ea-7d694ac62a09');
      expect(first.pilgrimName, 'Ahmad Fauzi');
      expect(first.status, 'triggered');
      expect(first.incidentStatus, SosIncidentStatus.triggered);
    });

    test('updateIncidentStatus sends PATCH request with reason and updates local state', () async {
      String? sentPath;
      Map? sentData;

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            sentPath = options.path;
            sentData = options.data as Map?;
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'message': 'Status SOS berhasil diperbarui.',
                  'data': {
                    'id': '01a0f64b-7cc9-70f9-92ea-7d694ac62a09',
                    'status': 'false_alarm',
                  },
                },
              ),
            );
          },
        ),
      );

      final apiClient = ApiClient(customDio: dio);
      final repo = SosRepository(apiClient: apiClient, secureStorage: storage);
      final notifier = IncidentNotifier(repo);

      notifier.addIncident(
        const IncidentModel(
          id: '01a0f64b-7cc9-70f9-92ea-7d694ac62a09',
          title: 'Tes SOS',
          pilgrimName: 'Ahmad Fauzi',
          type: 'critical',
          priority: 'critical',
          time: '12:00',
          location: 'Makkah',
          status: 'triggered',
        ),
      );

      await notifier.updateIncidentStatus(
        '01a0f64b-7cc9-70f9-92ea-7d694ac62a09',
        'false_alarm',
        reason: 'Tombol tidak sengaja tertekan oleh anak.',
      );

      expect(sentPath, '/sos-incidents/01a0f64b-7cc9-70f9-92ea-7d694ac62a09/status');
      expect(sentData?['status'], 'false_alarm');
      expect(sentData?['reason'], 'Tombol tidak sengaja tertekan oleh anak.');

      final updated = notifier.state.incidents.first;
      expect(updated.status, 'false_alarm');
      expect(updated.incidentStatus, SosIncidentStatus.falseAlarm);
    });

    test('createIncident excludes mock locationName and sends null coordinates when absent', () async {
      Map? sentData;

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            sentData = options.data as Map?;
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'message': 'SOS berhasil dibuat.',
                  'data': {
                    'id': 'incident-uuid-without-coords',
                    'type': 'critical',
                    'latitude': null,
                    'longitude': null,
                    'location_name': null,
                  },
                },
              ),
            );
          },
        ),
      );

      final apiClient = ApiClient(customDio: dio);
      final repo = SosRepository(apiClient: apiClient, secureStorage: storage);

      final res = await repo.createIncident(
        type: 'critical',
        latitude: null,
        longitude: null,
        locationName: null,
        description: 'Butuh Bantuan Umum',
      );

      expect(res['data']['id'], 'incident-uuid-without-coords');
      expect(sentData?['type'], 'critical');
      expect(sentData?['latitude'], isNull);
      expect(sentData?['longitude'], isNull);
      expect(sentData?['location_name'], isNull);
      expect(sentData?['description'], 'Butuh Bantuan Umum');
    });

    test('createIncident sends exact GPS coordinates when available', () async {
      Map? sentData;

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            sentData = options.data as Map?;
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'message': 'SOS berhasil dibuat.',
                  'data': {
                    'id': 'incident-uuid-with-coords',
                    'type': 'health',
                    'latitude': -6.9444655,
                    'longitude': 107.6713044,
                  },
                },
              ),
            );
          },
        ),
      );

      final apiClient = ApiClient(customDio: dio);
      final repo = SosRepository(apiClient: apiClient, secureStorage: storage);

      final res = await repo.createIncident(
        type: 'health',
        latitude: -6.9444655,
        longitude: 107.6713044,
        description: 'Darurat Medis / Kesehatan',
      );

      expect(res['data']['id'], 'incident-uuid-with-coords');
      expect(sentData?['type'], 'health');
      expect(sentData?['latitude'], -6.9444655);
      expect(sentData?['longitude'], 107.6713044);
      expect(sentData?['location_name'], isNull);
    });

    test('fetchIncidents handles network error safely', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionTimeout,
                error: 'Connection timeout',
              ),
            );
          },
        ),
      );

      final apiClient = ApiClient(customDio: dio);
      final repo = SosRepository(apiClient: apiClient, secureStorage: storage);
      final notifier = IncidentNotifier(repo);

      await notifier.fetchIncidents();

      expect(notifier.state.isLoading, false);
      expect(notifier.state.errorMessage, isNotNull);
      expect(notifier.state.incidents.isEmpty, true);
    });
  });
}
