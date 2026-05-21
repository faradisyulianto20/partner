import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final raw = price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final position = raw.length - i;
      buffer.write(raw[i]);
      if (position > 1 && position % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp. ${buffer.toString()}';
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
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE1E8F2))),
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
                      style: TextStyle(fontSize: 12, color: Color(0xFF6D7C93)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(doctor.price),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF1F3B59),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.push(
                    '/partner/professional-partner/booking',
                    extra: doctor,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F4C7A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Booking Sekarang',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _HeaderSection(doctor: doctor),
                      const SizedBox(height: 16),
                      const _SpecializationSection(),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD9E3F1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const TabBar(
                              labelColor: Color(0xFF1F4C7A),
                              unselectedLabelColor: Color(0xFF7A8CA5),
                              indicatorColor: Color(0xFF1F4C7A),
                              indicatorWeight: 2,
                              tabs: [
                                Tab(text: 'Tentang'),
                                Tab(text: 'Review'),
                                Tab(text: 'Program'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 220,
                              child: TabBarView(
                                children: [
                                  const _AboutTab(),
                                  const _ReviewTab(),
                                  const _ProgramTab(),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final Doctor doctor;

  const _HeaderSection({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFE7EDF5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(doctor.imageUrl, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          doctor.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F3B59),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          doctor.specialization,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6D7C93)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBFD0E6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Color(0xFFF4B740), size: 16),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E3F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, color: Color(0xFF1F4C7A), size: 20),
              SizedBox(width: 8),
              Text(
                'Spesialisasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B517A),
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
                      horizontal: 10,
                      vertical: 4,
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
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: Color(0xFF1B517A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Halo, saya senang dapat menemanimu dalam perjalanan memahami emosimu. '
            'Saya memiliki pendekatan yang tenang, empatik, dan nyaman untuk membantu '
            'menghadapi overthinking, kecemasan ringan, burnout, maupun tekanan emosional sehari-hari.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pengalaman',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color(0xFF1B517A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  icon: Icons.timer_outlined,
                  title: '7 Tahun',
                  subtitle: 'Pengalaman praktik sebagai psikolog klinis',
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: _InfoChip(
                  icon: Icons.people_outline,
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

class _ReviewTab extends StatelessWidget {
  const _ReviewTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD9E3F1)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: const [
                      Text(
                        '4.9',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B517A),
                        ),
                      ),
                      SizedBox(height: 4),
                      _StarRow(rating: 5),
                      SizedBox(height: 4),
                      Text(
                        '125 Ulasan',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Expanded(flex: 4, child: _RatingBars()),
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
          const Row(
            children: [
              Expanded(
                child: _MethodCard(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MethodCard(icon: Icons.graphic_eq, label: 'Voice'),
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
          const SizedBox(height: 20),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xFFE6F3FD),
              border: Border.all(color: const Color(0xFFD9E3F1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _ScheduleRow(day: 'Senin - Jumat:', time: '09:00 - 17:00'),
                SizedBox(height: 8),
                _ScheduleRow(day: 'Sabtu:', time: '09:00 - 14:00'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1F4C7A), size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Color(0xFF1B517A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              height: 1.3,
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
          index < rating ? Icons.star : Icons.star_border,
          color: const Color(0xFF1B517A),
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
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Text(
                '$label',
                style: const TextStyle(fontSize: 12, color: Color(0xFF1B517A)),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, size: 12, color: Color(0xFFF4B740)),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE5EAF1),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF1F4C7A)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                value.toString(),
                style: const TextStyle(fontSize: 10, color: Color(0xFF6D7C93)),
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
      padding: const EdgeInsets.all(12),
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
                radius: 18,
                backgroundColor: const Color(0xFF1F4C7A),
                child: const Icon(Icons.person, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F3B59),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _StarRow(rating: rating),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6D7C93),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6D7C93),
              height: 1.4,
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E3F1)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF1F4C7A)),
          const SizedBox(height: 6),
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
      children: [
        Text(
          day,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF1F3B59),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          time,
          style: const TextStyle(fontSize: 12, color: Color(0xFF1F3B59)),
        ),
      ],
    );
  }
}
