import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Model ──────────────────────────────────────────────────────────────────

enum SessionMethod { chat, voice, video }

enum SessionStatus { waiting, done, cancelled }

class AppointmentSession {
  final String id;
  final String psychologistId;
  final String psychologistName;
  final String psychologistSpecialization;
  final SessionMethod method;
  final SessionStatus status;
  final DateTime scheduledAt;
  double? myRating;

  AppointmentSession({
    required this.id,
    required this.psychologistId,
    required this.psychologistName,
    required this.psychologistSpecialization,
    required this.method,
    required this.status,
    required this.scheduledAt,
    this.myRating,
  });
}

// ── Page ───────────────────────────────────────────────────────────────────

class MyAppointments extends StatefulWidget {
  const MyAppointments({super.key});

  @override
  State<MyAppointments> createState() => _MyAppointmentsState();
}

class _MyAppointmentsState extends State<MyAppointments> {
  // Demo data — ganti dengan fetch API nanti
  final List<AppointmentSession> _sessions = [
    AppointmentSession(
      id: '1',
      psychologistId: '5be3c8e1-b37d-49e8-91c0-771d698f46af',
      psychologistName: 'Dr. Priantara, M.Psi',
      psychologistSpecialization: 'Psikolog Klinis',
      method: SessionMethod.video,
      status: SessionStatus.waiting,
      scheduledAt: DateTime.now().add(const Duration(hours: 2)),
    ),
    AppointmentSession(
      id: '2',
      psychologistId: '5be3c8e1-b37d-49e8-91c0-771d698f46af',
      psychologistName: 'Dr. Priantara, M.Psi',
      psychologistSpecialization: 'Psikolog Klinis',
      method: SessionMethod.chat,
      status: SessionStatus.done,
      scheduledAt: DateTime(2026, 11, 20, 14, 0),
    ),
    AppointmentSession(
      id: '3',
      psychologistId: '5be3c8e1-b37d-49e8-91c0-771d698f46af',
      psychologistName: 'Dr. Priantara, M.Psi',
      psychologistSpecialization: 'Psikolog Klinis',
      method: SessionMethod.chat,
      status: SessionStatus.done,
      scheduledAt: DateTime(2026, 11, 20, 14, 0),
      myRating: 5,
    ),
    AppointmentSession(
      id: '4',
      psychologistId: '5be3c8e1-b37d-49e8-91c0-771d698f46af',
      psychologistName: 'Dr. Priantara, M.Psi',
      psychologistSpecialization: 'Psikolog Klinis',
      method: SessionMethod.voice,
      status: SessionStatus.cancelled,
      scheduledAt: DateTime(2026, 11, 20, 14, 0),
    ),
  ];

  List<AppointmentSession> get _upcoming => _sessions
      .where((s) => s.status == SessionStatus.waiting)
      .toList()
    ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

  List<AppointmentSession> get _history => _sessions
      .where((s) => s.status != SessionStatus.waiting)
      .toList()
    ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

  // ── Helpers ──

