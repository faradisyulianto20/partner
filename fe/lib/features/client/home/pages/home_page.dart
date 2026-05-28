import 'package:flutter/material.dart';
import 'package:hackathon/core/models/analysis_models.dart';
import 'package:hackathon/core/services/analysis_service.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/core/shared_widgets/header.dart';
import 'package:hackathon/features/client/home/widgets/cta.dart';
import 'package:hackathon/features/client/home/widgets/history.dart';
import 'package:hackathon/features/client/home/widgets/today.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _baseUrl = 'http://10.72.12.108:3000';

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
      final userId = Supabase.instance.client.auth.currentUser?.id;
      print('─────────────────────────────────────');
      print('User ID     : ${userId ?? 'null'}');
      print('Auth State  : ${Supabase.instance.client.auth.currentSession != null ? 'Authenticated' : 'Unauthenticated'}');
      print('Session     : ${Supabase.instance.client.auth.currentSession != null ? 'Exists' : 'None'}');
      print('User Email  : ${Supabase.instance.client.auth.currentUser?.email ?? 'null'}');
      print('─────────────────────────────────────');
      if (userId == null) {
        setState(() {
          _errorMessage = 'Sesi tidak ditemukan. Silakan login ulang.';
        });
        return;
      }
      final response = await _analysisService.fetchDashboard(userId: userId);
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
      List<Map<String, String>> todayRecommendations = const [];
      if (today is Map) {
        todayEmotion = today['emotionLabel']?.toString();
        todaySummary = today['summary']?.toString();
        final rawRec = today['recommendations'];
        if (rawRec is Map) {
          todayRecommendations = _buildRecommendationsFromMap(rawRec);
        }
      }

      setState(() {
        _historyDays = days;
        _todayEmotion = todayEmotion;
        _todaySummary = todaySummary;
        _todayRecommendations = todayRecommendations;
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

  List<Map<String, String>> _buildRecommendationsFromMap(Map raw) {
    final items = <Map<String, String>>[];

    final narrative = raw['narrative']?.toString();
    if (narrative != null && narrative.trim().isNotEmpty) {
      items.add({
        'title': raw['title']?.toString() ?? 'Rekomendasi',
        'description': narrative,
      });
    }

    final rawItems = raw['items'];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          final title = item['title']?.toString();
          final desc = item['description']?.toString();
          if (title != null && desc != null) {
            items.add({'title': title, 'description': desc});
          }
        }
      }
    }

    return items;
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
