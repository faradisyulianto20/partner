import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeHistory extends StatefulWidget {
  const HomeHistory({super.key});

  @override
  State<HomeHistory> createState() => _HomeHistoryState();
}

class _HomeHistoryState extends State<HomeHistory> {
  final List<Map<String, String>> weekData = [
    {'day': 'Jum', 'emotion': 'OVT', 'icon': 'sad'},
    {'day': 'Sab', 'emotion': 'Damai', 'icon': 'happy'},
    {'day': 'Min', 'emotion': 'Tenang', 'icon': 'happy'},
    {'day': 'Sen', 'emotion': 'Kesepian', 'icon': 'sad'},
    {'day': 'Sel', 'emotion': 'Sedih', 'icon': 'sad'},
    {'day': 'Rab', 'emotion': 'Insecure', 'icon': 'sad'},
    {'day': 'Kam', 'emotion': 'Bahagia', 'icon': 'happy'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1B517A),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat Emosi',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1B517A),
                ),
              ),
              Text(
                '7 hari terakhir',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                weekData.length,
                (index) => Padding(
                  padding: EdgeInsets.only(right: index < weekData.length - 1 ? 6 : 0),
                  child: _buildEmotionDay(
                    day: weekData[index]['day']!,
                    emotion: weekData[index]['emotion']!,
                    iconType: weekData[index]['icon']!,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionDay({
    required String day,
    required String emotion,
    required String iconType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: iconType == 'happy' ? const Color(0xFFF4F9FF) : const Color(0xFFFDF5EB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Color(0xFFE9E9E9),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B517A),
            ),
          ),
          const SizedBox(height: 12),
          SvgPicture.asset(
                iconType == 'happy'
                    ? 'assets/images/happy.svg'
                    : 'assets/images/sad.svg',
                width: 16,
                height: 16,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 31,
            child: Text(
              emotion,
              style: GoogleFonts.nunito(
                fontSize: 7,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1B517A),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
