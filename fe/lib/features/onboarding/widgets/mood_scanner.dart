import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoodScanner extends StatefulWidget {
  const MoodScanner({super.key});

  @override
  State<MoodScanner> createState() => _MoodScannerState();
}

class _MoodScannerState extends State<MoodScanner> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;

  @override
  void initState() {
    super.initState();
    _initCamera();
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      context.go('/partner');
    });
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

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipOval(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).width * 0.8,
            width: MediaQuery.sizeOf(context).width * 0.8,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: cameraController!.value.previewSize!.height,
                height: cameraController!.value.previewSize!.width,
                child: CameraPreview(cameraController!),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Please look at the camera to capture your mood',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
