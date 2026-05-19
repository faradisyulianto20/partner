import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

class ResultSummary extends StatelessWidget {
  const ResultSummary({
    super.key,
    required this.date,
    required this.time,
    required this.feeling,
    required this.description,
    required this.emotionIcon,
  });

  final String date;
  final String time;
  final String feeling;
  final String description;
  final String emotionIcon;

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF1B517A);
    const Color accent = Color(0xFF945FB2);
    const Color accentFill = Color(0xFFE9DEEF);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 36),
          padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$date  •  $time',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8A94A6),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    const TextSpan(text: 'Kamu sedang merasa '),
                    TextSpan(
                      text: feeling.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.grey, height: 1),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: primary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        CustomPaint(
          // Panggil painter yang tadi kita buat di sini
          painter: HalfBorderPainter(
            color: Colors.grey,
            strokeWidth: 1.5, // Ketebalan border setengah lingkaran
          ),
          child: Container(
            height: 72,
            width: 72,
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F4F6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(emotionIcon, width: 72, height: 72),
            ),
          ),
        ),
      ],
    );
  }
}

class HalfBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  HalfBorderPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // Membuat ujung border jadi bulat rapi

    // Menggambar busur setengah lingkaran di bagian atas (180 derajat)
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      0, // Titik mulai (9 posisi jam 9 malam)
      math.pi, // Jarak putaran (180 derajat ke arah jam 3 sore)
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
