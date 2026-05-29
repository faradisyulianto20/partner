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
