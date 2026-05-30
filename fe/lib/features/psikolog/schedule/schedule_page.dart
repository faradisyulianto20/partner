import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackathon/core/constants.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/core/shared_widgets/header.dart';
import 'package:hackathon/core/shared_widgets/psychologist_detail_sheet.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final Color _primaryColor = const Color(0xFF1B517A);
  final Color _softBlue = const Color(0xFF7DA0C4);
  final Color _lineBlue = const Color(0xFF2F6DA5);

  late final ApiClient _apiClient = ApiClient(
    baseUrl: AppConstants.baseUrl,
    autoLoadToken: true,
  );

  late final List<DateTime> _dates;
  late DateTime _selectedDate;
  List<_ScheduleItem> _sessions = [];
  bool _isLoading = false;

  int _totalSessionsToday = 0;
  int _monthlyIncome = 0;
  Map<String, dynamic>? _nextSession;
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _upcomingSessions = [];
  bool _isDashboardLoading = false;

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _dates = List.generate(
      6,
      (index) => _dateOnly(today.add(Duration(days: index))),
    );
    _selectedDate = _dates.first;
    _fetchSessions(_selectedDate);
    _fetchDashboard();
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
            _requests = rawRequests
                .map((e) => e as Map<String, dynamic>)
                .toList();
          }

          final rawUpcoming = data['upcomingSessions'];
          if (rawUpcoming is List) {
            _upcomingSessions = rawUpcoming
                .map((e) => e as Map<String, dynamic>)
                .toList();
          }
        });
      }
    } catch (e) {
      debugPrint('Fetch dashboard error: $e');
    }

    if (!mounted) return;
    setState(() => _isDashboardLoading = false);
  }

  Future<void> _fetchSessions(DateTime date) async {
    setState(() => _isLoading = true);

    try {
      final dateStr = '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/psychologist/me/sessions',
        query: {'date': dateStr},
      );

      if (!mounted) return;

      if (response.isSuccess) {
        final rawTimeline = response.data['timeline'];
        final items = <_ScheduleItem>[];

        if (rawTimeline is List) {
          for (final entry in rawTimeline) {
            if (entry is! Map) continue;
            final type = entry['type'] as String?;

            if (type == 'BREAK') {
              items.add(_ScheduleItem(
                time: _extractTime(entry['startAt']),
                name: '',
                age: '',
                gender: '',
                type: '',
                mood: '',
                note: '',
                status: _ScheduleStatus.rest,
              ));
            } else if (type == 'SESSION') {
              final method = entry['method'] as String? ?? '';
              final statusRaw = entry['status'] as String? ?? '';
              items.add(_ScheduleItem(
                time: entry['timeLabel'] as String? ?? '',
                name: entry['fullName'] as String? ?? '',
                age: '',
                gender: '',
                type: _displayMethod(method),
                mood: entry['moodLabel'] as String? ?? '-',
                note: entry['notes'] as String? ?? '',
                status: _mapSessionStatus(statusRaw),
              ));
            }
          }
        }

        setState(() => _sessions = items);
      } else {
        if (!mounted) return;
        setState(() => _sessions = []);
      }
    } catch (e) {
      debugPrint('Fetch sessions error: $e');
      if (!mounted) return;
      setState(() => _sessions = []);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

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

  _ScheduleStatus _mapSessionStatus(String status) {
    switch (status) {
      case 'COMPLETED':
        return _ScheduleStatus.done;
      default:
        return _ScheduleStatus.upcoming;
    }
  }

  String _formatRupiah(int amount) {
    if (amount == 0) return 'Rp. 0';
    final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = amount.toString().replaceAllMapped(
      regExp,
      (Match m) => '${m[1]}.',
    );
    return 'Rp. $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final sessionCount =
        _sessions.where((item) => item.status != _ScheduleStatus.rest).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
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
              _buildSectionTitle('Jadwal Sesi Anda'),
              const SizedBox(height: 12),
              _buildDateStrip(),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatFullDate(_selectedDate),
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _primaryColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF0F7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _softBlue, width: 1),
                    ),
                    child: Text(
                      '${sessionCount.toString()} sesi',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_sessions.isEmpty)
                _buildEmptyState()
              else
                Column(
                  children: _sessions
                      .map((item) => _buildTimelineItem(item))
                      .toList(),
                ),
            ],
          ),
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

  Widget _buildStatsRow() {
    if (_isDashboardLoading) {
      return Row(
        children: const [
          Expanded(child: LinearProgressIndicator()),
        ],
      );
    }

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

  Widget _buildNextSessionCard(Map<String, dynamic> session) {
    final name = session['fullName'] as String? ?? '';
    final timeLabel = session['timeLabel'] as String? ??
        _extractTime(session['scheduledAt']);
    final method = session['method'] as String? ?? '';

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
                          Icon(Icons.schedule, size: 14, color: _primaryColor),
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
                    horizontal: 12,
                    vertical: 6,
                  ),
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
              options: RoundedRectDottedBorderOptions(
                color: const Color(0xFF3D7AB5),
                strokeWidth: 1,
                dashPattern: const [10, 10],
                radius: const Radius.circular(14),
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
                            text: (session['moodLabel'] as String?) ?? '-',
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
                            text: (session['notes'] as String?) ?? '-',
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
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF578BB3), Color(0xFF194F78)],
                      ),
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
                                const Icon(
                                  Icons.description,
                                  color: Colors.white,
                                  size: 16,
                                ),
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

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final name = request['fullName'] as String? ?? '';
    final method = request['method'] as String? ?? '';
    final timeLabel = _extractTime(request['scheduledAt']);

    return GestureDetector(
      onTap: () => _openRequestDetail(request),
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
                GestureDetector(
                  onTap: () {
                    // TODO: reject request
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE76F51).withValues(alpha: 0.12),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFFE76F51),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // TODO: accept request
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF578BB3), Color(0xFF194F78)],
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
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

  Widget _buildUpcomingSessionCard(Map<String, dynamic> session) {
    final name = session['fullName'] as String? ?? '';
    final method = session['method'] as String? ?? '';
    final timeLabel = session['timeLabel'] as String? ??
        _extractTime(session['scheduledAt']);

    return GestureDetector(
      onTap: () => _openSessionDetail(session, false),
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

  Widget _buildDateStrip() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _dates.map((date) {
          final isSelected = _selectedDate == date;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                setState(() => _selectedDate = date);
                _fetchSessions(date);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 54,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? _primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _softBlue, width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      _weekdayShort(date),
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      date.day.toString().padLeft(2, '0'),
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _softBlue, width: 1),
      ),
      child: Text(
        'Belum ada sesi di tanggal ini.',
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildTimelineItem(_ScheduleItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 54,
              child: Column(
                children: [
                  Text(
                    item.time,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        color: _lineBlue.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: item.status == _ScheduleStatus.rest
                    ? null
                    : () => _openTimelineDetail(item),
                child: DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    color: item.status == _ScheduleStatus.rest || item.status == _ScheduleStatus.done
                        ? Colors.black26
                        : const Color(0xFF3D7AB5),
                    strokeWidth: 2,
                    dashPattern: const [10, 10],
                    radius: const Radius.circular(14),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: item.status == _ScheduleStatus.rest
                          ? const Color(0xFFEFEFEF)
                          : item.status == _ScheduleStatus.done
                          ? const Color(0xFFE9E9E9)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: item.status == _ScheduleStatus.rest
                        ? Center(
                            child: Text(
                              'Waktu Istirahat',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                                color: Colors.black38,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color:
                                            item.status == _ScheduleStatus.done
                                            ? Colors.black54
                                            : _primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          _typeIcon(item.type),
                                          size: 16,
                                          color: Colors.black45,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          item.type,
                                          style: GoogleFonts.nunito(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: _buildStatusPill(item.status),
                                    ),
                                  ],
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
      ),
    );
  }

  Widget _buildStatusPill(_ScheduleStatus status) {
    if (status == _ScheduleStatus.rest) {
      return const SizedBox.shrink();
    }

    final isDone = status == _ScheduleStatus.done;
    final label = isDone ? 'Selesai' : 'Mendatang';
    final background = isDone ? const Color(0xFF8B8B8B) : _primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  void _openTimelineDetail(_ScheduleItem item) {
    final mode = item.status == _ScheduleStatus.done
        ? PsychologistDetailMode.done
        : PsychologistDetailMode.session;

    showPsychologistDetailSheet(
      context: context,
      data: PsychologistDetailData(
        name: item.name,
        age: item.age,
        gender: item.gender,
        time: item.time,
        type: item.type,
        mood: item.mood,
        note: item.note,
      ),
      mode: mode,
    );
  }

  void _openSessionDetail(Map<String, dynamic> session, bool isDone) {
    final name = session['fullName'] as String? ?? '';
    final timeLabel = session['timeLabel'] as String? ??
        _extractTime(session['scheduledAt']);
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
      mode: isDone ? PsychologistDetailMode.done : PsychologistDetailMode.session,
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
      onPrimaryTap: () {
        // TODO: accept request
        Navigator.pop(context);
      },
      onSecondaryTap: () {
        // TODO: reject request
        Navigator.pop(context);
      },
    );
  }

  String _weekdayShort(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Sen';
      case DateTime.tuesday:
        return 'Sel';
      case DateTime.wednesday:
        return 'Rab';
      case DateTime.thursday:
        return 'Kam';
      case DateTime.friday:
        return 'Jum';
      case DateTime.saturday:
        return 'Sab';
      case DateTime.sunday:
        return 'Min';
      default:
        return '';
    }
  }

  String _formatFullDate(DateTime date) {
    final weekdays = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final dayName = weekdays[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Video Call':
        return Icons.videocam;
      case 'Voice Call':
        return Icons.call;
      default:
        return Icons.chat_bubble;
    }
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

enum _ScheduleStatus { done, rest, upcoming }

class _ScheduleItem {
  final String time;
  final String name;
  final String age;
  final String gender;
  final String type;
  final String mood;
  final String note;
  final _ScheduleStatus status;

  const _ScheduleItem({
    required this.time,
    required this.name,
    required this.age,
    required this.gender,
    required this.type,
    required this.mood,
    required this.note,
    required this.status,
  });
}
