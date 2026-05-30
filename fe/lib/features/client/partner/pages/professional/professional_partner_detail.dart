import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:hackathon/core/constants.dart';
import 'package:hackathon/core/models/psychologist_models.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/core/services/psychologist_service.dart';
import 'package:hackathon/core/theme/app_gradients.dart';

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
      final response = await _psychologistService.getDetail(
        widget.psychologistId,
      );
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
    final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = price.toString().replaceAllMapped(
      regExp,
      (Match m) => '${m[1]}.',
    );
    return 'Rp. $formatted';
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
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFB0BEC5),
              ),
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
    final price = psychologist.price;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: _buildAppBar(),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6D7C93),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatPrice(price),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color(0xFF1F4C7A),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.push(
                      '/partner/professional-partner/booking',
                      extra: psychologist,
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              children: [
                _HeaderSection(psychologist: psychologist),
                const SizedBox(height: 16),
                _SpecializationSection(tags: psychologist.tags),
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
                          children: [
                            _AboutTab(psychologist: psychologist),
                            _ReviewTab(reviews: psychologist.reviews),
                            _ProgramTab(schedules: psychologist.schedules),
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
        // Avatar dengan gradient background
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: AppGradients.horizontal,
            border: Border.all(color: const Color(0xFFD9E3F1), width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child:
                psychologist.photoUrl != null &&
                    psychologist.photoUrl!.isNotEmpty
                ? Image.network(psychologist.photoUrl!, fit: BoxFit.cover)
                : Center(
                    child: Text(
                      psychologist.fullName.isNotEmpty
                          ? psychologist.fullName[0]
                          : '?',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          psychologist.fullName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F3B59),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          psychologist.specialization,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6D7C93),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        // Rating badge — bintang biru
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
                color: Colors.amber, // ← biru
                size: 18,
              ),
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
            children: displayTags
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
          // Tentang Saya
          const Text(
            'Tentang Saya',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color(0xFF1F3B59),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            psychologist.bio,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6D7C93),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),

          // Pengalaman
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
                  icon: Icons.people_outline_rounded,
                  title: '${psychologist.clientsHandled}+',
                  subtitle: 'Klien ditangani',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Nomor STR
          if (psychologist.strNumber.isNotEmpty) ...[
            const Text(
              'Nomor STR',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Color(0xFF1F3B59),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              psychologist.strNumber,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6D7C93)),
            ),
            const SizedBox(height: 20),
          ],

          // Pendidikan
          if (psychologist.education.isNotEmpty) ...[
            const Text(
              'Pendidikan',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Color(0xFF1F3B59),
              ),
            ),
            const SizedBox(height: 8),
            ...psychologist.education.map(
              (edu) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(color: Color(0xFF6D7C93), fontSize: 12),
                    ),
                    Expanded(
                      child: Text(
                        '${edu.level} - ${edu.institution} (${edu.year})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6D7C93),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
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
        child: Text('Belum ada ulasan.', style: TextStyle(color: Colors.grey)),
      );
    }

    final averageRating =
        reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Rating summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD9E3F1)),
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F3B59),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _StarRow(rating: averageRating.round()),
                      const SizedBox(height: 4),
                      Text(
                        '${reviews.length} Ulasan',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6D7C93),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(flex: 5, child: _RatingBars(reviews: reviews)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...reviews.map(
            (review) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ReviewCard(
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

class _RatingBars extends StatelessWidget {
  final List<PsychologistReview> reviews;
  const _RatingBars({required this.reviews});

  @override
  Widget build(BuildContext context) {
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
                size: 16,
                color: Colors.amber,
              ), // ← biru
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
                  count.toString(),
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

// ── Tab Program ──
class _ProgramTab extends StatelessWidget {
  final List<PsychologistSchedule> schedules;
  const _ProgramTab({required this.schedules});

  String _getDayName(int dayOfWeek) {
    const days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    return days[dayOfWeek % 7];
  }

  @override
  Widget build(BuildContext context) {
    final displaySchedules = schedules.isNotEmpty
        ? schedules.where((s) => s.isAvailable).toList()
        : <PsychologistSchedule>[];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metode Konsultasi
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

          // Jadwal & Ketersediaan
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
            options: const RoundedRectDottedBorderOptions(
              color: Color(0xFF3D7AB5),
              strokeWidth: 1.5,
              dashPattern: [10, 10],
              radius: Radius.circular(14),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: displaySchedules.isEmpty
                  ? const Text(
                      'Tidak ada jadwal tersedia.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6D7C93)),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...displaySchedules.map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _ScheduleRow(
                              day: '${_getDayName(s.dayOfWeek)}:',
                              time: '${s.startTime} - ${s.endTime}',
                            ),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color.fromARGB(255, 255, 255, 255),
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
          color: const Color(0xFF1F4C7A), // ← biru
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
              // Icon profile dengan gradient horizontal
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.horizontal,
                ),
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
                    // Bintang biru di review card
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFF1F4C7A), // ← biru
                          size: 14,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                time,
                style: const TextStyle(fontSize: 10, color: Color(0xFF9BAFC5)),
              ),
            ],
          ),
          if (message.isNotEmpty) ...[
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
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1F4C7A), size: 22),
          ),
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
