import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:hackathon/core/models/doctor.dart';

class DetailDoctor extends StatefulWidget {
  const DetailDoctor({super.key});

  @override
  State<DetailDoctor> createState() => _DetailDoctorState();
}

class _DetailDoctorState extends State<DetailDoctor> {
  Doctor _fallbackDoctor() {
    return Doctor(
      id: 0,
      name: 'Dr. Priantara, S.Psi, M.Psi',
      specialization: 'Psikolog Klinis',
      location: 'Sleman, Yogyakarta',
      condition: 'Anxiety & Overthinking',
      rating: 4.9,
      imageUrl: 'assets/images/doctor1.png',
      price: 100000,
    );
  }

  String _formatPrice(int price) {
    // Menggunakan regex untuk menyisipkan titik setiap 3 digit dari belakang
    final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = price.toString().replaceAllMapped(
      regExp,
      (Match m) => '${m[1]}.',
    );
    return 'Rp. $formatted';
  }

  @override
  Widget build(BuildContext context) {
    final doctor =
        GoRouterState.of(context).extra as Doctor? ?? _fallbackDoctor();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: AppBar(
          backgroundColor: const Color(0xFF4D79A6),
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Profil Psikolog',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          centerTitle: true,
        ),
        // ✅ SafeArea wrapping bottomNavigationBar agar tidak tertutup system bar
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE1E8F2), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Tarif Sesi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6D7C93),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPrice(doctor.price),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color(0xFF1F4C7A),
                        ),
                      ),
                    ],
                  ),
                ),
                // ✅ Navigate ke booking route
                ElevatedButton(
                  onPressed: () {
                    context.push(
                      '/partner/professional-partner/booking',
                      extra: doctor,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F4C7A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'Booking Sekarang',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // ✅ SafeArea pada body agar konten tidak bertabrakan dengan status bar
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              children: [
                _HeaderSection(doctor: doctor),
                const SizedBox(height: 16),
                const _SpecializationSection(),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD9E3F1)),
                  ),
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: Color(0xFF1F4C7A),
                        unselectedLabelColor: Color(0xFF9BAFC5),
                        indicatorColor: Color(0xFF1F4C7A),
                        indicatorWeight: 2.5,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                        ),
                        tabs: [
                          Tab(text: 'Tentang'),
                          Tab(text: 'Review'),
                          Tab(text: 'Program'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 440,
                        child: TabBarView(
                          children: const [
                            _AboutTab(),
                            _ReviewTab(),
                            _ProgramTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Header Section
// ─────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  final Doctor doctor;
  const _HeaderSection({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Foto dokter
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFE7EDF5),
            border: Border.all(color: const Color(0xFFD9E3F1), width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(doctor.imageUrl, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          doctor.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F3B59),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          doctor.specialization,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6D7C93),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        // Rating badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBFD0E6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFF4B740),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '${doctor.rating.toStringAsFixed(1)}/5 (125 review)',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1F3B59),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Spesialisasi Section
// ─────────────────────────────────────────────

class _SpecializationSection extends StatelessWidget {
  const _SpecializationSection();

  @override
  Widget build(BuildContext context) {
    final chips = [
      'Depresi',
      'Pengembangan Diri',
      'Gangguan Kecemasan',
      'Keluarga & Hubungan',
      'Stres',
      'Pekerjaan & Karir',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9E3F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.psychology_rounded,
                color: Color(0xFF1F4C7A),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Spesialisasi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F3B59),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (label) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFD0E6)),
                      color: Colors.white,
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1F4C7A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab: Tentang
// ─────────────────────────────────────────────

class _AboutTab extends StatelessWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tentang Saya',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color(0xFF1F3B59),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Halo, saya senang dapat menemanimu dalam perjalanan memahami emosimu. '
            'Saya memiliki pendekatan yang tenang, empatik, dan nyaman untuk membantu '
            'menghadapi overthinking, kecemasan ringan, burnout, maupun tekanan emosional sehari-hari.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6D7C93),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Pengalaman',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color(0xFF1F3B59),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _InfoChip(
                  icon: Icons.timer_outlined,
                  title: '7 Tahun',
                  subtitle: 'Pengalaman praktik sebagai psikolog klinis',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _InfoChip(
                  icon: Icons.people_outline_rounded,
                  title: '500+',
                  subtitle: 'Klien ditangani',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab: Review
// ─────────────────────────────────────────────

class _ReviewTab extends StatelessWidget {
  const _ReviewTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Rating summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD9E3F1)),
              color: const Color(0xFFF8FAFD),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '4.9',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F3B59),
                        ),
                      ),
                      SizedBox(height: 6),
                      _StarRow(rating: 5),
                      SizedBox(height: 4),
                      Text(
                        '125 Ulasan',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6D7C93),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(flex: 5, child: _RatingBars()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _ReviewCard(
            name: 'Amanda R',
            time: '2 hari lalu',
            rating: 5,
            message:
                'Sangat membantu dan nyaman untuk cerita. Terima kasih banyak.',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tab: Program
// ─────────────────────────────────────────────

class _ProgramTab extends StatelessWidget {
  const _ProgramTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.video_call_outlined,
                color: Color(0xFF1F4C7A),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Metode Konsultasi',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF1F3B59),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _MethodCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Chat',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MethodCard(
                  icon: Icons.graphic_eq_rounded,
                  label: 'Voice',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MethodCard(
                  icon: Icons.videocam_outlined,
                  label: 'Video',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: Color(0xFF1F4C7A),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Jadwal & Ketersediaan',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF1F3B59),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DottedBorder(
            options: RoundedRectDottedBorderOptions(
              color: const Color(0xFF3D7AB5),
              strokeWidth: 1.5,
              dashPattern: const [6, 6],
              radius: const Radius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFF8FAFD),
              ),
              child: Column(
                children: const [
                  _ScheduleRow(day: 'Senin - Jumat', time: '09:00 - 17:00'),
                  Divider(color: Color(0xFFE1E8F2), height: 20),
                  _ScheduleRow(day: 'Sabtu', time: '09:00 - 14:00'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoChip({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E3F1)),
        color: const Color(0xFFF8FAFD),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE7EDF5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF1F4C7A), size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF1F3B59),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6D7C93),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final int rating;
  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_border_rounded,
          color: const Color(0xFFF4B740),
          size: 16,
        );
      }),
    );
  }
}

class _RatingBars extends StatelessWidget {
  const _RatingBars();

  @override
  Widget build(BuildContext context) {
    final ratings = [120, 3, 2, 0, 0];
    return Column(
      children: List.generate(5, (index) {
        final value = ratings[index];
        final label = 5 - index;
        final ratio = value / 120;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.5),
          child: Row(
            children: [
              Text(
                '$label',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF1F3B59),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.star_rounded,
                size: 12,
                color: Color(0xFFF4B740),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFE5EAF1),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF1F4C7A)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 24,
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6D7C93),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final String time;
  final int rating;
  final String message;

  const _ReviewCard({
    required this.name,
    required this.time,
    required this.rating,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E3F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF4D79A6),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF1F3B59),
                      ),
                    ),
                    const SizedBox(height: 3),
                    _StarRow(rating: rating),
                  ],
                ),
              ),
              Text(
                time,
                style: const TextStyle(fontSize: 10, color: Color(0xFF9BAFC5)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6D7C93),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MethodCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E3F1)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE7EDF5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1F4C7A), size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1F3B59),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final String day;
  final String time;

  const _ScheduleRow({required this.day, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 14,
              color: Color(0xFF4D79A6),
            ),
            const SizedBox(width: 6),
            Text(
              day,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1F3B59),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE7EDF5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1F4C7A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
