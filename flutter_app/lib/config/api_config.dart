class ApiConfig {
  ApiConfig._();

  // Base URL default untuk Web/Desktop; Emulator Android memakai http://10.0.2.2:8000.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.137.1:8000',
  );

  static const String setsEndpoint = '$baseUrl/api/sets';
  static const String themesEndpoint = '$baseUrl/api/themes';

  static const Duration timeout = Duration(seconds: 15);
}
