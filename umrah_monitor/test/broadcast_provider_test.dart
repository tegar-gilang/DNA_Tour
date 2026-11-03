import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umrah_monitor/core/network/api_client.dart';
import 'package:umrah_monitor/core/storage/secure_storage.dart';
import 'package:umrah_monitor/features/common/data/broadcast_repository.dart';
import 'package:umrah_monitor/features/common/domain/broadcast_model.dart';
import 'package:umrah_monitor/features/common/presentation/broadcast_provider.dart';

class FakeBroadcastRepository implements BroadcastRepository {
  List<Broadcast>? result;
  Object? errorToThrow;

  @override
  ApiClient get apiClient => throw UnimplementedError();

  @override
  SecureStorage get secureStorage => throw UnimplementedError();

  @override
  Future<List<Broadcast>> getBroadcasts() async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return result ?? [];
  }
}

void main() {
  late FakeBroadcastRepository fakeRepo;
  late BroadcastNotifier notifier;

  setUp(() {
    fakeRepo = FakeBroadcastRepository();
    notifier = BroadcastNotifier(fakeRepo);
  });

  group('BroadcastNotifier error handling & status', () {
    test('Initial state is idle', () {
      expect(notifier.state.status, BroadcastStatus.idle);
      expect(notifier.state.items, isEmpty);
      expect(notifier.state.errorMessage, isNull);
    });

    test('Loads broadcast list successfully (status = success)', () async {
      fakeRepo.result = [
        Broadcast(
          id: 'b-1',
          title: 'Info Jadwal',
          message: 'Kumpul jam 07:00 di lobi',
          senderName: 'Tour Leader',
          category: 'umum',
          priority: 'high',
          createdAt: DateTime.now(),
        ),
      ];

      await notifier.load();

      expect(notifier.state.status, BroadcastStatus.success);
      expect(notifier.state.items.length, 1);
      expect(notifier.state.items.first.title, 'Info Jadwal');
      expect(notifier.state.errorMessage, isNull);
    });

    test('Returns empty status when repository returns empty list', () async {
      fakeRepo.result = <Broadcast>[];

      await notifier.load();

      expect(notifier.state.status, BroadcastStatus.empty);
      expect(notifier.state.items, isEmpty);
      expect(notifier.state.errorMessage, isNull);
    });

    test('Handles 403 DioException with friendly family access message from backend', () async {
      fakeRepo.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/broadcasts'),
        response: Response(
          requestOptions: RequestOptions(path: '/broadcasts'),
          statusCode: 403,
          data: {'message': 'Forbidden. Relasi keluarga tidak aktif atau tidak ditemukan.'},
        ),
      );

      await notifier.load();

      expect(notifier.state.status, BroadcastStatus.error);
      expect(
        notifier.state.errorMessage,
        'Forbidden. Relasi keluarga tidak aktif atau tidak ditemukan.',
      );
    });

    test('Handles 403 DioException without server message using default friendly fallback', () async {
      fakeRepo.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/broadcasts'),
        response: Response(
          requestOptions: RequestOptions(path: '/broadcasts'),
          statusCode: 403,
          data: null,
        ),
      );

      await notifier.load();

      expect(notifier.state.status, BroadcastStatus.error);
      expect(
        notifier.state.errorMessage,
        'Akses pengumuman keluarga belum aktif. Silakan hubungi admin travel.',
      );
    });

    test('Handles 401 DioException with invalid session message', () async {
      fakeRepo.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/broadcasts'),
        response: Response(
          requestOptions: RequestOptions(path: '/broadcasts'),
          statusCode: 401,
        ),
      );

      await notifier.load();

      expect(notifier.state.status, BroadcastStatus.error);
      expect(notifier.state.errorMessage, 'Sesi tidak valid. Silakan login kembali.');
    });

    test('Handles connection error gracefully', () async {
      fakeRepo.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/broadcasts'),
        type: DioExceptionType.connectionError,
      );

      await notifier.load();

      expect(notifier.state.status, BroadcastStatus.error);
      expect(
        notifier.state.errorMessage,
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    });
  });
}
