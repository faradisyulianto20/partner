import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hackathon/core/theme/app_gradients.dart';

class MascotBadge extends StatefulWidget {
  final double size;
  final bool isActive;
  final Color borderColor;
  final Color rippleColor;

  const MascotBadge({
    super.key,
    required this.size,
    this.isActive = true,
    this.borderColor = const Color(0xFF2F6FB4),
    this.rippleColor = const Color(0xFF2F6FB4),
  });

  @override
  State<MascotBadge> createState() => _MascotBadgeState();
}

class _MascotBadgeState extends State<MascotBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    if (widget.isActive) _controller.repeat();
  }

  @override
  void didUpdateWidget(MascotBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rippleAreaSize = widget.size;

    return SizedBox(
      width: rippleAreaSize,
      height: rippleAreaSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.isActive)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(rippleAreaSize, rippleAreaSize),
                  painter: _RipplePainter(
                    animValue: _controller.value,
                    color: widget.rippleColor,
                    rippleCount: 3,
                  ),
                );
              },
            ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: widget.borderColor),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  gradient: AppGradients.horizontal,
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.borderColor, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                    child: SvgPicture.asset(
                      'assets/images/mascot/mascot-white.svg',
                      width: widget.size * 0.7,
                      height: widget.size * 0.7,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double animValue;
  final Color color;
  final int rippleCount;

  _RipplePainter({
    required this.animValue,
    required this.color,
    this.rippleCount = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;

    for (int i = 0; i < rippleCount; i++) {
      final delay = i / rippleCount;
      final progress = (animValue + delay) % 1.0;
      final radius = baseRadius + (progress * baseRadius * 0.6);
      final opacity = (1.0 - progress) * 0.6;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RipplePainter old) => old.animValue != animValue;
}
