import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/shared_widgets/custom_app_bar.dart';
import 'package:hackathon/core/models/analysis_models.dart';
import '../widgets/recommendation.dart';
import '../widgets/result_summary.dart';

class AnalysisResult extends StatefulWidget {
  const AnalysisResult({super.key, this.result});

  final AnalysisResultData? result;

  @override
  State<AnalysisResult> createState() => _AnalysisResultState();
}

class _AnalysisResultState extends State<AnalysisResult> {
  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final createdAt = result?.createdAt ?? DateTime.now();
    final date = _formatDate(createdAt);
    final time = _formatTime(createdAt);

    final feeling = (result?.emotionLabel.isNotEmpty ?? false)
        ? result!.emotionLabel
        : 'Cemas Ringan';
    final description = (result?.summary.isNotEmpty ?? false)
        ? result!.summary
        : 'Kamu terlihat sedang mengalami kecemasan ringan akibat banyak pikiran dan tekanan emosional yang memenuhi pikiranmu akhir-akhir ini. Hal ini dapat membuatmu merasa lelah, sulit tenang, dan terus memikirkan banyak kemungkinan secara berlebihan.\n\n'
              'Meski terasa cukup berat, kondisi ini masih dapat perlahan membaik jika kamu memberi dirimu waktu untuk beristirahat dan tidak memendam semuanya sendirian. Luangkan waktu 1–2 menit untuk menarik napas perlahan dan menenangkan pikiranmu sejenak, musik yang lembut dapat membantu tubuh dan pikiran terasa lebih rileks, coba keluarkan isi pikiranmu melalui tulisan agar beban di kepala terasa sedikit lebih ringan.';

    final emotionIcon = _emotionIconForFeeling(
      feeling: feeling,
      confidence: result?.confidence,
    );

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomAppBar(title: 'Hasil Analisis', onBack: () => context.go('/home')),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: ResultSummary(
                        date: date,
                        time: time,
                        feeling: feeling,
                        description: description,
                        emotionIcon: emotionIcon,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(child: Recommendation()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final month = months[value.month - 1];
    return '${value.day} $month ${value.year}';
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour.$minute';
  }

  String _emotionIconForFeeling({
    required String feeling,
    required double? confidence,
  }) {
    final normalized = feeling.toLowerCase();
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
        normalized.contains('murung') ||
        normalized.contains('down')) {
      return 'assets/images/emoji/sedih.svg';
    }

    return _emotionIconForConfidence(confidence);
  }

  String _emotionIconForConfidence(double? confidence) {
    final score = ((confidence ?? 0) * 10).round().clamp(1, 10);
    if (score <= 2) {
      return 'assets/images/emoji/sad.svg';
    }
    if (score <= 4) {
      return 'assets/images/emoji/sad_white.svg';
    }
    if (score <= 6) {
      return 'assets/images/emoji/happy_white.svg';
    }
    return 'assets/images/emoji/happy.svg';
  }
}
