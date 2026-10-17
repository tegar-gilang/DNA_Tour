import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    // Periksa apakah layanan lokasi perangkat aktif.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'GPS perangkat belum aktif. Aktifkan lokasi terlebih dahulu.',
      );
    }

    // Periksa izin lokasi.
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Izin lokasi ditolak.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak permanen. Aktifkan melalui pengaturan aplikasi.',
      );
    }

    // Ambil posisi GPS terbaru.
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }
}
