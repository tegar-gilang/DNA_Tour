import 'package:geolocator/geolocator.dart';

/// Hasil pengambilan lokasi GPS dengan informasi status yang jelas.
class LocationResult {
  /// Koordinat GPS jika berhasil didapatkan; null jika tidak tersedia.
  final Position? position;

  /// Pesan penjelasan mengapa lokasi tidak tersedia (null jika berhasil).
  final String? unavailableReason;

  /// True jika GPS berhasil mendapatkan koordinat.
  bool get hasPosition => position != null;

  const LocationResult.success(Position pos)
      : position = pos,
        unavailableReason = null;

  const LocationResult.unavailable(String reason)
      : position = null,
        unavailableReason = reason;
}

class LocationService {
  /// Mencoba mengambil posisi GPS saat ini.
  ///
  /// Mengembalikan [LocationResult.success] jika koordinat berhasil didapatkan.
  /// Mengembalikan [LocationResult.unavailable] dengan penjelasan jika:
  /// - Layanan GPS nonaktif.
  /// - Izin lokasi ditolak atau ditolak permanen.
  /// - Timeout pengambilan lokasi (15 detik).
  /// - Terjadi kegagalan sensor lainnya.
  ///
  /// Metode ini tidak pernah melempar exception; seluruh kegagalan dikembalikan
  /// sebagai [LocationResult.unavailable] agar pemanggil dapat memutuskan
  /// apakah akan melanjutkan pengiriman SOS tanpa koordinat.
  Future<LocationResult> tryGetCurrentPosition() async {
    try {
      // Periksa apakah layanan lokasi perangkat aktif.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return const LocationResult.unavailable(
          'GPS perangkat belum aktif. Koordinat tidak dapat dikumpulkan.',
        );
      }

      // Periksa izin lokasi.
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return const LocationResult.unavailable(
          'Izin lokasi ditolak. Koordinat tidak dapat dikumpulkan.',
        );
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.unavailable(
          'Izin lokasi ditolak permanen. Aktifkan melalui pengaturan aplikasi.',
        );
      }

      // Ambil posisi GPS terbaru dengan timeout 15 detik.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      return LocationResult.success(position);
    } catch (e) {
      // Tangkap TimeoutException, PlatformException, atau kegagalan sensor lain.
      return LocationResult.unavailable(
        'Koordinat GPS tidak dapat diperoleh saat ini.',
      );
    }
  }
}
