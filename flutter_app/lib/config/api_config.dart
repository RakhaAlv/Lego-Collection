/// Konfigurasi alamat Web Service API (PHP).
///
/// Jalankan API: `php -S 0.0.0.0:8000 -t api/public`
///
/// Pilih Base URL sesuai perangkat:
/// - Emulator Android        : http://10.0.2.2:8000
/// - HP fisik (satu Wi-Fi)    : `http://IP-LAN-laptop:8000` (cek dengan `ipconfig`)
/// - Web / Windows desktop    : http://localhost:8000
/// - Hosting                  : https://domain-anda.com
///
/// Bisa juga di-override saat build tanpa mengubah kode:
/// `flutter build apk --dart-define=API_BASE_URL=http://192.168.1.10:8000`
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String setsEndpoint = '$baseUrl/api/sets';
  static const String themesEndpoint = '$baseUrl/api/themes';

  static const Duration timeout = Duration(seconds: 15);
}
