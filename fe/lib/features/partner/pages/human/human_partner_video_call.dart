import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/theme/app_gradients.dart';

class VideoCall extends StatefulWidget {
  const VideoCall({super.key});

  @override
  State<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  CameraController? _primaryController;
  CameraController? _secondaryController;
  bool _isMuted = true;
  bool _isCameraOff = false;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  @override
  void dispose() {
    _primaryController?.dispose();
    _secondaryController?.dispose();
    super.dispose();
  }

  Future<void> _initCameras() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final backCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    final frontCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.last,
    );

    final primaryController = CameraController(
      backCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await primaryController.initialize();

    // CameraController? secondaryController;
    // if (cameras.length > 1) {
    //   secondaryController = CameraController(
    //     frontCamera,
    //     ResolutionPreset.medium,
    //     enableAudio: false,
    //   );
    //   await secondaryController.initialize();
    // }

    if (!mounted) return;
    setState(() {
      _primaryController = primaryController;
      _secondaryController = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('Mulyono'),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '08:30',
              style: TextStyle(
                color: Color(0xFF1B517A),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.horizontal),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildPrimaryView()),
          Positioned(top: 24, right: 18, child: _buildSecondaryView()),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildControls(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryView() {
    final controller = _primaryController;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isCameraOff) {
      return Container(
        color: const Color(0xFF0B1D2A),
        child: const Center(
          child: Icon(Icons.videocam_off, color: Colors.white, size: 48),
        ),
      );
    }

    return CameraPreview(controller);
  }

  Widget _buildSecondaryView() {
    final controller = _secondaryController;
    return Container(
      width: 96,
      height: 132,
      decoration: BoxDecoration(
        color: const Color(0xFF0B1D2A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1B517A), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: controller != null && controller.value.isInitialized
            ? CameraPreview(controller)
            : const Center(child: Icon(Icons.person, color: Colors.white70)),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CallControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            color: const Color(0xFF1B517A),
            onTap: () => setState(() => _isMuted = !_isMuted),
          ),
          _CallControlButton(
            icon: Icons.call_end,
            color: const Color(0xFFE35B4E),
            size: 82,
            iconSize: 30,
            backgroundColor: const Color(0xFFF7DDDA),
            onTap: () => context.pop(),
          ),
          _CallControlButton(
            icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
            color: const Color(0xFF1B517A),
            onTap: () => setState(() => _isCameraOff = !_isCameraOff),
          ),
        ],
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  const _CallControlButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.size = 72,
    this.iconSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }
}
