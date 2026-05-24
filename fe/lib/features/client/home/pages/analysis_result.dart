import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/shared_widgets/custom_app_bar.dart';
import '../widgets/recommendation.dart';
import '../widgets/result_summary.dart';

class AnalysisResult extends StatefulWidget {
  const AnalysisResult({super.key});

  @override
  State<AnalysisResult> createState() => _AnalysisResultState();
}

class _AnalysisResultState extends State<AnalysisResult> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomAppBar(title: 'Hasil Analisis', onBack: () => context.pop()),
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
                        date: '12 Mei 2026',
                        time: '02.30',
                        feeling: 'cemas ringan',
                        description:
                            'Kamu terlihat sedang mengalami kecemasan ringan akibat banyak pikiran dan tekanan emosional yang memenuhi pikiranmu akhir-akhir ini. Hal ini dapat membuatmu merasa lelah, sulit tenang, dan terus memikirkan banyak kemungkinan secara berlebihan.\n\n' // <-- Paragraf 1 selesai di sini
                            'Meski terasa cukup berat, kondisi ini masih dapat perlahan membaik jika kamu memberi dirimu waktu untuk beristirahat dan tidak memendam semuanya sendirian. Luangkan waktu 1–2 menit untuk menarik napas perlahan dan menenangkan pikiranmu sejenak, musik yang lembut dapat membantu tubuh dan pikiran terasa lebih rileks, coba keluarkan isi pikiranmu melalui tulisan agar beban di kepala terasa sedikit lebih ringan.', // <-- Paragraf 2
                        emotionIcon: 'assets/images/emoji/happy.svg',
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
}
