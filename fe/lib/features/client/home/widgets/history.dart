import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

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

class HomeHistory extends StatelessWidget {
  const HomeHistory({super.key, this.days = const []});

  final List<HistoryDay> days;

  static const String _happyIcon = 'assets/images/emoji/happy_blue.svg';
  static const String _sadIcon = 'assets/images/emoji/sad_blue.svg';

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
          if (days.isEmpty)
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
                  days.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      right: index < days.length - 1 ? 6 : 0,
                    ),
                    child: _buildEmotionDay(
                      day: days[index].dayLabel,
                      emotion: days[index].emotionLabel,
                      iconAsset: days[index].iconAsset,
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
