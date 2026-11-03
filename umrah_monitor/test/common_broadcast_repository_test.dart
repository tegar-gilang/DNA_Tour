// test/common_broadcast_repository_test.dart
//
// Regression tests untuk BroadcastRepository (common / Jamaah feed).
// Memverifikasi parsing respons JSON aktual dari backend Laravel
// yang dapat mengembalikan struktur:
//   a) Paginated: { message, data: { current_page, data: [...], total } }
//   b) Flat list:  { message, data: [...] }
//   c) Kosong:     { message, data: null } / { message, data: [] }

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umrah_monitor/core/network/api_client.dart';
import 'package:umrah_monitor/core/storage/secure_storage.dart';
import 'package:umrah_monitor/features/common/data/broadcast_repository.dart';

// ── Fakes ───────────────────────────────────────────────────────────────────

class FakeSecureStorage extends SecureStorage {
  @override
  Future<String?> getToken() async => 'valid-jamaah-token';
}

class FakeApiClient extends ApiClient {
  final Dio mockDio;
  FakeApiClient(this.mockDio);
  @override
  Dio get dio => mockDio;
}

// ── Helper ───────────────────────────────────────────────────────────────────

Map<String, dynamic> _broadcastJson({
  String id = 'bc-001',
  String title = 'Pengumuman Test',
  String message = 'Isi pengumuman.',
}) =>
    {
      'id': id,
      'title': title,
      'message': message,
      'category': 'umum',
      'priority': 'normal',
      'sender_name': 'Pembimbing Ali',
      'created_at': '2026-10-27T08:00:00.000000Z',
    };

BroadcastRepository _makeRepo(dynamic responseData) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: responseData,
          ),
        );
      },
    ),
  );
  return BroadcastRepository(
    apiClient: FakeApiClient(dio),
    secureStorage: FakeSecureStorage(),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('BroadcastRepository (common/Jamaah) — parsing JSON', () {
    // ── FORMAT A: Paginated (struktur aktual backend Laravel) ────────────────
    test(
      'FORMAT A – paginated: { data: { data: [...] } } harus berhasil diparsing',
      () async {
        final repo = _makeRepo({
          'message': 'Broadcasts retrieved.',
          'data': {
            'current_page': 1,
            'data': [
              _broadcastJson(id: 'bc-001'),
              _broadcastJson(id: 'bc-002', title: 'Kedua'),
            ],
            'total': 2,
          },
        });

        final result = await repo.getBroadcasts();

        expect(result.length, 2);
        expect(result[0].id, 'bc-001');
        expect(result[0].title, 'Pengumuman Test');
        expect(result[0].senderName, 'Pembimbing Ali');
        expect(result[1].id, 'bc-002');
      },
    );

    // ── FORMAT B: Flat list ─────────────────────────────────────────────────
    test(
      'FORMAT B – flat list: { data: [...] } harus berhasil diparsing',
      () async {
        final repo = _makeRepo({
          'message': 'Broadcasts retrieved.',
          'data': [_broadcastJson(id: 'bc-flat-001')],
        });

        final result = await repo.getBroadcasts();

        expect(result.length, 1);
        expect(result[0].id, 'bc-flat-001');
      },
    );

    // ── FORMAT C: data null ─────────────────────────────────────────────────
    test(
      'FORMAT C – data null: { data: null } harus mengembalikan list kosong',
      () async {
        final repo = _makeRepo({'message': 'No data.', 'data': null});

        final result = await repo.getBroadcasts();

        expect(result, isEmpty);
      },
    );

    // ── FORMAT D: data = list kosong ────────────────────────────────────────
    test(
      'FORMAT D – data: [] harus mengembalikan list kosong',
      () async {
        final repo = _makeRepo({'message': 'No broadcasts.', 'data': []});

        final result = await repo.getBroadcasts();

        expect(result, isEmpty);
      },
    );

    // ── FORMAT E: paginated kosong ──────────────────────────────────────────
    test(
      'FORMAT E – paginated kosong: { data: { data: [], total: 0 } } harus mengembalikan list kosong',
      () async {
        final repo = _makeRepo({
          'message': 'No broadcasts.',
          'data': {'current_page': 1, 'data': [], 'total': 0},
        });

        final result = await repo.getBroadcasts();

        expect(result, isEmpty);
      },
    );

    // ── FORMAT F: respons tidak sesuai (data bukan Map/List) ────────────────
    test(
      'FORMAT F – data tidak dikenal: mengembalikan list kosong, tidak crash',
      () async {
        final repo = _makeRepo({'message': 'Unexpected.', 'data': 42});

        final result = await repo.getBroadcasts();

        expect(result, isEmpty);
      },
    );

    // ── Verifikasi field model ───────────────────────────────────────────────
    test(
      'Broadcast.fromJson memetakan semua field dengan benar',
      () async {
        final repo = _makeRepo({
          'data': [
            {
              'id': 'uuid-broadcast-999',
              'title': 'Rencana Perjalanan Madinah',
              'message': 'Bus berangkat jam 05.00 WAS.',
              'category': 'logistik',
              'priority': 'high',
              'sender_name': 'Ust. Hasan',
              'broadcast_id': 'bcast-ref-123',
              'created_at': '2026-10-27T10:30:00.000000Z',
            }
          ],
        });

        final result = await repo.getBroadcasts();
        expect(result.length, 1);

        final b = result.first;
        expect(b.id, 'uuid-broadcast-999');
        expect(b.title, 'Rencana Perjalanan Madinah');
        expect(b.message, 'Bus berangkat jam 05.00 WAS.');
        expect(b.category, 'logistik');
        expect(b.priority, 'high');
        expect(b.senderName, 'Ust. Hasan');
        expect(b.broadcastId, 'bcast-ref-123');
        expect(b.createdAt.year, 2026);
        expect(b.createdAt.month, 10);
        expect(b.createdAt.day, 27);
      },
    );

    // ── Error: token tidak ada ───────────────────────────────────────────────
    test(
      'getBroadcasts melempar Exception jika token tidak ditemukan',
      () async {
        final dio = Dio();
        final repo = BroadcastRepository(
          apiClient: FakeApiClient(dio),
          secureStorage: _NoTokenStorage(),
        );

        expect(
          () => repo.getBroadcasts(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Token tidak ditemukan'),
            ),
          ),
        );
      },
    );
  });
}

class _NoTokenStorage extends SecureStorage {
  @override
  Future<String?> getToken() async => null;
}
