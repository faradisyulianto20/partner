import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  // Vertical gradient
  final LinearGradient verticalGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF578BB3),
      Color(0xFF194F78),
    ],
  );

  // Horizontal gradient
  final LinearGradient horizontalGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF578BB3),
      Color(0xFF194F78),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF194F78),
      body: Stack(
        children: [
          Column(
            children: [
              // Top blue section
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: verticalGradient,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 92),
                      SvgPicture.asset(
                          'assets/images/logo-partner.svg',
                        width: 163,
                        height: 200,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
          // Bottom white section overlays the blue section
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 1,
              heightFactor: 1.9 / 4,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(42),
                    topRight: Radius.circular(42),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Text(
                        'Mulai Perjalanan Emosionalmu',
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Temukan dukungan emosional yang nyaman, aman,\ndan memahami dirimu',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 28),
                      // Google Signup Button
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
                            borderRadius: BorderRadius.circular(30),
                            gradient: horizontalGradient,
                          ),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(27),
                            child: InkWell(
                              onTap: () => context.go('/input-data'),
                              borderRadius: BorderRadius.circular(27),

                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/google-icon.svg',
                                      width: 20,
                                      height: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Lanjut dengan Google',
                                      style: GoogleFonts.nunito(
                                        fontSize: 15,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Divider,
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
