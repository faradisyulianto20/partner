import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/theme/app_gradients.dart';
import 'package:hackathon/features/client/partner/widgets/mascot_badge.dart';

class VoiceCall extends StatefulWidget {
  const VoiceCall({super.key});

  @override
  State<VoiceCall> createState() => _VoiceCallState();
}

class _VoiceCallState extends State<VoiceCall> {
  bool _isMuted = true;
  bool _isSpeakerOn = true;

  Future<void> _handleEndChat(BuildContext context) async {
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text(
            'Akhiri Chat dengan Mulyono?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight(800),
              color: Color(0xFF1B517A),
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppGradients.horizontal,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Akhiri'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2F5F8F),
                      side: const BorderSide(color: Color(0xFF2F5F8F)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldEnd == true && context.mounted) {
      context.go('/partner');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
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
            IconButton(
              icon: const Icon(Icons.videocam_outlined),
              onPressed: () => context.go('/partner/human-partner/video-call'),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _handleEndChat(context),
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: AppGradients.horizontal),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 82),
                  const MascotBadge(
                    size: 162,
                    isActive: false,
                    borderColor: Color(0xFF1B517A),
                    rippleColor: Color(0xFF1B517A),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Mulyono',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B517A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _StatusDot(),
                      SizedBox(width: 6),
                      Text(
                        'Menelpon',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7C8CA0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 42,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: const Color(0xFF1B517A)),
                    ),
                    child: const Text(
                      '05:30',
                      style: TextStyle(
                        color: Color(0xFF1B517A),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                top: 18,
                bottom: 24 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                    onTap: () => context.go('/partner/human-partner/end-call'),
                  ),
                  _CallControlButton(
                    icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                    color: const Color(0xFF1B517A),
                    onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
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

class _StatusDot extends StatelessWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Color(0xFF5DBB78),
        shape: BoxShape.circle,
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
    this.size = 82,
    this.iconSize = 42,
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
