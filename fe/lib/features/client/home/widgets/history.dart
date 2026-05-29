import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryDay {
  final String dayLabel;
  final String? emotionLabel;
  final String iconAsset;

  const HistoryDay({
    required this.dayLabel,
    required this.emotionLabel,
    required this.iconAsset,
  });
}

class HomeHistory extends StatefulWidget {
  const HomeHistory({super.key});

  @override
  State<HomeHistory> createState() => _HomeHistoryState();
}

class _HomeHistoryState extends State<HomeHistory> {
  static const String _happyIcon = 'assets/images/emoji/happy_blue.svg';
  static const String _sadIcon = 'assets/images/emoji/sad_blue.svg';
  static const String _baseUrl = 'https://partner-seven-phi.vercel.app/';

  List<HistoryDay> _days = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📊 HISTORY FETCH - /analysis/dashboard');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('User ID     : ${userId ?? 'null'}');
      debugPrint(
        'Auth State  : ${Supabase.instance.client.auth.currentSession != null ? 'Authenticated' : 'Unauthenticated'}',
      );
      debugPrint(
        'Session     : ${Supabase.instance.client.auth.currentSession != null ? 'Exists' : 'None'}',
      );
      debugPrint(
        'User Email  : ${Supabase.instance.client.auth.currentUser?.email ?? 'null'}',
      );
      debugPrint('───────────────────────────────────────────────────────');

      if (userId == null) {
        throw Exception('User ID not found. Please login first.');
      }

      // Build URL with userId query parameter
      final uri = Uri.parse('$_baseUrl/analysis/dashboard').replace(
        queryParameters: {'userId': userId},
      );

      debugPrint('Request URL : $uri');
      debugPrint('───────────────────────────────────────────────────────');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer ${Supabase.instance.client.auth.currentSession?.accessToken ?? ''}',
        },
      );

      debugPrint('Status Code : ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final completeData =
            const JsonEncoder.withIndent('  ').convert(data);

        debugPrint('Response Data:');
        debugPrint(completeData);
        debugPrint('───────────────────────────────────────────────────────');

        // Parse last7Days from response
        final last7Days =
            (data['last7Days'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
                [];

        debugPrint('✅ Last 7 Days: ${last7Days.length} items');
        for (int i = 0; i < last7Days.length; i++) {
          final day = last7Days[i];
          debugPrint(
            '  [$i] ${day['dayLabel']} - ${day['emotionLabel'] ?? 'no emotion'}',
          );
        }

        // Convert to HistoryDay objects
        final days = last7Days
            .map((day) => HistoryDay(
                  dayLabel: day['dayLabel'] ?? '',
                  emotionLabel: day['emotionLabel'],
                  iconAsset: _resolveIcon(day['emotionLabel'],  _happyIcon),
                ))
            .toList();

        debugPrint('───────────────────────────────────────────────────────');
        debugPrint('📋 Today Data:');
        final today = data['today'] as Map<String, dynamic>?;
        if (today != null) {
          debugPrint('  Emotion: ${today['emotionLabel']}');
          debugPrint('  Summary: ${today['summary']?.substring(0, 50)}...');
          debugPrint(
            '  Recommendations: ${(today['recommendations'] as Map?)?['narrative']?.substring(0, 50)}...',
          );
        } else {
          debugPrint('  No data for today');
        }
        debugPrint('═══════════════════════════════════════════════════════\n');

        setState(() {
          _days = days;
          _isLoading = false;
        });
      } else {
        throw Exception(
          'Failed to fetch dashboard: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error: $e');
      debugPrint(stackTrace.toString());
      debugPrint('═══════════════════════════════════════════════════════\n');

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1B517A), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat Emosi',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B517A),
                ),
              ),
              Text(
                '7 hari terakhir',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  7,
                  (index) => Padding(
                    padding: EdgeInsets.only(right: index < 6 ? 6 : 0),
                    child: _buildSkeletonDay(),
                  ),
                ),
              ),
            )
          else if (_errorMessage != null)
            Text(
              'Error: $_errorMessage',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            )
          else if (_days.isEmpty)
            Text(
              'Belum ada data riwayat.',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _days.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      right: index < _days.length - 1 ? 6 : 0,
                    ),
                    child: _buildEmotionDay(
                      day: _days[index].dayLabel,
                      emotion: _days[index].emotionLabel,
                      iconAsset: _days[index].iconAsset,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmotionDay({
    required String day,
    required String? emotion,
    required String iconAsset,
  }) {
    final resolvedEmotion = (emotion == null || emotion.trim().isEmpty)
        ? '-'
        : emotion;
    final resolvedIcon = _resolveIcon(emotion, iconAsset);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE9E9E9), width: 1),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B517A),
            ),
          ),
          const SizedBox(height: 12),
          SvgPicture.asset(resolvedIcon, width: 16, height: 16),
          const SizedBox(height: 12),
          SizedBox(
            width: 31,
            child: Text(
              resolvedEmotion,
              style: GoogleFonts.nunito(
                fontSize: 7,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B517A),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonDay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      width: 39,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF3F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE9E9E9), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 20,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFD4DFE8),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: Color(0xFFD4DFE8),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 24,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFD4DFE8),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  String _resolveIcon(String? emotion, String fallback) {
    if (fallback == _happyIcon || fallback == _sadIcon) {
      return fallback;
    }

    if (emotion == null || emotion.trim().isEmpty) {
      return _happyIcon;
    }

    final normalized = emotion.toLowerCase();
    final positiveKeywords = ['bahagia', 'senang', 'damai', 'tenang', 'rileks'];
    final negativeKeywords = [
      'sedih',
      'kesedihan',
      'cemas',
      'ovt',
      'overthinking',
      'gelisah',
      'murung',
      'down',
    ];

    if (negativeKeywords.any((word) => normalized.contains(word))) {
      return _sadIcon;
    }
    if (positiveKeywords.any((word) => normalized.contains(word))) {
      return _happyIcon;
    }

    return _happyIcon;
  }
}
