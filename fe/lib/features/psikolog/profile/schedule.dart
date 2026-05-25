import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  final Color _primaryColor = const Color(0xFF1B517A);
  final Color _softBlue = const Color(0xFF7DA0C4);

  late final List<_DaySchedule> _days;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _days = [
      _DaySchedule(
        label: 'Senin',
        start: '09:00',
        end: '17:00',
        isActive: true,
      ),
      _DaySchedule(
        label: 'Selasa',
        start: '09:00',
        end: '17:00',
        isActive: true,
      ),
      _DaySchedule(label: 'Rabu', start: '09:00', end: '17:00', isActive: true),
      _DaySchedule(
        label: 'Kamis',
        start: '09:00',
        end: '17:00',
        isActive: true,
      ),
      _DaySchedule(
        label: 'Jumat',
        start: '09:00',
        end: '15:00',
        isActive: true,
      ),
      _DaySchedule(
        label: 'Sabtu',
        start: '09:00',
        end: '17:00',
        isActive: false,
      ),
      _DaySchedule(
        label: 'Minggu',
        start: '09:00',
        end: '17:00',
        isActive: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Pengaturan Jadwal',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 16),
              Column(
                children: _days
                    .map(
                      (day) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildDayCard(day),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FA),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: _buildSaveButton(),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF1F4C7A), Color(0xFF0E3A63)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jam Praktik Mingguan',
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            'Klien hanya dapat memesan sesi pada rentang waktu yang Anda aktifkan di bawah ini',
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(_DaySchedule day) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  day.label,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _primaryColor,
                  ),
                ),
              ),
              Transform.scale(
                scale:
                    0.8, // <--- Angka di bawah 1.0 untuk memperkecil (misal jadi 80%)
                child: Switch(
                  value: day.isActive,
                  onChanged: (value) => setState(() => day.isActive = value),
                  activeThumbColor: Colors.white,
                  activeTrackColor: _primaryColor,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade300,
                  trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) => Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
          if (day.isActive) ...[
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    label: day.start,
                    onTap: () => _pickTime(day, true),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '—',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeField(
                    label: day.end,
                    onTap: () => _pickTime(day, false),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeField({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _softBlue, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime(_DaySchedule day, bool isStart) async {
    final initial = _parseTime(isStart ? day.start : day.end);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked == null) return;

    setState(() {
      final formatted = _formatTime(picked);
      if (isStart) {
        day.start = formatted;
      } else {
        day.end = formatted;
      }
    });
  }

  Future<void> _saveSchedule() async {
    for (final day in _days) {
      if (!day.isActive) continue;
      if (!_isValidRange(day.start, day.end)) {
        _showSnackBar('Jam ${day.label} tidak valid.');
        return;
      }
    }

    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isSaving = false);
    _showSnackBar('Jadwal berhasil disimpan.');
  }

  bool _isValidRange(String start, String end) {
    final startTime = _parseTime(start);
    final endTime = _parseTime(end);
    return endTime.hour > startTime.hour ||
        (endTime.hour == startTime.hour && endTime.minute > startTime.minute);
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveSchedule,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: _isSaving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save, color: Colors.white, size: 18),
        label: Text(
          _isSaving ? 'Menyimpan...' : 'Simpan Jadwal',
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _DaySchedule {
  final String label;
  String start;
  String end;
  bool isActive;

  _DaySchedule({
    required this.label,
    required this.start,
    required this.end,
    required this.isActive,
  });
}
