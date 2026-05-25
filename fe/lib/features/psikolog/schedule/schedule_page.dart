import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:google_fonts/google_fonts.dart';
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

  late final List<DateTime> _dates;
  late final Map<DateTime, List<_ScheduleItem>> _scheduleByDate;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _dates = List.generate(
      6,
      (index) => _dateOnly(today.add(Duration(days: index))),
    );
    _selectedDate = _dates.first;
    _scheduleByDate = _buildSchedule(today);
  }

  @override
  Widget build(BuildContext context) {
    final sessionsToday = _scheduleByDate[_selectedDate] ?? [];
    final sessionCount = sessionsToday
        .where((item) => item.status != _ScheduleStatus.rest)
        .length;

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
              if (sessionsToday.isEmpty)
                _buildEmptyState()
              else
                Column(
                  children: sessionsToday
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

  Widget _buildDateStrip() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _dates.map((date) {
        final isSelected = _selectedDate == date;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: InkWell(
            onTap: () => setState(() => _selectedDate = date),
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
        // <--- 1. Bungkus dengan ini
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // <--- 2. Ubah ke stretch
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
                    // <--- 3. Ubah dari height: 86 menjadi Expanded
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
                    : () => _openDetailSheet(item),
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
                            mainAxisAlignment: MainAxisAlignment
                                .spaceBetween, // <--- MEMAKSA PILL STATUS DI KANAN POJOK
                            children: [
                              Expanded(
                                // Agar teks nama panjang tidak merusak layout
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
      alignment: Alignment.centerRight, // <--- MEMAKSA PILL KE KANAN
      child: _buildStatusPill(item.status),
    ),
                                  ],
                                ),
                              ),
                              // Spacing aman sebelum status pill
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

  void _openDetailSheet(_ScheduleItem item) {
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

  int _countForDate(DateTime date) {
    final list = _scheduleByDate[date] ?? [];
    return list.where((item) => item.status != _ScheduleStatus.rest).length;
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

  Map<DateTime, List<_ScheduleItem>> _buildSchedule(DateTime today) {
    return {
      _dateOnly(today): [
        const _ScheduleItem(
          time: '09:00',
          name: 'Alana Francisco',
          age: '32 Tahun',
          gender: 'Laki-laki',
          type: 'Chat',
          mood: 'Cemas',
          note:
              'Aku cemas banget belum nikah sampai sekarang tapi banyak orang menanyakan kapan aku nikah di umur segini',
          status: _ScheduleStatus.done,
        ),
        const _ScheduleItem(
          time: '10:00',
          name: 'Tujo Bin Atala',
          age: '21 Tahun',
          gender: 'Laki-laki',
          type: 'Voice Call',
          mood: 'Kelelahan',
          note:
              'Aku tidak tahu bagaimana lagi menghadapi semua ini. Aku sangat capek tapi aku tidak tahu harus bagaimana selain aku menyelesaikan semua tanggungan yang aku punya sekarang',
          status: _ScheduleStatus.upcoming,
        ),
        const _ScheduleItem(
          time: '12:00',
          name: 'Waktu Istirahat',
          age: '-',
          gender: '-',
          type: 'Break',
          mood: '-',
          note: '-',
          status: _ScheduleStatus.rest,
        ),
        const _ScheduleItem(
          time: '13:00',
          name: 'Catline Putri',
          age: '24 Tahun',
          gender: 'Perempuan',
          type: 'Video Call',
          mood: 'Tenang',
          note: 'Aku ingin belajar mengelola kecemasan di tempat kerja.',
          status: _ScheduleStatus.upcoming,
        ),
        const _ScheduleItem(
          time: '15:00',
          name: 'Michael Alexiz',
          age: '27 Tahun',
          gender: 'Laki-laki',
          type: 'Chat',
          mood: 'Netral',
          note: 'Ingin konsultasi singkat terkait pola tidur.',
          status: _ScheduleStatus.upcoming,
        ),
      ],
      _dateOnly(today.add(const Duration(days: 1))): [
        const _ScheduleItem(
          time: '09:30',
          name: 'Nadia Mulyani',
          age: '30 Tahun',
          gender: 'Perempuan',
          type: 'Video Call',
          mood: 'Cemas',
          note: 'Aku khawatir tentang keseimbangan kerja dan keluarga.',
          status: _ScheduleStatus.upcoming,
        ),
      ],
      _dateOnly(today.add(const Duration(days: 2))): [
        const _ScheduleItem(
          time: '11:00',
          name: 'Ronaldo Pratama',
          age: '28 Tahun',
          gender: 'Laki-laki',
          type: 'Chat',
          mood: 'Bingung',
          note: 'Aku bingung menghadapi keputusan besar di karir.',
          status: _ScheduleStatus.upcoming,
        ),
      ],
      _dateOnly(today.add(const Duration(days: 3))): [],
      _dateOnly(today.add(const Duration(days: 4))): [
        const _ScheduleItem(
          time: '14:00',
          name: 'Ajeng Larasati',
          age: '26 Tahun',
          gender: 'Perempuan',
          type: 'Voice Call',
          mood: 'Tenang',
          note: 'Aku ingin menata ulang rutinitas yang lebih sehat.',
          status: _ScheduleStatus.upcoming,
        ),
      ],
      _dateOnly(today.add(const Duration(days: 5))): [
        const _ScheduleItem(
          time: '10:30',
          name: 'Doni Ardiansyah',
          age: '33 Tahun',
          gender: 'Laki-laki',
          type: 'Chat',
          mood: 'Cemas',
          note: 'Butuh saran untuk mengelola kecemasan sebelum presentasi.',
          status: _ScheduleStatus.upcoming,
        ),
      ],
    };
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
