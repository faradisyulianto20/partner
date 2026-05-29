import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:hackathon/core/constants.dart';

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
  static const String _sadIcon  = 'assets/images/emoji/sad_blue.svg';
  static String get _baseUrl  =>
      AppConstants.baseUrl;

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
      // ── Ambil userId & token dari SharedPreferences ──────────────
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final token  = prefs.getString('custom_access_token') ?? '';

      debugPrint('📊 HISTORY FETCH');
      debugPrint('userId : $userId');
      debugPrint('token  : ${token.isEmpty ? 'KOSONG' : '${token.substring(0, 20)}...'}');

      if (userId.isEmpty) {
        throw Exception('User ID not found. Please login first.');
      }
      if (token.isEmpty) {
        throw Exception('Token not found. Please login first.');
      }

      // ── HTTP GET ─────────────────────────────────────────────────
      final uri = Uri.parse('$_baseUrl/analysis/dashboard')
          .replace(queryParameters: {'userId': userId});

      debugPrint('Request URL : $uri');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // ✅ token dari SharedPreferences
        },
      );

      debugPrint('Status : ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Fetch gagal: ${response.statusCode} - ${response.body}',
        );
      }

      // ── Parse JSON ───────────────────────────────────────────────
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      final rawDays =
          (data['last7Days'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];

      debugPrint('✅ Last 7 Days: ${rawDays.length} items');

      final days = rawDays
          .map(
            (day) => HistoryDay(
              dayLabel:     day['dayLabel']?.toString() ?? '',
              emotionLabel: day['emotionLabel']?.toString(),
              iconAsset:    _resolveIcon(day['emotionLabel']?.toString(), _happyIcon),
            ),
          )
          .toList();

      setState(() => _days = days);
    } catch (e, st) {
      debugPrint('❌ Error: $e\n$st');
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── UI (tidak berubah dari kode asli) ─────────────────────────────

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
                  (i) => Padding(
                    padding: EdgeInsets.only(right: i < 6 ? 6 : 0),
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
                  (i) => Padding(
                    padding: EdgeInsets.only(
                      right: i < _days.length - 1 ? 6 : 0,
                    ),
                    child: _buildEmotionDay(
                      day:       _days[i].dayLabel,
                      emotion:   _days[i].emotionLabel,
                      iconAsset: _days[i].iconAsset,
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
    final label = (emotion == null || emotion.trim().isEmpty) ? '-' : emotion;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE9E9E9), width: 1),
      ),
      child: Column(
        children: [
          Text(day,
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B517A))),
          const SizedBox(height: 12),
          SvgPicture.asset(_resolveIcon(emotion, iconAsset),
              width: 16, height: 16),
          const SizedBox(height: 12),
          SizedBox(
            width: 31,
            child: Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B517A)),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
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
      child: Column(children: [
        Container(
            width: 20, height: 10,
            decoration: BoxDecoration(
                color: const Color(0xFFD4DFE8),
                borderRadius: BorderRadius.circular(4))),
        const SizedBox(height: 12),
        Container(
            width: 16, height: 16,
            decoration: const BoxDecoration(
                color: Color(0xFFD4DFE8), shape: BoxShape.circle)),
        const SizedBox(height: 12),
        Container(
            width: 24, height: 8,
            decoration: BoxDecoration(
                color: const Color(0xFFD4DFE8),
                borderRadius: BorderRadius.circular(4))),
      ]),
    );
  }

  String _resolveIcon(String? emotion, String fallback) {
    if (emotion == null || emotion.trim().isEmpty) return _happyIcon;
    final n = emotion.toLowerCase();
    const negative = ['sedih', 'kesedihan', 'cemas', 'ovt',
                      'overthinking', 'gelisah', 'murung', 'down'];
    if (negative.any((w) => n.contains(w))) return _sadIcon;
    return _happyIcon;
  }
}