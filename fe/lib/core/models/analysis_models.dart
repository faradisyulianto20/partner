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

// Ganti class AnalysisDashboardResponse dan tambah DayAnalysis

class AnalysisDashboardResponse {
  final List<DayAnalysis> last7Days;
  final DashboardTodayData? today;

  const AnalysisDashboardResponse({
    required this.last7Days,
    this.today,
  });

  factory AnalysisDashboardResponse.fromJson(Object? json) {
    final payload = _resolvePayload(json);
    if (payload is! Map) {
      return const AnalysisDashboardResponse(last7Days: []);
    }

    final map = Map<String, dynamic>.from(payload);

    return AnalysisDashboardResponse(
      last7Days: (map['last7Days'] as List<dynamic>? ?? [])
          .map((e) => DayAnalysis.fromJson(e as Map<String, dynamic>))
          .toList(),
      today: DashboardTodayData.tryFromJson(map['today']),
    );
  }
}

/// Data hari ini dari dashboard — recommendations disimpan sebagai Object?
/// agar bisa menampung Map yang dikembalikan API.
class DashboardTodayData {
  final String id;
  final DateTime createdAt;
  final String emotionLabel;
  final String summary;
  final Object? recommendations; // Map { title, narrative, items[] } dari API

  const DashboardTodayData({
    required this.id,
    required this.createdAt,
    required this.emotionLabel,
    required this.summary,
    this.recommendations,
  });

  static DashboardTodayData? tryFromJson(Object? json) {
    if (json is! Map) return null;
    final map = Map<String, dynamic>.from(json);
    if (!map.containsKey('id')) return null;

    DateTime createdAt = DateTime.now();
    final createdAtRaw = map['createdAt'];
    if (createdAtRaw is String) {
      final parsed = DateTime.tryParse(createdAtRaw);
      if (parsed != null) createdAt = parsed.toLocal();
    }

    return DashboardTodayData(
      id: map['id']?.toString() ?? '',
      createdAt: createdAt,
      emotionLabel: map['emotionLabel']?.toString() ?? '',
      summary: map['summary']?.toString() ?? '',
      recommendations: map['recommendations'],
    );
  }
}

class DayAnalysis {
  final String date;
  final String dayLabel;
  final String? emotionLabel; // nullable — bisa null jika belum ada analisis

  const DayAnalysis({
    required this.date,
    required this.dayLabel,
    this.emotionLabel,
  });

  factory DayAnalysis.fromJson(Map<String, dynamic> json) {
    return DayAnalysis(
      date: json['date'] as String,
      dayLabel: json['dayLabel'] as String,
      emotionLabel: json['emotionLabel'] as String?,
    );
  }
}

// lib/core/models/analysis_models.dart

class RecommendationItem {
  final String key;
  final String title;
  final String description;

  const RecommendationItem({
    required this.key,
    required this.title,
    required this.description,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) =>
      RecommendationItem(
        key: json['key'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
      );
}

class RecommendationData {
  final String title;
  final String narrative;
  final List<RecommendationItem> items;

  const RecommendationData({
    required this.title,
    required this.narrative,
    required this.items,
  });

  factory RecommendationData.fromJson(Map<String, dynamic> json) =>
      RecommendationData(
        title: json['title'] as String,
        narrative: json['narrative'] as String,
        items: (json['items'] as List)
            .map((e) => RecommendationItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class AnalysisResultData {
  final String id;
  final DateTime createdAt;
  final String emotionLabel;
  final String summary;
  final RecommendationData recommendations;
  final double confidence;

  const AnalysisResultData({
    required this.id,
    required this.createdAt,
    required this.emotionLabel,
    required this.summary,
    required this.recommendations,
    required this.confidence,
  });

  factory AnalysisResultData.fromJson(Map<String, dynamic> json) =>
      AnalysisResultData(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        emotionLabel: json['emotionLabel'] as String,
        summary: json['summary'] as String,
        recommendations: RecommendationData.fromJson(
          json['recommendations'] as Map<String, dynamic>,
        ),
        confidence: (json['confidence'] as num).toDouble(),
      );

  static AnalysisResultData? tryFromJson(Object? json) {
    if (json is! Map) return null;
    try {
      return AnalysisResultData.fromJson(Map<String, dynamic>.from(json));
    } catch (_) {
      return null;
    }
  }
}