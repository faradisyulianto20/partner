import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackathon/core/constants.dart';
import 'package:hackathon/core/services/api_client.dart';
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
  final Color _primaryColor = const Color(0xFF1B517A);
  final Color _softBlue = const Color(0xFF7DA0C4);

  late final ApiClient _apiClient = ApiClient(
    baseUrl: AppConstants.baseUrl,
    autoLoadToken: true,
  );

  int _totalSessionsToday = 0;
  int _monthlyIncome = 0;
  Map<String, dynamic>? _nextSession;
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _upcomingSessions = [];
  bool _isDashboardLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  @override
  void dispose() {
    _apiClient.close();
    super.dispose();
  }

  Future<void> _fetchDashboard() async {
    setState(() => _isDashboardLoading = true);

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/psychologist/me/dashboard',
      );

      if (!mounted) return;

      if (response.isSuccess) {
        final data = response.data;
        final stats = data['stats'] as Map<String, dynamic>?;

        setState(() {
          _totalSessionsToday =
              (stats?['totalSessionsToday'] as num?)?.toInt() ?? 0;
          _monthlyIncome =
              (stats?['monthlyIncome'] as num?)?.toInt() ?? 0;
          _nextSession = data['nextSession'] as Map<String, dynamic>?;

          final rawRequests = data['requests'];
          if (rawRequests is List) {
            _requests =
                rawRequests.map((e) => e as Map<String, dynamic>).toList();
          }

          final rawUpcoming = data['upcomingSessions'];
          if (rawUpcoming is List) {
            _upcomingSessions =
                rawUpcoming.map((e) => e as Map<String, dynamic>).toList();
          }
        });
      }
    } catch (e) {
      debugPrint('Fetch dashboard error: $e');
    }

    if (!mounted) return;
    setState(() => _isDashboardLoading = false);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _extractTime(dynamic dateValue) {
    if (dateValue == null) return '';
    final s = dateValue.toString();
    if (s.length >= 16) return s.substring(11, 16);
    return s;
  }

  String _displayMethod(String method) {
    switch (method) {
      case 'VIDEO':
        return 'Video Call';
      case 'VOICE':
        return 'Voice Call';
      default:
        return 'Chat';
    }
  }

  String _formatRupiah(int amount) {
    if (amount == 0) return 'Rp. 0';
    final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = amount
        .toString()
        .replaceAllMapped(regExp, (Match m) => '${m[1]}.');
    return 'Rp. $formatted';
  }

  String _shortenNote(String note) {
    if (note.length <= 70) return note;
    return '${note.substring(0, 67)}...';
  }

  // ── Detail sheet openers ──────────────────────────────────────────────────

  void _openSessionDetail(Map<String, dynamic> session, bool isDone) {
    final name = session['fullName'] as String? ?? '';
    final timeLabel =
        session['timeLabel'] as String? ?? _extractTime(session['scheduledAt']);
    final method = session['method'] as String? ?? '';
    final moodLabel = session['moodLabel'] as String? ?? '-';
    final notes = session['notes'] as String? ?? '';

    showPsychologistDetailSheet(
      context: context,
      data: PsychologistDetailData(
        name: name,
        age: '',
        gender: '',
        time: timeLabel,
        type: _displayMethod(method),
        mood: moodLabel,
        note: notes,
      ),
      mode: isDone
          ? PsychologistDetailMode.done
          : PsychologistDetailMode.session,
      onPrimaryTap: () => Navigator.pop(context),
    );
  }

  void _openRequestDetail(Map<String, dynamic> request) {
    final name = request['fullName'] as String? ?? '';
    final method = request['method'] as String? ?? '';
    final notes = request['notes'] as String? ?? '';
    final timeLabel = _extractTime(request['scheduledAt']);

    showPsychologistDetailSheet(
      context: context,
      data: PsychologistDetailData(
        name: name,
        age: '',
        gender: '',
        time: timeLabel,
        type: _displayMethod(method),
        mood: '-',
        note: notes,
      ),
      mode: PsychologistDetailMode.request,
      onPrimaryTap: () => Navigator.pop(context),
      onSecondaryTap: () => Navigator.pop(context),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchDashboard,
          color: _primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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

                // ── Statistik ──
                _buildSectionTitle('Statistik'),
                const SizedBox(height: 12),
                _isDashboardLoading
                    ? const LinearProgressIndicator()
                    : _buildStatsRow(),

                // ── Sesi Selanjutnya ──
                if (_nextSession != null) ...[
                  const SizedBox(height: 20),
                  _buildSectionTitle('Sesi Selanjutnya'),
                  const SizedBox(height: 12),
                  _buildNextSessionCard(_nextSession!),
                ],

                // ── Permintaan Baru ──
                if (_requests.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildSectionTitle('Permintaan Baru'),
                  const SizedBox(height: 12),
                  ..._requests.map(
                    (req) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildRequestCard(req),
                    ),
                  ),
                ],

                // ── Sesi Mendatang ──
                if (_upcomingSessions.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildSectionTitle('Sesi Mendatang'),
                  const SizedBox(height: 12),
                  ..._upcomingSessions.map(
                    (up) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildUpcomingSessionCard(up),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section title ─────────────────────────────────────────────────────────

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

  // ── Stats row ─────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today,
            label: 'Total Sesi Hari Ini',
            value: _totalSessionsToday.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.account_balance_wallet,
            label: 'Pendapatan Bulan Ini',
            value: _formatRupiah(_monthlyIncome),
          ),
        ),
      ],
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
          Expanded(
            child: Column(
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
          ),
        ],
      ),
    );
  }

  // ── Next session card ─────────────────────────────────────────────────────

  Widget _buildNextSessionCard(Map<String, dynamic> session) {
    final name = session['fullName'] as String? ?? '';
    final timeLabel =
        session['timeLabel'] as String? ?? _extractTime(session['scheduledAt']);
    final method = session['method'] as String? ?? '';
    final moodLabel = session['moodLabel'] as String? ?? '-';
    final notes = session['notes'] as String? ?? '';

    return GestureDetector(
      onTap: () => _openSessionDetail(session, false),
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
                        name,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule,
                              size: 14, color: _primaryColor),
                          const SizedBox(width: 6),
                          Text(
                            timeLabel,
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
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _primaryColor, width: 1.2),
                  ),
                  child: Text(
                    _displayMethod(method),
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
              options: const RoundedRectDottedBorderOptions(
                color: Color(0xFF3D7AB5),
                strokeWidth: 1,
                dashPattern: [10, 10],
                radius: Radius.circular(14),
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
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          const TextSpan(text: 'Mood Terakhir: '),
                          TextSpan(
                            text: moodLabel,
                            style: GoogleFonts.nunito(
                              color: _primaryColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          const TextSpan(text: 'Catatan: '),
                          TextSpan(
                            text: _shortenNote(notes),
                            style: GoogleFonts.nunito(
                              color: _primaryColor,
                              fontWeight: FontWeight.w800,
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
                      gradient: AppGradients.horizontal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openSessionDetail(session, false),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.description,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 8),
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
                    onPressed: () => _openSessionDetail(session, false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _primaryColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: Icon(Icons.play_arrow,
                        size: 16, color: _primaryColor),
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

  // ── Request card ──────────────────────────────────────────────────────────

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final name = request['fullName'] as String? ?? '';
    final method = request['method'] as String? ?? '';
    final timeLabel = _extractTime(request['scheduledAt']);

    return GestureDetector(
      onTap: () => _openRequestDetail(request),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    name,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _primaryColor,
                    ),
                  ),
                  Text(
                    '$timeLabel - ${_displayMethod(method)}',
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
                  onTap: () {
                    // TODO: reject
                  },
                ),
                const SizedBox(width: 8),
                _buildActionCircle(
                  icon: Icons.check,
                  colorOrGradient: AppGradients.horizontal,
                  onTap: () {
                    // TODO: accept
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Upcoming session card ─────────────────────────────────────────────────

  Widget _buildUpcomingSessionCard(Map<String, dynamic> session) {
    final name = session['fullName'] as String? ?? '';
    final method = session['method'] as String? ?? '';
    final timeLabel = session['timeLabel'] as String? ??
        _extractTime(session['scheduledAt']);

    return GestureDetector(
      onTap: () => _openSessionDetail(session, false),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    name,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _primaryColor,
                    ),
                  ),
                  Text(
                    '$timeLabel - ${_displayMethod(method)}',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: _primaryColor),
          ],
        ),
      ),
    );
  }

  // ── Action circle button ──────────────────────────────────────────────────

  Widget _buildActionCircle({
    required IconData icon,
    required dynamic colorOrGradient,
    required VoidCallback onTap,
  }) {
    final isGradient = colorOrGradient is Gradient;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isGradient
              ? null
              : (colorOrGradient as Color).withValues(alpha: 0.12),
          gradient: isGradient ? (colorOrGradient as Gradient) : null,
        ),
        child: Icon(
          icon,
          color: isGradient ? Colors.white : (colorOrGradient as Color),
          size: 18,
        ),
      ),
    );
  }
}