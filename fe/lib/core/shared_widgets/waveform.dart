import 'dart:math';
import 'package:flutter/material.dart';

class Waveform extends StatelessWidget {
  final bool isActive;
  final double animValue;
  final int barCount;
  final double barWidth;
  final double barSpacing;
  final double minHeight;
  final double maxHeight;
  final Color activeColor;
  final Color idleColor;

  const Waveform({
    super.key,
    required this.isActive,
    required this.animValue,
    this.barCount = 23,
    this.barWidth = 8,
    this.barSpacing = 6,
    this.minHeight = 6,
    this.maxHeight = 160,
    this.activeColor = const Color.fromRGBO(45, 106, 159, 0.90),
    this.idleColor = const Color.fromRGBO(45, 106, 159, 0.30),
  });

  // Pola diamond: kecil di tepi, besar di tengah, simetris
  static const List<double> _baseHeights = [
    10, 18, 30, 46, 64, 84, 104, 124,
    138, 148, 154, 158, 154, 148, 138,
    124, 104, 84, 64, 46, 30, 18, 10,
  ];

  // Gradient biru muda (tepi) → biru tua (tengah), simetris
  static const List<Color> _gradientColors = [
    Color(0xFFC8DFF5), Color(0xFFB5D4F4), Color(0xFF9AC8F0),
    Color(0xFF85B7EB), Color(0xFF6FA8E6), Color(0xFF5798DF),
    Color(0xFF4A8ED8), Color(0xFF3A84D2), Color(0xFF378ADD),
    Color(0xFF2E7DC8), Color(0xFF2672B8), Color(0xFF1E68AA),
    Color(0xFF2672B8), Color(0xFF2E7DC8), Color(0xFF378ADD),
    Color(0xFF3A84D2), Color(0xFF4A8ED8), Color(0xFF5798DF),
    Color(0xFF6FA8E6), Color(0xFF85B7EB), Color(0xFF9AC8F0),
    Color(0xFFB5D4F4), Color(0xFFC8DFF5),
  ];

  @override
  Widget build(BuildContext context) {
    final safeCount = barCount.clamp(1, _baseHeights.length);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(safeCount, (i) {
        double height;

        if (isActive) {
          final phase = (animValue + i / safeCount) % 1.0;
          final wave = (sin(phase * 2 * pi) + 1) / 2;
          final base = _baseHeights[i];
          height = base * 0.4 + base * 0.65 * wave;
        } else {
          // Idle: tampilkan siluet diamond kecil
          height = (_baseHeights[i] * 0.09).clamp(minHeight, 14.0);
        }

        final color = i < _gradientColors.length
            ? _gradientColors[i].withOpacity(isActive ? 0.90 : 0.30)
            : (isActive ? activeColor : idleColor);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: barSpacing / 2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            width: barWidth,
            height: height.clamp(minHeight, maxHeight),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}