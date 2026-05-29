import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hackathon/core/shared_widgets/header.dart';
import 'package:hackathon/features/client/home/widgets/cta.dart';
import 'package:hackathon/features/client/home/widgets/history.dart';
import 'package:hackathon/features/client/home/widgets/today.dart';
import 'package:hackathon/core/constants.dart';

final RouteObserver<ModalRoute<void>> homeRouteObserver =
    RouteObserver<ModalRoute<void>>();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) homeRouteObserver.subscribe(this, route);
  }

  @override
  void didPopNext() => _loadDashboard();

  @override
  void dispose() {
    homeRouteObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ── Ambil userId & token dari SharedPreferences ──────────────
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final token = prefs.getString('custom_access_token') ?? '';

      print('── Dashboard Fetch ──────────────────────');
      print('userId : $userId');
      print('token  : ${token.isEmpty ? 'KOSONG' : token.substring(0, 20)}...');

      if (userId.isEmpty || token.isEmpty) {
        setState(() =>
            _errorMessage = 'Sesi tidak ditemukan. Silakan login ulang.');
        return;
      }

      // ── HTTP GET ke endpoint dashboard ───────────────────────────
      final uri = Uri.parse(
        '${AppConstants.baseUrl}/analysis/dashboard'
        '?userId=$userId',
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Status : ${response.statusCode}');
      print('Body   : ${response.body}');

      if (response.statusCode != 200) {
        setState(() => _errorMessage = 'Gagal memuat dashboard (${response.statusCode}).');
        return;
      }

      // ── Parse JSON ───────────────────────────────────────────────
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      // last7Days
      final rawDays = json['last7Days'] as List<dynamic>? ?? [];
      final days = rawDays.map((item) {
        final map = item as Map<String, dynamic>;
        final emotionLabel = map['emotionLabel']?.toString();
        return HistoryDay(
          dayLabel: map['dayLabel']?.toString() ?? '',
          emotionLabel: emotionLabel ?? '',
          iconAsset: _iconForEmotion(emotionLabel),
        );
      }).toList();

      // today
      String? todayEmotion;
      String? todaySummary;
      List<Map<String, String>> todayRecs = const [];

      final rawToday = json['today'];
      if (rawToday is Map<String, dynamic>) {
        todayEmotion = rawToday['emotionLabel']?.toString();
        todaySummary = rawToday['summary']?.toString();

        final rawRec = rawToday['recommendations'];
        if (rawRec is Map) {
          todayRecs = _parseRecommendations(rawRec);
        }
      }

      setState(() {
        _historyDays = days;
        _todayEmotion = todayEmotion;
        _todaySummary = todaySummary;
        _todayRecommendations = todayRecs;
      });

      print('✅ Dashboard loaded — ${days.length} hari, today: $todayEmotion');
    } catch (e, st) {
      print('❌ Exception: $e\n$st');
      setState(() => _errorMessage = 'Terjadi kesalahan saat memuat data.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, String>> _parseRecommendations(Map raw) {
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

  String _iconForEmotion(String? label) {
    if (label == null || label.trim().isEmpty) {
      return 'assets/images/emoji/damai.svg';
    }
    final n = label.toLowerCase();
    if (n.contains('bahagia') || n.contains('senang')) {
      return 'assets/images/emoji/bahagia.svg';
    }
    if (n.contains('damai') || n.contains('tenang') || n.contains('rileks')) {
      return 'assets/images/emoji/damai.svg';
    }
    if (n.contains('ovt') || n.contains('overthinking') ||
        n.contains('cemas') || n.contains('gelisah')) {
      return 'assets/images/emoji/ovt.svg';
    }
    if (n.contains('sedih') || n.contains('murung') || n.contains('down')) {
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
          const HomeHistory(),
          const SizedBox(height: 20),
          HomeToday(
            emotion: _todayEmotion,
            message: _todaySummary,
            iconAsset: _iconForEmotion(_todayEmotion),
            recommendations: _todayRecommendations,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}