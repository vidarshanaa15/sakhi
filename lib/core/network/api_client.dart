import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

/// Thrown for any non-2xx response or network failure.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Central HTTP client for the app. Wraps base URL, auth header injection,
/// JSON encode/decode, timeouts, and basic retry for transient failures.
class ApiClient {
  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();

  // TODO: point this at your FastAPI deployment (or load from --dart-define / env config).
  static const String baseUrl = 'https://YOUR_FASTAPI_HOST';

  /// Set this from wherever auth/session state lives (e.g. after login).
  /// Returning null means requests go out unauthenticated.
  Future<String?> Function() tokenProvider = () async => null;

  Duration timeout = const Duration(seconds: 15);

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await tokenProvider();
    return {
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$cleanPath').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, '$v')),
    );
  }

  dynamic _decode(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }
    String message = res.body;
    try {
      final parsed = jsonDecode(res.body);
      if (parsed is Map && parsed['detail'] != null) {
        message = parsed['detail'].toString();
      }
    } catch (_) {}
    throw ApiException(message, statusCode: res.statusCode);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final res = await http
          .get(_uri(path, query), headers: await _headers())
          .timeout(timeout);
      return _decode(res);
    } on TimeoutException {
      throw ApiException('Request timed out');
    } on http.ClientException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<dynamic> post(String path, {Object? body}) async {
    try {
      final res = await http
          .post(_uri(path), headers: await _headers(), body: jsonEncode(body))
          .timeout(timeout);
      return _decode(res);
    } on TimeoutException {
      throw ApiException('Request timed out');
    } on http.ClientException catch (e) {
      throw ApiException(e.message);
    }
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    try {
      final res = await http
          .patch(_uri(path), headers: await _headers(), body: jsonEncode(body))
          .timeout(timeout);
      return _decode(res);
    } on TimeoutException {
      throw ApiException('Request timed out');
    } on http.ClientException catch (e) {
      throw ApiException(e.message);
    }
  }

  /// Multipart upload — used for evidence photos/audio/video.
  Future<dynamic> uploadFile(
    String path, {
    required String fieldName,
    required String filePath,
    Map<String, String>? fields,
  }) async {
    final uri = _uri(path);
    final request = http.MultipartRequest('POST', uri);
    final token = await tokenProvider();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (fields != null) request.fields.addAll(fields);
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    try {
      final streamed = await request.send().timeout(
            const Duration(seconds: 60),
          );
      final res = await http.Response.fromStream(streamed);
      return _decode(res);
    } on TimeoutException {
      throw ApiException('Upload timed out');
    }
  }
}