import 'dart:convert';
import 'dart:io';

import 'package:hackathon/core/models/analysis_models.dart';
import 'package:hackathon/core/models/api_response.dart';
import 'package:hackathon/core/services/api_client.dart';

class AnalysisService {
  final ApiClient _client;

  AnalysisService(this._client);

  Future<ApiResponse<AnalysisTextResponse>> analyzeText(
    AnalysisTextRequest request,
  ) {
    return _client.post(
      '/analysis/text',
      body: request.toJson(),
      parser: (json) => AnalysisTextResponse.fromJson(json),
    );
  }

  /// Mengirim gambar wajah ke endpoint `/analysis/face` sebagai JSON body
  /// berisi `imageBase64` (base64 encoded). Pendekatan ini lebih reliabel
  /// daripada multipart/form-data di Vercel serverless.
  Future<ApiResponse<AnalysisFaceResponse>> analyzeFace({
    required File image,
    String? mimeType,
    String? userId,
  }) async {
    // Baca file dan convert ke base64
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    // Tentukan MIME type dari ekstensi file
    final resolvedMimeType = mimeType ?? _guessMimeType(image.path);

    final body = <String, dynamic>{
      'imageBase64': base64Image,
      'mimeType': resolvedMimeType,
    };
    if (userId != null) {
      body['userId'] = userId;
    }

    return _client.post(
      '/analysis/face',
      body: body,
      parser: (json) => AnalysisFaceResponse.fromJson(json),
    );
  }

  String _guessMimeType(String filePath) {
    final lower = filePath.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg'; // default JPEG untuk HEIC/JPG/JPEG
  }

  Future<ApiResponse<AnalysisDashboardResponse>> fetchDashboard({
    String? userId,
  }) {
    return _client.get(
      '/analysis/dashboard',
      query: userId == null ? null : {'userId': userId},
      parser: (json) => AnalysisDashboardResponse.fromJson(json),
    );
  }
}
