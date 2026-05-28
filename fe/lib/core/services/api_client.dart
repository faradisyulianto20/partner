import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hackathon/core/models/api_response.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  ApiClient({required this.baseUrl, this.authToken, http.Client? httpClient})
    : _client = httpClient ?? http.Client() {
    _initToken();
  }

  final String baseUrl;
  final http.Client _client;
  String? authToken;
  StreamSubscription<AuthState>? _authSub;

  void _initToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      authToken = prefs.getString('custom_access_token');

      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((
        data,
      ) async {
        // Option to clear token on logout
        if (data.event == AuthChangeEvent.signedOut) {
          authToken = null;
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('custom_access_token');
        }
      });
    } catch (_) {}
  }

  Uri _buildUri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse(baseUrl);
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;

    // Ensure proper URL construction by using the scheme, host, and port from base
    final resolved = base.replace(
      path:
          (base.path.endsWith('/') ? base.path : base.path + '/') +
          normalizedPath,
    );

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
    Map<String, String>? headers,
    T Function(Object? json)? parser,
  }) async {
    final uri = _buildUri(path, query);
    final requestHeaders = await _defaultHeaders();
    if (headers != null) {
      requestHeaders.addAll(headers);
    }
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
    request.headers.addAll(await _defaultHeaders());
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
    _authSub?.cancel();
    _client.close();
  }

  Future<Map<String, String>> _defaultHeaders() async {
    final headers = <String, String>{'Accept': 'application/json'};

    // Attempt to load token if missing
    if (authToken == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        authToken = prefs.getString('custom_access_token');
      } catch (_) {}
    }

    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    } else {
      // Fallback to Supabase token for initial /auth/provider-token request
      try {
        final session = Supabase.instance.client.auth.currentSession;
        if (session?.accessToken != null) {
          headers['Authorization'] = 'Bearer ${session!.accessToken}';
        }
      } catch (_) {}
    }

    return headers;
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
