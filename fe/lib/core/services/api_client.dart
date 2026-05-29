import 'dart:convert';
import 'dart:io';

import 'package:hackathon/core/models/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  ApiClient({
    required this.baseUrl,
    this.authToken,
    http.Client? httpClient,
    bool autoLoadToken = true,
  }) : _client = httpClient ?? http.Client() {
    if (autoLoadToken) {
      _initToken();
    }
  }

  final String baseUrl;
  final http.Client _client;
  String? authToken;

  void _initToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      authToken ??= prefs.getString('custom_access_token');
    } catch (_) {}
  }

  Uri _buildUri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse(baseUrl);
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;

    final resolved = base.replace(
      path:
          (base.path.endsWith('/') ? base.path : '${base.path}/') +
          normalizedPath,
    );

    if (query == null || query.isEmpty) return resolved;

    final queryParameters = <String, String>{};
    for (final entry in query.entries) {
      if (entry.value == null) continue;
      queryParameters[entry.key] = entry.value.toString();
    }

    return resolved.replace(queryParameters: queryParameters);
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    T Function(Object? json)? parser,
  }) async {
    final uri = _buildUri(path, query);
    final requestHeaders = await _defaultHeaders();
    if (headers != null) requestHeaders.addAll(headers);

    final response = await _client.get(uri, headers: requestHeaders);
    final parsed = _decodeBody(response.body);
    final data = parser != null ? parser(parsed) : parsed as T;
    return ApiResponse(statusCode: response.statusCode, data: data);
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? body,
    Map<String, String>? headers,
    T Function(Object? json)? parser,
  }) async {
    final uri = _buildUri(path);
    final requestHeaders = await _defaultHeaders();

    if (body != null) {
      requestHeaders['Content-Type'] =
          'application/json'; // pakai [] bukan putIfAbsent
    }

    if (headers != null) requestHeaders.addAll(headers);

    String? encodedBody;
    if (body != null) {
      encodedBody = jsonEncode(body);
    }

    print('Request URL: $uri');
    print('Request headers: $requestHeaders');
    print('Request body: $encodedBody');

    final response = await _client.post(
      uri,
      headers: requestHeaders,
      body: encodedBody,
    );
    final parsed = _decodeBody(response.body);
    final data = parser != null ? parser(parsed) : parsed as T;
    return ApiResponse(statusCode: response.statusCode, data: data);
  }

  Future<ApiResponse<T>> multipart<T>(
    String path, {
    required File file,
    String fieldName = 'image',
    Map<String, String>? fields,
    T Function(Object? json)? parser,
  }) async {
    final uri = _buildUri(path);
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(await _defaultHeaders());
    if (fields != null) request.fields.addAll(fields);
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final parsed = _decodeBody(response.body);
    final data = parser != null ? parser(parsed) : parsed as T;
    return ApiResponse(statusCode: response.statusCode, data: data);
  }

  void close() => _client.close();

  Future<Map<String, String>> _defaultHeaders() async {
    final headers = <String, String>{'Accept': 'application/json'};

    if (authToken == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        authToken = prefs.getString('custom_access_token');
      } catch (_) {}
    }

    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }
}

Object? _decodeBody(String body) {
  if (body.isEmpty) return null;
  try {
    return jsonDecode(body);
  } catch (_) {
    return body;
  }
}
