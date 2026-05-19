import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExpressionAnalysis extends StatefulWidget {
  const ExpressionAnalysis({super.key});

  @override
  State<ExpressionAnalysis> createState() => _ExpressionAnalysisState();
}

class _ExpressionAnalysisState extends State<ExpressionAnalysis> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  int currentState = 0; // 0-4 for 5 states

  // State data
  final List<Map<String, String>> stateData = [
    {
      'title': 'Mempersiapkan Analisis Emosi',
      'description':
          'Pastikan wajahmu berada di tengah latar dan terlihat dengan jelas.',
    },
    {
      'title': 'Menganalisis Mood',
      'description':
          'Kami sedang memahami pola emosi dari ekspresi yang terdeteksi.',
    },
    {
      'title': 'Menyiapkan Insight Emosional',
      'description':
          'Hasil analisis sedang diprosses untuk memberikan dukungan yang sesuai.',
    },
    {
      'title': 'Analisis Hampir Selesai',
      'description':
          'Sebentar lagi kamu akan mendapatkan hasil dan rekomendasi emosionalmu.',
    },
    {
      'title': 'Hasil Analisis Siap',
      'description':
          'Kami telah menyiapkan insight emosional dan rekomendasi dukungan untukmu.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initCamera();
    _simulateStateProgression();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    final List<CameraDescription> availableCams = await availableCameras();
    if (availableCams.isNotEmpty) {
      setState(() {
        cameras = availableCams;
        cameraController = CameraController(
          availableCams.last,
          ResolutionPreset.high,
        );
      });
      cameraController!.initialize().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  void _simulateStateProgression() {
    // Simulate state progression every 3 seconds
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted && currentState < 4) {
        setState(() {
          currentState++;
        });
        return true;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFF1B517A),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Deteksi Ekspresi Wajah',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B517A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Camera preview - ubah ke portrait ratio 3:4
                    if (cameraController != null &&
                        cameraController!.value.isInitialized)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AspectRatio(
                          aspectRatio: 3 / 4, // <-- portrait ratio
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CameraPreview(cameraController!),
                              // Face detection overlay - oval seperti referensi
                              Container(
                                height: 180, // <-- lebih tinggi
                                width: 180, // <-- lebih sempit
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      AspectRatio(
                        aspectRatio: 3 / 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // State title
                    Text(
                      stateData[currentState]['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B517A),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Progress bar
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (currentState + 1) / 5,
                              minHeight: 4,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF1B517A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // State description
                    Text(
                      stateData[currentState]['description']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action button - only show on last state
                    if (currentState == 4)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.go('/home/analysis-result');
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Color(0xFFF4F6F8),
                            side: const BorderSide(
                              color: Color(0xFF1B517A),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Lihat Analisis',
                            style: TextStyle(
                              color: Color(0xFF1B517A),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
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
