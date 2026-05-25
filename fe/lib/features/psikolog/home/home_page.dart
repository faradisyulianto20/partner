import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackathon/core/shared_widgets/header.dart';
import 'package:hackathon/core/shared_widgets/psychologist_detail_sheet.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:hackathon/core/theme/app_gradients.dart';

class PsychologistHomePage extends StatefulWidget {
  const PsychologistHomePage({super.key});

  @override
  State<PsychologistHomePage> createState() => _PsychologistHomePageState();
}

class _PsychologistHomePageState extends State<PsychologistHomePage> {
  final _SessionData _nextSession = const _SessionData(
    name: 'Tujo Bin Atala',
    age: '21 Tahun',
    gender: 'Laki-laki',
    time: '10:00 WIB',
    type: 'Voice Call',
    mood: 'Kelelahan',
    note:
        'Aku tidak tahu bagaimana lagi menghadapi semua ini. Aku sangat capek tapi aku tidak tahu harus bagaimana selain aku menyelesaikan semua tanggungan yang aku punya sekarang',
  );

  final List<_RequestData> _pendingRequests = const [
    _RequestData(
      name: 'Suroto Ahmad',
      age: '32 Tahun',
      gender: 'Laki-laki',
      time: '14:00 WIB',
      dayLabel: 'Rabu',
      type: 'Video Call',
      mood: 'Cemas',
      note:
          'Aku cemas banget belum nikah sampai sekarang tapi banyak orang menanyakan kapan aku nikah di umur segini',
    ),
    _RequestData(
      name: 'Supra Bapak Jazali',
      age: '29 Tahun',
      gender: 'Laki-laki',
      time: '09:00 WIB',
      dayLabel: 'Kamis',
      type: 'Chat',
      mood: 'Bingung',
      note: 'Aku bingung harus mulai dari mana untuk cerita.',
    ),
  ];

