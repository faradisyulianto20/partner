import 'package:flutter/material.dart';
import 'package:hackathon/core/models/analysis_models.dart';
import 'package:hackathon/core/services/analysis_service.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/core/shared_widgets/header.dart';
import 'package:hackathon/features/client/home/widgets/cta.dart';
import 'package:hackathon/features/client/home/widgets/history.dart';
import 'package:hackathon/features/client/home/widgets/today.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _baseUrl = 'http://192.168.137.1:3000';

  late final ApiClient _apiClient = ApiClient(baseUrl: _baseUrl);
  late final AnalysisService _analysisService = AnalysisService(_apiClient);

  bool _isLoading = true;
  String? _errorMessage;
  List<HistoryDay> _historyDays = const [];
  String? _todayEmotion;
  String? _todaySummary;
  List<Map<String, String>> _todayRecommendations = const [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  @override
  void dispose() {
    _apiClient.close();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _analysisService.fetchDashboard();
      if (!response.isSuccess) {
        setState(() {
          _errorMessage = 'Gagal memuat data dashboard.';
        });
        return;
      }

      final data = response.data is AnalysisDashboardResponse
          ? (response.data as AnalysisDashboardResponse).data
          : response.data;
      final map = data is Map ? Map<String, dynamic>.from(data) : null;

      final last7Days = map?['last7Days'];
      final days = <HistoryDay>[];
      if (last7Days is List) {
        for (final item in last7Days) {
          if (item is Map) {
            final dayLabel = item['dayLabel']?.toString() ?? '-';
            final emotionLabel = item['emotionLabel']?.toString();
            days.add(
              HistoryDay(
                dayLabel: dayLabel,
                emotionLabel: emotionLabel,
                iconAsset: _iconForEmotionLabel(emotionLabel),
              ),
            );
          }
        }
      }

      final today = map?['today'];
      String? todayEmotion;
      String? todaySummary;
      String? todayRecommendations;
      if (today is Map) {
        todayEmotion = today['emotionLabel']?.toString();
        todaySummary = today['summary']?.toString();
        todayRecommendations = today['recommendations']?.toString();
      }

      setState(() {
        _historyDays = days;
        _todayEmotion = todayEmotion;
        _todaySummary = todaySummary;
        _todayRecommendations = _buildRecommendations(todayRecommendations);
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memuat data.';
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, String>> _buildRecommendations(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }

    final parts = raw
        .split(RegExp(r'\n+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (parts.length <= 1) {
      return [
        {'title': 'Rekomendasi', 'description': raw.trim()},
      ];
    }

    return List.generate(
      parts.length,
      (index) => {
        'title': 'Rekomendasi ${index + 1}',
        'description': parts[index],
      },
    );
  }

  String _iconForEmotionLabel(String? label) {
    if (label == null || label.trim().isEmpty) {
      return 'assets/images/emoji/damai.svg';
    }
    final normalized = label.toLowerCase();
    if (normalized.contains('bahagia') || normalized.contains('senang')) {
      return 'assets/images/emoji/bahagia.svg';
    }
    if (normalized.contains('damai') ||
        normalized.contains('tenang') ||
        normalized.contains('rileks')) {
      return 'assets/images/emoji/damai.svg';
    }
    if (normalized.contains('ovt') ||
        normalized.contains('overthinking') ||
        normalized.contains('cemas') ||
        normalized.contains('gelisah')) {
      return 'assets/images/emoji/ovt.svg';
    }
    if (normalized.contains('sedih') ||
        normalized.contains('kesedihan') ||
        normalized.contains('murung') ||
        normalized.contains('down')) {
      return 'assets/images/emoji/sedih.svg';
    }
    return 'assets/images/emoji/happy.svg';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          Header(userName: 'Dinda', greeting: 'Selamat Pagi'),
          const SizedBox(height: 20),
          const HomeCTA(),
          const SizedBox(height: 20),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          HomeHistory(days: _historyDays),
          const SizedBox(height: 20),
          HomeToday(
            emotion: _todayEmotion,
            message: _todaySummary,
            iconAsset: _iconForEmotionLabel(_todayEmotion),
            recommendations: _todayRecommendations,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add more content here
              ],
            ),
          ),
        ],
      ),
    );
  }
}
