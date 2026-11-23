import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/lego_set.dart';
import '../models/lego_theme.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Service untuk mengambil data dari REST API PHP menggunakan package `http`.
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> _get(String url) async {
    try {
      final response = await _client
          .get(Uri.parse(url), headers: {'Accept': 'application/json'})
          .timeout(ApiConfig.timeout);

      final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && body['status'] == 'success') {
        return body['data'];
      }
      throw ApiException(body['message'] ?? 'Terjadi kesalahan (HTTP ${response.statusCode})');
    } on TimeoutException {
      throw const ApiException('Koneksi ke server timeout. Periksa Base URL & server API.');
    } on FormatException {
      throw const ApiException('Format respons server tidak valid.');
    } on http.ClientException {
      // SocketException dibungkus menjadi ClientException oleh package http.
      throw const ApiException(
          'Tidak dapat terhubung ke server. Pastikan API PHP berjalan & Base URL benar.');
    }
  }

  Future<List<LegoSet>> fetchSets({int? themeId}) async {
    final url = themeId == null
        ? ApiConfig.setsEndpoint
        : '${ApiConfig.setsEndpoint}?theme_id=$themeId';
    final data = await _get(url) as List<dynamic>;
    return data.map((e) => LegoSet.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<LegoSet> fetchSetById(int id) async {
    final data = await _get('${ApiConfig.setsEndpoint}/$id');
    return LegoSet.fromJson(data as Map<String, dynamic>);
  }

  Future<List<LegoTheme>> fetchThemes() async {
    final data = await _get(ApiConfig.themesEndpoint) as List<dynamic>;
    return data.map((e) => LegoTheme.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<LegoTheme> fetchThemeById(int id) async {
    final data = await _get('${ApiConfig.themesEndpoint}/$id');
    return LegoTheme.fromJson(data as Map<String, dynamic>);
  }
}