  final LinearGradient _horizontalGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF578BB3), Color(0xFF194F78)],
  );

  final Color _primaryColor = const Color(0xFF1B517A);
  final Color _softBlue = const Color(0xFF7DA0C4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(
              userName: 'Dr. Shinta!',
              greeting: 'Selamat Pagi',
              onProfileTap: () {},
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Statistik'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.calendar_today,
                    label: 'Total Sesi Hari Ini',
                    value: '4 Sesi',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.account_balance_wallet,
                    label: 'Pendapatan Bulan Ini',
                    value: 'Rp. 3.500.000',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Sesi Selanjutnya'),
            const SizedBox(height: 12),
            _buildNextSessionCard(_nextSession),
            const SizedBox(height: 20),
            _buildSectionTitle('Permintaan Baru'),
            const SizedBox(height: 12),
            Column(
              children: _pendingRequests
                  .map(
                    (request) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildPendingRequestCard(request),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: _primaryColor,
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _softBlue, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: _primaryColor, size: 28),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextSessionCard(_SessionData session) {
    return GestureDetector(
      onTap: () => _showSessionDetail(session),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _softBlue, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFE3ECF6),
                  child: Icon(Icons.person, color: Color(0xFF4D6E8A)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.name,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 14, color: _primaryColor),
                          const SizedBox(width: 6),
                          Text(
                            session.time,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _primaryColor, width: 1.2),
                  ),
                  child: Text(
                    session.type,
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DottedBorder(
              options: RoundedRectDottedBorderOptions(
                color: const Color(
                  0xFF3D7AB5,
                ), // atau gunakan _softBlue sesuai kebutuhan Anda
                strokeWidth: 1,
                dashPattern: const [10, 10],
                radius: const Radius.circular(
                  14,
                ), // Disesuaikan dengan radius Container agar pas
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F7FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bagian Mood Terakhir
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.black54, // Warna default untuk label
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          const TextSpan(text: 'Mood Terakhir: '),
                          TextSpan(
                            text: '${session.mood}',
                            style: GoogleFonts.nunito(
                              color:
                                  _primaryColor, // Menggunakan warna primary Anda
                              fontWeight: FontWeight.w800, // Weight 800
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Bagian Catatan
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.black54, // Warna default untuk label
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          const TextSpan(text: 'Catatan: '),
                          TextSpan(
                            text: _shortenNote(session.note),
                            style: GoogleFonts.nunito(
                              color:
                                  _primaryColor, // Menggunakan warna primary Anda
                              fontWeight: FontWeight.w800, // Weight 800
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _horizontalGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showSessionDetail(session),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize
                                  .min, // Agar Row hanya memakan ruang seperlunya di dalam Center
                              children: [
                                const Icon(
                                  Icons.description, // Ikon dokumen
                                  color: Colors.white,
                                  size: 16, // Anda bisa sesuaikan ukurannya
                                ),
                                const SizedBox(
                                  width: 8,
                                ), // Jarak antara ikon dan teks
                                Text(
                                  'Detail',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSessionDetail(session),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _primaryColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: Icon(
                      Icons.play_arrow,
                      size: 16,
                      color: _primaryColor,
                    ),
                    label: Text(
                      'Mulai Sesi',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestCard(_RequestData request) {
    return GestureDetector(
      onTap: () => _showPendingDetail(request),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _softBlue, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.name,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _primaryColor,
                    ),
                  ),
                  Text(
                    '${request.dayLabel}, ${request.time} - ${request.type}',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                _buildActionCircle(
                  icon: Icons.close,
                  colorOrGradient: const Color(0xFFE76F51),
                ),
                const SizedBox(width: 8),
                _buildActionCircle(
                  icon: Icons.check,
                  colorOrGradient: AppGradients.horizontal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCircle({
    required IconData icon,
    required dynamic colorOrGradient, // Menerima Color atau Gradient
  }) {
    final isGradient = colorOrGradient is Gradient;

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Jika warna solid, buat background soft (alpha 0.12)
        color: isGradient
            ? null
            : (colorOrGradient as Color).withValues(alpha: 0.12),
        // Jika gradient, gunakan gradient-nya langsung
        gradient: isGradient ? (colorOrGradient as Gradient) : null,
      ),
      child: Icon(
        icon,
        // Jika background-nya gradient, warna ikon diganti putih agar kontras
        color: isGradient ? Colors.white : (colorOrGradient as Color),
        size: 18,
      ),
    );
  }

  String _shortenNote(String note) {
    if (note.length <= 70) {
      return note;
    }
    return '${note.substring(0, 67)}...';
  }

  void _showSessionDetail(_SessionData session) {
    showPsychologistDetailSheet(
      context: context,
      data: _toDetailDataFromSession(session),
      mode: PsychologistDetailMode.session,
      onPrimaryTap: () => Navigator.pop(context),
    );
  }

  void _showPendingDetail(_RequestData request) {
    showPsychologistDetailSheet(
      context: context,
      data: _toDetailDataFromRequest(request),
      mode: PsychologistDetailMode.request,
      onPrimaryTap: () => Navigator.pop(context),
      onSecondaryTap: () => Navigator.pop(context),
    );
  }

  PsychologistDetailData _toDetailDataFromSession(_SessionData session) {
    return PsychologistDetailData(
      name: session.name,
      age: session.age,
      gender: session.gender,
      time: session.time,
      type: session.type,
      mood: session.mood,
      note: session.note,
    );
  }

  PsychologistDetailData _toDetailDataFromRequest(_RequestData request) {
    return PsychologistDetailData(
      name: request.name,
      age: request.age,
      gender: request.gender,
      time: request.time,
      type: request.type,
      mood: request.mood,
      note: request.note,
    );
  }
}

class _SessionData {
  const _SessionData({
    required this.name,
    required this.age,
    required this.gender,
    required this.time,
    required this.type,
    required this.mood,
    required this.note,
  });

  final String name;
  final String age;
  final String gender;
  final String time;
  final String type;
  final String mood;
  final String note;
}

class _RequestData {
  const _RequestData({
    required this.name,
    required this.age,
    required this.gender,
    required this.time,
    required this.dayLabel,
    required this.type,
    required this.mood,
    required this.note,
  });

  final String name;
  final String age;
  final String gender;
  final String time;
  final String dayLabel;
  final String type;
  final String mood;
  final String note;
}
