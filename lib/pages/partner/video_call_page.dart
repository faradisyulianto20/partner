import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({super.key});

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isFrontCamera = true;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      // prefer front camera for video call
      final front = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );
      setState(() {
        cameras = _cameras;
        cameraController = CameraController(front, ResolutionPreset.high);
      });
      cameraController!.initialize().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _flipCamera() async {
    if (cameras.length < 2) return;
    final newDirection = _isFrontCamera
        ? CameraLensDirection.back
        : CameraLensDirection.front;
    final target = cameras.firstWhere(
      (c) => c.lensDirection == newDirection,
      orElse: () => cameras.first,
    );
    await cameraController?.dispose();
    final newController = CameraController(target, ResolutionPreset.high);
    await newController.initialize();
    if (mounted) {
      setState(() {
        cameraController = newController;
        _isFrontCamera = !_isFrontCamera;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildUI());
  }

  Widget _buildUI() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return SafeArea(
      child: SizedBox.expand(
        child: Stack(
          children: [
            // Full-screen camera preview
            SizedBox(
              height: MediaQuery.sizeOf(context).height,
              width: MediaQuery.sizeOf(context).width,
              child: CameraPreview(cameraController!),
            ),
            // Flip camera button (top right)
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: _flipCamera,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flip_camera_ios,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
            // Bottom control bar
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Speaker button
                  _CallButton(
                    icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                    label: _isSpeakerOn ? 'Speaker' : 'Speaker Off',
                    backgroundColor: Colors.white24,
                    onTap: () {
                      setState(() {
                        _isSpeakerOn = !_isSpeakerOn;
                      });
                    },
                  ),
                  // End call button
                  _CallButton(
                    icon: Icons.call_end,
                    label: 'End Call',
                    backgroundColor: Colors.red,
                    iconColor: Colors.white,
                    size: 68,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  // Mute button
                  _CallButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    backgroundColor: Colors.white24,
                    onTap: () {
                      setState(() {
                        _isMuted = !_isMuted;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final VoidCallback onTap;

  const _CallButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onTap,
    this.iconColor = Colors.white,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: size * 0.45),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}