class AnalysisTextRequest {
  final String text;
  final String? userId;

  const AnalysisTextRequest({required this.text, this.userId});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'text': text};
    if (userId != null) {
      json['userId'] = userId;
    }
    return json;
  }
}

class AnalysisTextResponse {
  final AnalysisResultData? result;
  final Object? raw;

  const AnalysisTextResponse({required this.result, required this.raw});

  factory AnalysisTextResponse.fromJson(Object? json) {
    final payload = _resolvePayload(json);
    return AnalysisTextResponse(
      result: AnalysisResultData.tryFromJson(payload),
      raw: json,
    );
  }
}

class AnalysisResultData {
  final String id;
  final DateTime createdAt;
  final String emotionLabel;
  final String summary;
  final String recommendations;
  final double confidence;

  const AnalysisResultData({
    required this.id,
    required this.createdAt,
    required this.emotionLabel,
    required this.summary,
    required this.recommendations,
    required this.confidence,
  });

  static AnalysisResultData? tryFromJson(Object? json) {
    if (json is! Map) {
      return null;
    }

    final map = Map<String, dynamic>.from(json);
    if (!map.containsKey('id')) {
      return null;
    }

    final createdAtRaw = map['createdAt'];
    DateTime createdAt = DateTime.now();
    if (createdAtRaw is String) {
      final parsed = DateTime.tryParse(createdAtRaw);
      if (parsed != null) {
        createdAt = parsed.toLocal();
      }
    }

    return AnalysisResultData(
      id: map['id']?.toString() ?? '',
      createdAt: createdAt,
      emotionLabel: map['emotionLabel']?.toString() ?? '',
      summary: map['summary']?.toString() ?? '',
      recommendations: map['recommendations']?.toString() ?? '',
      confidence: _toDouble(map['confidence']),
    );
  }
}

Object? _resolvePayload(Object? json) {
  if (json is Map && json['data'] is Map) {
    return json['data'];
  }
  return json;
}

double _toDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

class AnalysisFaceResponse {
  final Object? data;

  const AnalysisFaceResponse({required this.data});

  factory AnalysisFaceResponse.fromJson(Object? json) {
    return AnalysisFaceResponse(data: json);
  }
}

class AnalysisDashboardResponse {
  final Object? data;

  const AnalysisDashboardResponse({required this.data});

  factory AnalysisDashboardResponse.fromJson(Object? json) {
    return AnalysisDashboardResponse(data: _resolvePayload(json));
  }
}
