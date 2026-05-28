import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:hackathon/core/shared_widgets/custom_app_bar.dart';

class ExpressionAnalysis extends StatefulWidget {
  const ExpressionAnalysis({super.key});

  @override
  State<ExpressionAnalysis> createState() => _ExpressionAnalysisState();
}

class _ExpressionAnalysisState extends State<ExpressionAnalysis> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  int currentState = 0; // 0-4 for 5 states
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableTracking: true,
    ),
  );
  bool _isProcessing = false;
  bool _isFaceDetected = false;

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
    cameraController?.stopImageStream();
    cameraController?.dispose();
    _faceDetector.close();
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
        if (!mounted) return;
        setState(() {});
        _startImageStream();
      });
    }
  }

  Future<void> _startImageStream() async {
    final controller = cameraController;
    if (controller == null || controller.value.isStreamingImages) {
      return;
    }

    await controller.startImageStream((image) async {
      if (_isProcessing) return;
      _isProcessing = true;

      final inputImage = _inputImageFromCameraImage(image, controller);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      try {
        final faces = await _faceDetector.processImage(inputImage);
        if (!mounted) return;
        setState(() {
          _isFaceDetected = faces.isNotEmpty;
        });
      } finally {
        _isProcessing = false;
      }
    });
  }

  InputImage? _inputImageFromCameraImage(
    CameraImage image,
    CameraController controller,
  ) {
    final rotation = InputImageRotationValue.fromRawValue(
      controller.description.sensorOrientation,
    );
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (rotation == null || format == null) {
      return null;
    }

    final bytes = _concatenatePlanes(image.planes);
    final size = Size(image.width.toDouble(), image.height.toDouble());
    final metadata = InputImageMetadata(
      size: size,
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
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
          CustomAppBar(
            title: 'Deteksi Ekspresi Wajah',
            onBack: () => context.pop(),
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
                                height: 180,
                                width: 180,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _isFaceDetected
                                        ? const Color(0xFF2E7D32)
                                        : Colors.white.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: _isFaceDetected ? 1 : 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      'Ekspresi Berhasil Dideteksi',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
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
