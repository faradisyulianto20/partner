import 'package:flutter/material.dart';
import 'package:hackathon/core/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/models/psychologist_models.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/core/services/psychologist_service.dart';

class DetailDoctor extends StatefulWidget {
  final String psychologistId;
  const DetailDoctor({super.key, required this.psychologistId});

  @override
  State<DetailDoctor> createState() => _DetailDoctorState();
}

class _DetailDoctorState extends State<DetailDoctor> {
  late PsychologistService _psychologistService;
  PsychologistDetailResponse? _psychologistData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _psychologistService = PsychologistService(
      ApiClient(baseUrl: AppConstants.baseUrl),
    );
    _fetchPsychologistDetail();
  }

  Future<void> _fetchPsychologistDetail() async {
    if (widget.psychologistId.isEmpty) {
      setState(() {
        _errorMessage = 'ID psikolog tidak ditemukan';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _psychologistService.getDetail(widget.psychologistId);
      if (!mounted) return;

      if (response.isSuccess) {
        setState(() {
          _psychologistData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data psikolog';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _formatPrice(int price) {
    if (price == 0) return 'Hubungi klinik';
    final raw = price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final position = raw.length - i;
      buffer.write(raw[i]);
      if (position > 1 && position % 3 == 1) buffer.write('.');
    }
    return 'Rp ${buffer.toString()}';
  }

  AppBar _buildAppBar() => AppBar(
        backgroundColor: const Color(0xFF4D79A6),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profil Psikolog',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF1B517A)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFFB0BEC5)),
              const SizedBox(height: 12),
              Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _fetchPsychologistDetail,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final psychologist = _psychologistData!;

    // FIX #8: Gunakan price dari API response, bukan dari fallback Doctor
    final price = psychologist.price;

    return DefaultTabController(
      length: 4, // FIX #3: Tambah tab Pendidikan
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: _buildAppBar(),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
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
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF6D7C93)),
                      ),
                      const SizedBox(height: 4),
                      // FIX #8: Tampilkan price dari API
                      Text(
                        _formatPrice(price),
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
                    // Kirim PsychologistDetailResponse sebagai extra untuk halaman booking
                    context.push(
                      '/partner/professional-partner/booking',
                      extra: psychologist,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F4C7A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Booking Sekarang',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _HeaderSection(psychologist: psychologist),
                const SizedBox(height: 16),
                _SpecializationSection(tags: psychologist.tags),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
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
                      // FIX #3: Tambah tab Pendidikan
                      const TabBar(
                        labelColor: Color(0xFF1F4C7A),
                        unselectedLabelColor: Color(0xFF7A8CA5),
                        indicatorColor: Color(0xFF1F4C7A),
                        indicatorWeight: 2,
                        tabs: [
                          Tab(text: 'Tentang'),
                          Tab(text: 'Review'),
                          Tab(text: 'Program'),
                          Tab(text: 'Pendidikan'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 280,
                        child: TabBarView(
                          children: [
                            _AboutTab(psychologist: psychologist),
                            // FIX #4 & #5: Kirim seluruh reviews ke tab
                            _ReviewTab(reviews: psychologist.reviews),
                            _ProgramTab(schedules: psychologist.schedules),
                            // FIX #3: Render data education dari API
                            _EducationTab(
                                education: psychologist.education),
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

// ── Header ──
class _HeaderSection extends StatelessWidget {
  final PsychologistDetailResponse psychologist;

  const _HeaderSection({required this.psychologist});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFDCEAF5),
          ),
          child: Center(
            child: Text(
              psychologist.fullName.isNotEmpty
                  ? psychologist.fullName[0]
                  : '?',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B517A),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          psychologist.fullName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F3B59),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          psychologist.specialization,
          style: const TextStyle(fontSize: 13, color: Color(0xFF6D7C93)),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 14, color: Color(0xFF94A3B8)),
            const SizedBox(width: 4),
            Text(
              '${psychologist.clinicName} · ${psychologist.location}',
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBFD0E6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star,
                  color: Color(0xFFF4B740), size: 16),
              const SizedBox(width: 6),
              Text(
                '${psychologist.rating.toStringAsFixed(1)}/5 (${psychologist.reviewCount} review)',
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

// ── Spesialisasi ──
class _SpecializationSection extends StatelessWidget {
  final List<String> tags;

  const _SpecializationSection({required this.tags});

  @override
  Widget build(BuildContext context) {
    final displayTags = tags.isNotEmpty
        ? tags
        : ['Depresi', 'Kecemasan', 'Stres', 'Keluarga'];

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
            children: displayTags
                .map(
                  (label) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: const Color(0xFFBFD0E6)),
                      color: Colors.white,
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF1F4C7A)),
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

// ── Tab Tentang ──
class _AboutTab extends StatelessWidget {
  final PsychologistDetailResponse psychologist;

  const _AboutTab({required this.psychologist});

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
          Text(
            psychologist.bio,
            style: const TextStyle(
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
                  title: '${psychologist.yearsExperience} Tahun',
                  subtitle: 'Pengalaman praktik sebagai psikolog klinis',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoChip(
                  icon: Icons.people_outline,
                  title: '${psychologist.clientsHandled}+',
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

// ── Tab Review ──
class _ReviewTab extends StatelessWidget {
  final List<PsychologistReview> reviews;

  const _ReviewTab({required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Center(
        child: Text('Belum ada ulasan.',
            style: TextStyle(color: Colors.grey)),
      );
    }

    final averageRating =
        reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;

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
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B517A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _StarRow(rating: averageRating.round()),
                      const SizedBox(height: 4),
                      Text(
                        '${reviews.length} Ulasan',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // FIX #4: Hitung rating bar dari data reviews nyata
                Expanded(
                  flex: 4,
                  child: _RatingBars(reviews: reviews),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // FIX #5: Tampilkan semua review, bukan hanya .take(1)
          ...reviews.map(
            (review) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ReviewCard(
                // FIX #6: Label lebih ramah daripada "User u1"
                name: 'Pengguna ${review.userId}',
                time: _formatDate(review.createdAt),
                rating: review.rating.round(),
                message: review.comment,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}

// FIX #4: _RatingBars sekarang menerima data reviews nyata
class _RatingBars extends StatelessWidget {
  final List<PsychologistReview> reviews;

  const _RatingBars({required this.reviews});

  @override
  Widget build(BuildContext context) {
    // Hitung distribusi rating dari data nyata
    final counts = List.filled(5, 0);
    for (final r in reviews) {
      final idx = r.rating.round().clamp(1, 5) - 1;
      counts[idx]++;
    }
    final maxCount = counts.reduce((a, b) => a > b ? a : b);

    return Column(
      children: List.generate(5, (index) {
        final label = 5 - index;
        final count = counts[label - 1];
        final ratio = maxCount > 0 ? count / maxCount : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Text(
                '$label',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF1B517A)),
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
                    valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF1F4C7A)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                count.toString(),
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF6D7C93)),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Tab Program ──
class _ProgramTab extends StatelessWidget {
  final List<PsychologistSchedule> schedules;

  const _ProgramTab({required this.schedules});

  String _getDayName(int dayOfWeek) {
    const days = [
      'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu',
    ];
    return days[dayOfWeek % 7];
  }

  @override
  Widget build(BuildContext context) {
    final displaySchedules = schedules.isNotEmpty
        ? schedules
        : [
            const PsychologistSchedule(
              id: '1', dayOfWeek: 1,
              startTime: '09:00', endTime: '17:00', isAvailable: true,
            ),
          ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.video_call_outlined,
                  color: Color(0xFF1F4C7A), size: 20),
              SizedBox(width: 8),
              Text(
                'Metode Konsultasi',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF1F3B59)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                  child: _MethodCard(
                      icon: Icons.chat_bubble_outline, label: 'Chat')),
              SizedBox(width: 12),
              Expanded(
                  child: _MethodCard(
                      icon: Icons.graphic_eq, label: 'Voice')),
              SizedBox(width: 12),
              Expanded(
                  child: _MethodCard(
                      icon: Icons.videocam_outlined, label: 'Video')),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.calendar_month_outlined,
                  color: Color(0xFF1F4C7A), size: 20),
              SizedBox(width: 8),
              Text(
                'Jadwal & Ketersediaan',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF1F3B59)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFE6F3FD),
              border: Border.all(color: const Color(0xFFD9E3F1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: displaySchedules
                  .where((s) => s.isAvailable)
                  .map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _ScheduleRow(
                        day: '${_getDayName(s.dayOfWeek)}:',
                        time: '${s.startTime} - ${s.endTime}',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// FIX #3: Tab baru untuk menampilkan data education dari API
class _EducationTab extends StatelessWidget {
  final List<PsychologistEducation> education;

  const _EducationTab({required this.education});

  @override
  Widget build(BuildContext context) {
    if (education.isEmpty) {
      return const Center(
        child: Text('Data pendidikan tidak tersedia.',
            style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.school_outlined,
                  color: Color(0xFF1F4C7A), size: 20),
              SizedBox(width: 8),
              Text(
                'Riwayat Pendidikan',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF1F3B59),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...education.map(
            (edu) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD9E3F1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F4C7A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      edu.level,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          edu.institution,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F3B59),
                          ),
                        ),
                        Text(
                          'Lulus ${edu.year}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6D7C93),
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
    );
  }
}

// ── Shared Widgets ──

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          color: const Color(0xFFF4B740),
          size: 16,
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
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF1F4C7A),
                child: Icon(Icons.person, color: Colors.white, size: 18),
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
                        fontSize: 12,
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
                              fontSize: 10, color: Color(0xFF6D7C93)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6D7C93),
                  height: 1.4),
            ),
          ],
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
          style:
              const TextStyle(fontSize: 12, color: Color(0xFF1F3B59)),
        ),
      ],
    );
  }
}