  String _formatScheduled(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay = DateTime(dt.year, dt.month, dt.day);
    final dayLabel = sessionDay == today ? 'Hari ini' : _formatDate(dt);
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$dayLabel, $hour:$minute WIB';
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  bool _isSessionReady(DateTime scheduledAt) {
    final now = DateTime.now();
    // Enable jika sudah waktunya (dalam 15 menit sebelum atau sudah lewat)
    return now.isAfter(scheduledAt.subtract(const Duration(minutes: 15)));
  }

  IconData _methodIcon(SessionMethod method) {
    switch (method) {
      case SessionMethod.chat:
        return Icons.chat_bubble_outline_rounded;
      case SessionMethod.voice:
        return Icons.graphic_eq_rounded;
      case SessionMethod.video:
        return Icons.videocam_outlined;
    }
  }

  String _methodLabel(SessionMethod method) {
    switch (method) {
      case SessionMethod.chat:
        return 'Chat';
      case SessionMethod.voice:
        return 'Voice Call';
      case SessionMethod.video:
        return 'Video Call';
    }
  }

  // ── Dialogs ──

  Future<void> _showReviewDialog(AppointmentSession session) async {
    double selectedRating = 0;
    final commentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Beri Ulasan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F4C7A),
                  ),
                ),
                const SizedBox(height: 16),
                // Bintang rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () =>
                          setDialogState(() => selectedRating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          i < selectedRating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFFFC107),
                          size: 36,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                // Text field ulasan
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFBFD0E6)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: commentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan ulasan',
                      hintStyle: TextStyle(
                          color: Color(0xFFB0C4D8), fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedRating == 0
                        ? null
                        : () {
                            setState(() => session.myRating = selectedRating);
                            Navigator.pop(ctx);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F4C7A),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFBFD0E6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kirim Ulasan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    commentController.dispose();
  }

  Future<void> _showCancelDialog(AppointmentSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Apakah anda yakin untuk\nMembatalkan Sesi?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F4C7A),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE46E63),
                        side: const BorderSide(color: Color(0xFFE46E63)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1F4C7A),
                        side: const BorderSide(color: Color(0xFF1F4C7A)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Tidak',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      setState(() {
        final idx = _sessions.indexWhere((s) => s.id == session.id);
        if (idx != -1) {
          _sessions[idx] = AppointmentSession(
            id: session.id,
            psychologistId: session.psychologistId,
            psychologistName: session.psychologistName,
            psychologistSpecialization: session.psychologistSpecialization,
            method: session.method,
            status: SessionStatus.cancelled,
            scheduledAt: session.scheduledAt,
            myRating: session.myRating,
          );
        }
      });
    }
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4D79A6),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Partner Profesional',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Sesi Akan Datang ──
              const Text(
                'Sesi Akan Datang',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F3B59),
                ),
              ),
              const SizedBox(height: 12),
              if (_upcoming.isEmpty)
                _EmptyCard(label: 'Belum ada sesi yang akan datang.')
              else
                ..._upcoming.map((s) => _UpcomingCard(
                      session: s,
                      formatScheduled: _formatScheduled,
                      methodIcon: _methodIcon,
                      methodLabel: _methodLabel,
                      isReady: _isSessionReady(s.scheduledAt),
                      onCancel: () => _showCancelDialog(s),
                    )),

              const SizedBox(height: 28),

              // ── Riwayat ──
              const Text(
                'Riwayat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F3B59),
                ),
              ),
              const SizedBox(height: 12),
              if (_history.isEmpty)
                _EmptyCard(label: 'Belum ada riwayat sesi.')
              else
                ..._history.map((s) => _HistoryCard(
                      session: s,
                      formatScheduled: _formatScheduled,
                      methodIcon: _methodIcon,
                      methodLabel: _methodLabel,
                      onReview: () => _showReviewDialog(s),
                      onKonsultasiLagi: () => context.push(
                        '/partner/professional-partner/detail/${s.psychologistId}',
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Upcoming Card ──────────────────────────────────────────────────────────

class _UpcomingCard extends StatelessWidget {
  final AppointmentSession session;
  final String Function(DateTime) formatScheduled;
  final IconData Function(SessionMethod) methodIcon;
  final String Function(SessionMethod) methodLabel;
  final bool isReady;
  final VoidCallback onCancel;

  const _UpcomingCard({
    required this.session,
    required this.formatScheduled,
    required this.methodIcon,
    required this.methodLabel,
    required this.isReady,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header psikolog
          _PsychologistHeader(
            name: session.psychologistName,
            specialization: session.psychologistSpecialization,
          ),
          const Divider(height: 20, color: Color(0xFFE1E8F2)),

          // Metode & status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F4C7A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(methodIcon(session.method),
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      methodLabel(session.method),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F3B59),
                      ),
                    ),
                    Text(
                      formatScheduled(session.scheduledAt),
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              // Badge status
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBFD0E6)),
                ),
                child: const Text(
                  'Menunggu Sesi',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF1F4C7A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tombol Mulai Sesi
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isReady ? () {} : null,
              icon: Icon(
                Icons.play_arrow_rounded,
                color: isReady
                    ? const Color(0xFF1F4C7A)
                    : const Color(0xFFB0C4D8),
              ),
              label: Text(
                'Mulai Sesi',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isReady
                      ? const Color(0xFF1F4C7A)
                      : const Color(0xFFB0C4D8),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isReady
                      ? const Color(0xFF1F4C7A)
                      : const Color(0xFFB0C4D8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Tombol Batalkan Sesi
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFFF0EE),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Batalkan Sesi',
                style: TextStyle(
                  color: Color(0xFFE46E63),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── History Card ───────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final AppointmentSession session;
  final String Function(DateTime) formatScheduled;
  final IconData Function(SessionMethod) methodIcon;
  final String Function(SessionMethod) methodLabel;
  final VoidCallback onReview;
  final VoidCallback onKonsultasiLagi;

  const _HistoryCard({
    required this.session,
    required this.formatScheduled,
    required this.methodIcon,
    required this.methodLabel,
    required this.onReview,
    required this.onKonsultasiLagi,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = session.status == SessionStatus.done;
    final isCancelled = session.status == SessionStatus.cancelled;
    final hasRated = session.myRating != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header psikolog
          _PsychologistHeader(
            name: session.psychologistName,
            specialization: session.psychologistSpecialization,
          ),
          const Divider(height: 20, color: Color(0xFFE1E8F2)),

          // Metode & status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F4C7A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(methodIcon(session.method),
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      methodLabel(session.method),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F3B59),
                      ),
                    ),
                    Text(
                      formatScheduled(session.scheduledAt),
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              // Badge
              if (isDone)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF7F0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF4CAF82)),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF2E7D57),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else if (isCancelled)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0EE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE46E63)),
                  ),
                  child: const Text(
                    'Dibatalkan',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFE46E63),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Tombol bawah
          Row(
            children: [
              // Konsultasi Lagi
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onKonsultasiLagi,
                  icon: const Icon(Icons.health_and_safety_outlined,
                      size: 16),
                  label: const Text('Konsultasi Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F4C7A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Tombol review (hanya jika selesai)
              if (isDone) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: hasRated
                      // Sudah dinilai — tampilkan rating
                      ? OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.star_rounded,
                              color: Color(0xFFFFC107), size: 18),
                          label: Text(
                            session.myRating!
                                .toStringAsFixed(0),
                            style: const TextStyle(
                              color: Color(0xFF1F3B59),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFFBFD0E6)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      // Belum dinilai — tombol beri ulasan
                      : OutlinedButton.icon(
                          onPressed: onReview,
                          icon: const Icon(Icons.star_border_rounded,
                              color: Color(0xFF1F4C7A), size: 18),
                          label: const Text(
                            'Beri Ulasan',
                            style: TextStyle(
                              color: Color(0xFF1F4C7A),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFF1F4C7A)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ─────────────────────────────────────────────────────────

class _PsychologistHeader extends StatelessWidget {
  final String name;
  final String specialization;

  const _PsychologistHeader({
    required this.name,
    required this.specialization,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar inisial
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xFFDCEAF5),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0] : '?',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B517A),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F3B59),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                specialization,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6D7C93),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String label;
  const _EmptyCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E8F2)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      ),
    );
  }
}