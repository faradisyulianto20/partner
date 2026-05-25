import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Header extends StatelessWidget {
  final String userName;
  final String greeting;
  final VoidCallback? onProfileTap;

  const Header({
    super.key,
    this.userName = 'User',
    this.greeting = 'Selamat Pagi',
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: const [
        Color(0xFF578BB3),
        Color(0xFF194F78),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: horizontalGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting + ', ' + userName,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                    'Bagaimana perasaanmu hari ini?',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: Color(0xFF1B517A),
                    size: 28,
                  ),
                ),
              ),
              SizedBox(width: 12),
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
