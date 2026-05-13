import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';

class RecomendationDialog extends StatefulWidget {
  const RecomendationDialog({super.key});

  @override
  State<RecomendationDialog> createState() => _RecomendationDialogState();
}

class _RecomendationDialogState extends State<RecomendationDialog> {

  final String? message = 'Berdasarkan analisis emosi Anda hari ini, kami mendeteksi adanya stres yang cukup tinggi. Kami menyarankan Anda untuk mencoba beberapa teknik relaksasi seperti meditasi atau pernapasan dalam untuk membantu meredakan stres tersebut.';
  final List<Map<String, String>> recommendations = [
    {
      'title': 'Meditasi 5 Menit',
      'description': 'Luangkan waktu sejenak untuk duduk tenang dan fokus pada pernapasan Anda. Cobalah meditasi sederhana selama 5 menit untuk membantu menenangkan pikiran.'
    },
    {
      'title': 'Jurnal Emosi',
      'description': 'Tuliskan apa yang Anda rasakan hari ini. Menulis dapat membantu Anda memproses emosi dan mendapatkan perspektif baru.'
    },
    {
      'title': 'Berjalan di Alam',
      'description': 'Jika memungkinkan, cobalah berjalan-jalan di taman atau area hijau terdekat. Berada di alam dapat membantu meredakan stres dan meningkatkan suasana hati.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Analisis dan Rekomendasi AI',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B517A),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF1B517A),
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Analisis Emosi box
              DottedBorder(
                options: RoundedRectDottedBorderOptions(
                   color: const Color(0xFF3D7AB5),
                    strokeWidth: 2,
                    dashPattern: const [10, 10],
                    radius: const Radius.circular(12),
                    // customPath: (size) {
                    //   final path = Path();
                    //   path.moveTo(0, 0);
                    //   path.lineTo(size.width, 0);
                    //   path.lineTo(size.width, size.height);
                    //   path.lineTo(0, size.height);
                    //   path.close();
                    //   return path;
                    // },
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: const Color(0xFFF4F9FF),
                      borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.psychology_outlined,
                            color: Color(0xFF3D7AB5),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Analisis Emosi',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF3D7AB5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message ?? '',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Recommendations list
              if (recommendations.isNotEmpty)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: recommendations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final rec = recommendations[index];
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F7F5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border(
                            left: BorderSide(
                              color: const Color(0xFF3FB582),
                              width: 6,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec['title'] ?? '',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF148D63),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              rec['description'] ?? '',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF148D63),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );  
  }
}