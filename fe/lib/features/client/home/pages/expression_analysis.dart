import 'package:hackathon/core/constants.dart';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/models/analysis_models.dart';
import 'package:hackathon/core/services/analysis_service.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'dart:async';
import 'package:hackathon/core/shared_widgets/custom_app_bar.dart';

class ExpressionAnalysis extends StatefulWidget {
  const ExpressionAnalysis({super.key});

  @override
  State<ExpressionAnalysis> createState() => _ExpressionAnalysisState();
}

class _ExpressionAnalysisState extends State<ExpressionAnalysis> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  int currentState = 0;
  bool _hasSubmitted = false;
  bool _captureSuccess = false;
  bool _isCapturing = false;
  bool _apiDone = false;
  AnalysisResultData? _analysisResult;

  late final ApiClient _apiClient = ApiClient(baseUrl: AppConstants.baseUrl);
  late final AnalysisService _analysisService = AnalysisService(_apiClient);

  final List<Map<String, String>> stateData = [
    {
      'title': 'Mempersiapkan Analisis Emosi',
      'description':
          'Pastikan wajahmu berada di tengah layar dan terlihat dengan jelas.',
    },
    {
      'title': 'Menganalisis Mood',
      'description':
          'Kami sedang memahami pola emosi dari ekspresi yang terdeteksi.',
    },
    {
      'title': 'Menyiapkan Insight Emosional',
      'description':
          'Hasil analisis sedang diproses untuk memberikan dukungan yang sesuai.',
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
  }

  @override
  void dispose() {
    // cameraController bisa sudah null jika sudah di-dispose setelah capture
    final ctrl = cameraController;
    if (ctrl != null) {
      cameraController = null;
      ctrl.dispose();
    }
    _apiClient.close();
    super.dispose();
  }

  Future<void> _initCamera() async {
    final List<CameraDescription> availableCams = await availableCameras();
    if (availableCams.isNotEmpty) {
      setState(() {
        cameras = availableCams;
        cameraController = CameraController(
          availableCams.last,
          ResolutionPreset.low, // ← gunakan low untuk kurangi tekanan buffer
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );
      });

      await cameraController!.initialize();

      if (mounted) {
        setState(() {});
        // Tunggu agar buffer kamera benar-benar siap
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) _captureAndSubmit();
      }
    }
  }

  Future<void> _captureAndSubmit() async {
    if (_hasSubmitted || _isCapturing) {
      debugPrint(
        '⚠️ [DEBUG-FACE] Proses capture diabaikan karena sedang berjalan atau sudah sukses dikirim.',
      );
      return;
    }

    final controller = cameraController;
    if (controller == null || !controller.value.isInitialized) {
      debugPrint(
        '⚠️ [DEBUG-FACE] Kamera belum siap atau belum diinisialisasi.',
      );
      return;
    }

    if (controller.value.isTakingPicture) {
      debugPrint(
        '⏳ [DEBUG-FACE] Kamera sedang sibuk mengambil gambar, menunda 500ms...',
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _captureAndSubmit();
      return;
    }

    setState(() => _isCapturing = true);
    _simulateStateProgression();

    try {
      debugPrint('📸 [DEBUG-FACE] Menstabilkan frame preview (jeda 300ms)...');
      await Future.delayed(const Duration(milliseconds: 300));

      // 1. Proses Pengambilan Foto
      debugPrint('📸 [DEBUG-FACE] Memicu fungsi takePicture()...');
      final xfile = await controller.takePicture();
      final imageFile = File(xfile.path);

      // Verifikasi File Fisik
      if (await imageFile.exists()) {
        final int fileSize = await imageFile.length();
        debugPrint('✅ [DEBUG-FACE] Foto BERHASIL diambil!');
        debugPrint('📂 [DEBUG-FACE] Path File: ${imageFile.path}');
        debugPrint(
          '⚖️ [DEBUG-FACE] Ukuran File: ${(fileSize / 1024).toStringAsFixed(2)} KB',
        );
      } else {
        debugPrint(
          '❌ [DEBUG-FACE] Gagal: File foto tidak ditemukan di storage lokal.',
        );
        throw Exception('File hasil takePicture tidak tercipta.');
      }

      setState(() {
        _hasSubmitted = true;
        _captureSuccess = true;
      });

      // Dispose kamera SEGERA setelah foto diambil
      // Ini mencegah BLASTBufferQueue buffer overflow saat API call berlangsung
      final camController = cameraController;
      if (camController != null) {
        setState(() => cameraController = null);
        try {
          await camController.dispose();
          debugPrint(
            '📷 [DEBUG-FACE] CameraController disposed setelah capture.',
          );
        } catch (_) {}
      }

      // 2. Proses Pengiriman POST API (base64 JSON)
      debugPrint(
        '🌐 [DEBUG-FACE] Mengirim HTTP POST ke endpoint face analysis di: ${AppConstants.baseUrl}',
      );
      // Timeout 90 detik karena Gemini Vision butuh waktu untuk analisis gambar
      final response = await _analysisService
          .analyzeFace(image: imageFile)
          .timeout(
            const Duration(seconds: 90),
            onTimeout: () => throw TimeoutException('Request timeout 90 detik'),
          );

      // 3. Log Response dari Server
      debugPrint('📥 [DEBUG-FACE] Response diterima dari Server!');
      debugPrint(
        '📊 [DEBUG-FACE] Status Code: ${response.statusCode}, isSuccess: ${response.isSuccess}',
      );
      debugPrint(
        '📦 [DEBUG-FACE] Raw Data Response (Type: ${response.data.runtimeType}): ${response.data}',
      );

      // Hapus berkas foto sementara agar tidak penuh
      if (await imageFile.exists()) {
        await imageFile.delete();
        debugPrint(
          '🗑️ [DEBUG-FACE] File foto sementara berhasil dihapus dari cache.',
        );
      }

      if (!mounted) {
        debugPrint(
          '⚠️ [DEBUG-FACE] Navigasi dibatalkan karena widget sudah tidak mounted.',
        );
        return;
      }

      if (!response.isSuccess) {
        debugPrint(
          '❌ [DEBUG-FACE] API mengembalikan status GAGAL: HTTP ${response.statusCode}.',
        );
        final errorMsg = response.statusCode == 401
            ? 'Sesi kamu sudah habis. Silakan login ulang.'
            : response.statusCode == 404
            ? 'Endpoint tidak ditemukan. Pastikan server backend berjalan.'
            : 'Gagal menganalisis (HTTP ${response.statusCode}). Coba lagi.';
        _showSnackBar(errorMsg);

        setState(() {
          _hasSubmitted = false;
          _isCapturing = false;
          currentState = 0;
        });
        return;
      }

      // 4. Analisis Berhasil — parse result
      debugPrint(
        '🎉 [DEBUG-FACE] Analisis Wajah Sukses! Mem-parse result data...',
      );
      // Response BE langsung berupa { id, emotionLabel, summary, recommendations, confidence, createdAt }
      // AnalysisResultData.tryFromJson sudah handle unwrapping `.data` jika ada
      final rawData = response.data.data;
      final resultData = AnalysisResultData.tryFromJson(rawData);

      if (resultData == null) {
        debugPrint(
          '⚠️ [DEBUG-FACE] tryFromJson menghasilkan null. rawData: $rawData',
        );
        if (!mounted) return;
        _showSnackBar('Gagal memproses hasil analisis. Coba lagi.');
        setState(() {
          _hasSubmitted = false;
          _isCapturing = false;
          currentState = 0;
        });
        return;
      }

      setState(() {
        _analysisResult = resultData;
        _apiDone = true;  
        currentState = 4;
        _isCapturing = false;
      });
    } on TimeoutException catch (e) {
      debugPrint('⏰ [DEBUG-FACE] Request timeout: $e');
      if (!mounted) return;
      _showSnackBar('Analisis memakan waktu terlalu lama. Silakan coba lagi.');
      setState(() {
        _hasSubmitted = false;
        _isCapturing = false;
        currentState = 0;
      });
    } catch (e, stackTrace) {
      debugPrint('🔥 [DEBUG-FACE] CRASH TERJADI PADA ALUR CAPTURE/SUBMIT!');
      debugPrint('🔥 [DEBUG-FACE] Detail Exception: $e');
      debugPrint('📚 [DEBUG-FACE] StackTrace: $stackTrace');

      if (!mounted) return;
      _showSnackBar(
        'Terjadi kesalahan. Pastikan koneksi internet aktif dan coba lagi.',
      );

      setState(() {
        _hasSubmitted = false;
        _isCapturing = false;
        currentState = 0;
      });
    }
  }

  void _simulateStateProgression() {
    if (mounted) setState(() => currentState = 0);

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return false;

      // Lanjut animasi sampai state 3, tunggu API selesai di state 3
      if (currentState < 3) {
        setState(() => currentState++);
        return true;
      }

      // Sudah di state 3, tunggu API selesai
      if (currentState == 3 && !_apiDone) {
        return true; // terus loop (polling) sampai _apiDone true
      }

      return false; // stop
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Column(
        children: [
          CustomAppBar(
            title: 'Deteksi Ekspresi Wajah',
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),

                    // ── Camera Preview ──
                    if (cameraController != null &&
                        cameraController!.value.isInitialized)
                      SizedBox(
                        width: double.infinity,
                        height: 520,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          clipBehavior: Clip.antiAlias,
                          child: // Ganti bagian Stack children di dalam CameraPreview
                          Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: [
                              OverflowBox(
                                alignment: Alignment.center,
                                child: AspectRatio(
                                  aspectRatio:
                                      cameraController!.value.aspectRatio,
                                  child: CameraPreview(cameraController!),
                                ),
                              ),

                              // ── Overlay gelap saat analisis selesai ──
                              if (currentState == 4)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),

                              // Corner overlay (tetap tampil)
                              Center(
                                child: CustomPaint(
                                  size: const Size(220, 270),
                                  painter: _FaceCornerPainter(),
                                ),
                              ),

                              // ── Teks sukses di tengah saat analisis selesai ──
                              if (currentState == 4)
                                const Center(
                                  child: Text(
                                    'Ekspresi Berhasil\nDideteksi',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      height: 1.4,
                                    ),
                                  ),
                                ),

                              // Loading indicator saat capturing (tetap seperti semula)
                              if (_isCapturing)
                                Positioned(
                                  bottom: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Memproses...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    else if (_captureSuccess && currentState == 4)
                      SizedBox(
                        width: double.infinity,
                        height: 520,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(220, 270),
                                  painter: _FaceCornerPainter(),
                                ),
                                const Text(
                                  'Ekspresi Berhasil\nDideteksi',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      // Placeholder saat kamera loading
                      SizedBox(
                        width: double.infinity,
                        height: 480,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF1B517A),
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // ── State Title ──
                    Text(
                      stateData[currentState]['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B517A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Progress Bar ──
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
                    const SizedBox(height: 12),

                    // ── State Description ──
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

                    // ── Tombol Lihat Analisis (hanya state terakhir) ──
                    if (currentState == 4)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.go(
                            '/home/analysis-result',
                            extra: _analysisResult,
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFFF4F6F8),
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

class _FaceCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const double r = 16.0; // corner radius
    const double l = 28.0; // corner line length
    final double w = size.width;
    final double h = size.height;

    // Top-left
    canvas.drawArc(Rect.fromLTWH(0, 0, r * 2, r * 2), pi, pi / 2, false, paint);
    canvas.drawLine(Offset(r, 0), Offset(r + l, 0), paint);
    canvas.drawLine(Offset(0, r), Offset(0, r + l), paint);

    // Top-right
    canvas.drawArc(
      Rect.fromLTWH(w - r * 2, 0, r * 2, r * 2),
      pi * 1.5,
      pi / 2,
      false,
      paint,
    );
    canvas.drawLine(Offset(w - r - l, 0), Offset(w - r, 0), paint);
    canvas.drawLine(Offset(w, r), Offset(w, r + l), paint);

    // Bottom-left
    canvas.drawArc(
      Rect.fromLTWH(0, h - r * 2, r * 2, r * 2),
      pi / 2,
      pi / 2,
      false,
      paint,
    );
    canvas.drawLine(Offset(r, h), Offset(r + l, h), paint);
    canvas.drawLine(Offset(0, h - r - l), Offset(0, h - r), paint);

    // Bottom-right
    canvas.drawArc(
      Rect.fromLTWH(w - r * 2, h - r * 2, r * 2, r * 2),
      0,
      pi / 2,
      false,
      paint,
    );
    canvas.drawLine(Offset(w - r - l, h), Offset(w - r, h), paint);
    canvas.drawLine(Offset(w, h - r - l), Offset(w, h - r), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
