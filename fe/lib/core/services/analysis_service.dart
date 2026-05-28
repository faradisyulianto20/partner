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

  Future<ApiResponse<AnalysisFaceResponse>> analyzeFace({
    required File image,
    String? mimeType,
    String? userId,
  }) {
    final fields = <String, String>{};
    if (mimeType != null) {
      fields['mimeType'] = mimeType;
    }
    if (userId != null) {
      fields['userId'] = userId;
    }

    return _client.multipart(
      '/analysis/face',
      file: image,
      fields: fields.isEmpty ? null : fields,
      parser: (json) => AnalysisFaceResponse.fromJson(json),
    );
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
