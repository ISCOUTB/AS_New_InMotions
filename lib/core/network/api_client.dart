import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/app_config.dart';
import '../storage/local_session_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    http.Client? client,
    LocalSessionStorage? sessionStorage,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _sessionStorage = sessionStorage ?? LocalSessionStorage(),
        _baseUrl = baseUrl ?? _defaultBaseUrl;

  final http.Client _client;
  final LocalSessionStorage _sessionStorage;
  final String _baseUrl;

  static String get _defaultBaseUrl {
    if (Platform.isAndroid) return AppConfig.localApiBaseUrl;
    return AppConfig.webOrDesktopApiBaseUrl;
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    final response = await _client.get(uri, headers: await _headers(authenticated: authenticated));
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final uri = _buildUri(endpoint);
    final response = await _client.post(
      uri,
      headers: await _headers(authenticated: authenticated),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final uri = _buildUri(endpoint);
    final response = await _client.put(
      uri,
      headers: await _headers(authenticated: authenticated),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {bool authenticated = true}) async {
    final uri = _buildUri(endpoint);
    final response = await _client.delete(uri, headers: await _headers(authenticated: authenticated));
    return _decodeResponse(response);
  }

  Uri _buildUri(String endpoint, [Map<String, String>? queryParameters]) {
    final cleanBaseUrl = _baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl;
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final uri = Uri.parse('$cleanBaseUrl$cleanEndpoint');
    return queryParameters == null ? uri : uri.replace(queryParameters: queryParameters);
  }

  Future<Map<String, String>> _headers({required bool authenticated}) async {
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
    };

    if (authenticated) {
      final token = await _sessionStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      }
    }

    return headers;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final dynamic decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    final body = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{'data': decoded};

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        message: body['message'] as String? ?? 'Error al conectar con el servidor',
        statusCode: response.statusCode,
        details: body,
      );
    }

    return body;
  }
}
