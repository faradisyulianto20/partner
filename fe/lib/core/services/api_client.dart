import 'dart:convert';
import 'dart:io';

import 'package:hackathon/core/models/api_response.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl, http.Client? httpClient})
    : _client = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Uri _buildUri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse(baseUrl);
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final resolved = base.resolve(normalizedPath);

    if (query == null || query.isEmpty) {
      return resolved;
    }

    final queryParameters = <String, String>{};
    for (final entry in query.entries) {
      if (entry.value == null) {
        continue;
      }
      queryParameters[entry.key] = entry.value.toString();
    }

    return resolved.replace(queryParameters: queryParameters);
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(Object? json)? parser,
  }) async {
    final uri = _buildUri(path, query);
    final response = await _client.get(uri, headers: _defaultHeaders());
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
    final requestHeaders = _defaultHeaders();
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    String? encodedBody;
    if (body != null) {
      requestHeaders.putIfAbsent('Content-Type', () => 'application/json');
      encodedBody = jsonEncode(body);
    }

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
    request.headers.addAll(_defaultHeaders());
    if (fields != null) {
      request.fields.addAll(fields);
    }
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final parsed = _decodeBody(response.body);
    final data = parser != null ? parser(parsed) : parsed as T;
    return ApiResponse(statusCode: response.statusCode, data: data);
  }

  void close() {
    _client.close();
  }

  Map<String, String> _defaultHeaders() {
    return {'Accept': 'application/json'};
  }
}

Object? _decodeBody(String body) {
  if (body.isEmpty) {
    return null;
  }

  try {
    return jsonDecode(body);
  } catch (_) {
    return body;
  }
}
