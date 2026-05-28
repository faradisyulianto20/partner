import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackathon/core/models/psychologist_models.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/core/services/psychologist_service.dart';
import 'package:go_router/go_router.dart';

enum PartnerFilter { matchCondition, lowestPrice, highestPrice }

class ProfessionalPartnerPage extends StatefulWidget {
  const ProfessionalPartnerPage({super.key});

  @override
  State<ProfessionalPartnerPage> createState() => _ProfessionalPartnerState();
}

class _ProfessionalPartnerState extends State<ProfessionalPartnerPage> {
  final TextEditingController _searchController = TextEditingController();
  late final PsychologistService _service = PsychologistService(
    ApiClient(baseUrl: dotenv.env['API_URL'] ?? 'http://10.72.12.108:3000'),
  );

  List<PsychologistListItem> _allItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  Set<PartnerFilter> _filters = {PartnerFilter.matchCondition};

  @override
  void initState() {
    super.initState();
    _fetchPsychologists();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPsychologists() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Pastikan service kamu mereturn ApiResponse<List<PsychologistListItem>>
    final response = await _service.search(
      const PsychologistSearchRequest(limit: 20),
    );

    if (!mounted) return;

    if (response.isSuccess) {
      setState(() {
        // Pastikan di service, data yang diparsing sudah berbentuk List langsung
        _allItems = response.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        // Tangkap pesan error dari server untuk ditampilkan di layar 'Coba Lagi'
        _errorMessage = 'Gagal memuat data partner';
      });
    }
  }

  List<PsychologistListItem> get _filtered {
    final query = _searchController.text.trim().toLowerCase();

    var result = _allItems.where((p) {
      if (query.isEmpty) return true;
      return p.fullName.toLowerCase().contains(query) ||
          p.specialization.toLowerCase().contains(query) ||
          p.location.toLowerCase().contains(query) ||
          p.clinicName.toLowerCase().contains(query);
    }).toList();

    if (_filters.contains(PartnerFilter.lowestPrice)) {
      // Sort by rating ascending sebagai proxy (harga belum ada di response)
      result.sort((a, b) => a.rating.compareTo(b.rating));
    } else if (_filters.contains(PartnerFilter.highestPrice)) {
      result.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return result;
  }

  String _filterLabel(PartnerFilter value) {
    switch (value) {
      case PartnerFilter.matchCondition:
        return 'Sesuai Kondisi';
      case PartnerFilter.lowestPrice:
        return 'Harga Terendah';
      case PartnerFilter.highestPrice:
        return 'Harga Tertinggi';
    }
  }

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
        child: Column(
          children: [
            // ── Search & Filter Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Cari psikolog',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF7A8CA5),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1B517A),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1B517A),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1B517A),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  PopupMenuButton<PartnerFilter>(
                    onSelected: (value) {
                      setState(() {
                        // Bersihkan filter harga yang berlawanan sebelum menambahkan yang baru
                        if (value == PartnerFilter.lowestPrice) {
                          _filters.remove(PartnerFilter.highestPrice);
                        } else if (value == PartnerFilter.highestPrice) {
                          _filters.remove(PartnerFilter.lowestPrice);
                        }

                        if (_filters.contains(value)) {
                          if (_filters.length > 1) _filters.remove(value);
                        } else {
                          _filters.add(value);
                        }
                      });
                    },
                    offset: const Offset(0, 52),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    color: Colors.white,
                    elevation: 4,
                    itemBuilder: (context) => PartnerFilter.values.map((f) {
                      final isSelected = _filters.contains(f);
                      return PopupMenuItem<PartnerFilter>(
                        value: f,
                        padding: EdgeInsets.zero,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1F4C7A)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF1F4C7A)
                                  : const Color(0xFFBFD0E6),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _filterLabel(f),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1F4C7A),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1B517A)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.tune, color: Color(0xFF4D6A8B)),
                          if (_filters.length > 1 ||
                              !_filters.contains(PartnerFilter.matchCondition))
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1F4C7A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ──
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1B517A),
                      ),
                    )
                  : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wifi_off_rounded,
                            size: 48,
                            color: Color(0xFFB0BEC5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: _fetchPsychologists,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    )
                  : _filtered.isEmpty
                  ? const Center(child: Text('Tidak ada psikolog yang cocok.'))
                  : RefreshIndicator(
                      onRefresh: _fetchPsychologists,
                      color: const Color(0xFF1B517A),
                      child: // Ubah bagian ListView.builder di ProfessionalPartnerPage menjadi seperti ini:
                      ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final psychologist = _filtered[index];
                          return _PsychologistCard(
                            item: psychologist,
                            onTap: () {
                              print("ini ditekan");
                              // Navigasi menggunakan GoRouter dengan menginjeksikan id psikolog
                              context.push(
                                '/partner/professional-partner/detail/${psychologist.id}',
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card Widget ──
class _PsychologistCard extends StatelessWidget {
  final PsychologistListItem item;
  final VoidCallback? onTap;

  const _PsychologistCard({required this.item, this.onTap});

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
            color: const Color(0xFF1B517A).withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent, // Biarkan warna container yang terlihat
        child: InkWell(
          borderRadius: BorderRadius.circular(16), // Samakan agar efek klik tidak luber
          onTap: onTap, // Memicu fungsi navigasi GoRouter dari halaman utama
          child: Padding(
            padding: const EdgeInsets.all(16), // Padding dipindah ke dalam InkWell agar seluruh area kartu bisa diklik
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFDCEAF5),
                  child: Text(
                    item.fullName.isNotEmpty ? item.fullName[0] : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B517A),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info Lengkap Dokter
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.fullName,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1B517A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.specialization,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4D79A6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              '${item.clinicName} · ${item.location}',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: const Color(0xFF94A3B8),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Rating & Ulasan
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B517A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.reviewCount} ulasan',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
