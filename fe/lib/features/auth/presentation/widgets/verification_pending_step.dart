import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackathon/core/theme/app_gradients.dart';

class VerificationPendingStep extends StatefulWidget {
  final VoidCallback onBackToLogin;

  const VerificationPendingStep({super.key, required this.onBackToLogin});

  @override
  State<VerificationPendingStep> createState() =>
      _VerificationPendingStepState();
}

class _VerificationPendingStepState extends State<VerificationPendingStep> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle_outline,
                  size: 54,
                  color: Color(0xFF578BB3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Verifikasi Sedang Diproses!',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Profil dan dokumen profesional Anda sedang dalam proses verifikasi oleh tim PARTNER. Informasi hasil peninjauan akan dikirimkan melalui email yang telah terdaftar.',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onBackToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF194F78),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Kembali ke Login',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
