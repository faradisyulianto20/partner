import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackathon/core/theme/app_gradients.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF194F78),
      body: Stack(
        children: [
          Column(
            children: [
              // Top blue section (logo)
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(gradient: AppGradients.vertical),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 92),
                      SvgPicture.asset(
                        'assets/images/logo/logo-partner.svg',
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
          // Bottom white section
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 50,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Selamat datang di Partner',
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Ruang aman untuk berbagi perasaan,\nmenemukan dukungan, dan merasa dipahami',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Pilih peranmu untuk memulai perjalanan',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Tombol Sebagai User
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppGradients.horizontal,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => context.go('/login'),
                              borderRadius: BorderRadius.circular(30),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                child: Center(
                                  child: Text(
                                    'Sebagai user',
                                    style: GoogleFonts.nunito(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tombol Sebagai Psikolog
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.go('/login'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Sebagai Psikolog',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: const Color(0xFF294669),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
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
