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
    this.barCount = 10,
    this.barWidth = 10,
    this.barSpacing = 6, // Sekarang ini akan menjadi jarak murni antar bar
    this.minHeight = 6,
    this.maxHeight = 70,
    this.activeColor = const Color.fromRGBO(45, 106, 159, 0.8),
    this.idleColor = const Color.fromRGBO(45, 106, 159, 0.3),
  });

  static const List<double> _baseHeights = [
    10,
    18,
    30,
    45,
    55,
    62,
    58,
    48,
    36,
    22,
    14,
    22,
    36,
    48,
    58,
    62,
    55,
    45,
    30,
    18,
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
          height = base * 0.6 + base * 0.6 * wave;
        } else {
          height = 14.0;
        }

        return Padding(
          // Menggunakan Padding eksplisit agar aman di dalam Row
          padding: EdgeInsets.symmetric(horizontal: barSpacing / 2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            width: barWidth,
            height: height.clamp(minHeight, maxHeight),
            decoration: BoxDecoration(
              color: isActive ? activeColor : idleColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
