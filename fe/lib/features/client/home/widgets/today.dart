import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackathon/features/client/home/widgets/recommendation_dialog.dart';

class HomeToday extends StatelessWidget {
  final String? emotion;
  final String? message;
  final String iconAsset;
  final List<Map<String, String>> recommendations;

  static const String _happyIcon = 'assets/images/emoji/happy_white.svg';
  static const String _sadIcon = 'assets/images/emoji/sad_white.svg';

  const HomeToday({
    super.key,
    this.emotion,
    this.message,
    this.iconAsset = 'assets/images/emoji/happy_white.svg',
    this.recommendations = const [],
  });

  void _showRecommendationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RecomendationDialog(
        message: message,
        recommendations: recommendations,
      ),
    );
  }

  bool get isChecked => emotion != null && emotion!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final resolvedIcon = _resolveIcon(emotion, iconAsset);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1B517A), width: 1),
      ),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFF3D7AB5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(resolvedIcon, width: 42, height: 42),
            ),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Emosi mu hari ini: ',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B517A),
                  ),
                ),
                if (isChecked)
                  TextSpan(
                    text: emotion,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B517A),
                    ),
                  ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            isChecked
                ? (message ?? '')
                : 'Belum ada mood yang terdeteksi hari ini. Kamu bisa mulai dengan membagikan perasaanmu terlebih dahulu.',
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          if (isChecked) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF578BB3), Color(0xFF194F78)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showRecommendationDialog(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Lihat Rekomendasi Untukmu',
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
      'kelelahan',
      'gelisah',
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
