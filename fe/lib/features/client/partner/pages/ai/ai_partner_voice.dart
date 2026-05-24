import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/theme/app_gradients.dart';
import 'package:hackathon/core/shared_widgets/waveform.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AIPartnerVoice extends StatefulWidget {
  const AIPartnerVoice({super.key});

  @override
  State<AIPartnerVoice> createState() => _AIPartnerVoiceState();
}

class _AIPartnerVoiceState extends State<AIPartnerVoice>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  bool _isRecording = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      if (!_isRecording) {
        _isRecording = true;
        _isPaused = false;
        return;
      }

      _isPaused = !_isPaused;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWaveActive = _isRecording && !_isPaused;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text('AI Partner Voice'),
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
            IconButton(
              icon: const Icon(Icons.message_rounded),
              onPressed: () => {},
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: AppGradients.horizontal),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  height: 80,
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, _) {
                      return Waveform(
                        isActive: isWaveActive,
                        animValue: _waveController.value,
                      );
                    },
                  ),
                ),
              ),
            ),
            _VoiceControlPanel(
              onToggle: _toggleRecording,
              isRecording: _isRecording,
              isPaused: _isPaused,
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceControlPanel extends StatelessWidget {
  final VoidCallback onToggle;
  final bool isRecording;
  final bool isPaused;

  const _VoiceControlPanel({
    required this.onToggle,
    required this.isRecording,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: 36,
            left: 24,
            right: 24,
            bottom: 64 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
        ),
        Positioned(
          top: -62,
          left: 0,
          right: 0,
          child: Center(child: _GradientMascotButton(onTap: onToggle)),
        ),
      ],
    );
  }
}

class _GradientMascotButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GradientMascotButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(102),
          border: Border.all(color: const Color(0xFF1B517A), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: Container(
            width: 112,
            height: 112,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppGradients.horizontal,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
                child: SvgPicture.asset(
                  'assets/images/mascot/mascot-white.svg',
                  width: 72,
                  height: 72,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
