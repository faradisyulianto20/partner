import 'package:flutter/material.dart';
import 'package:hackathon/core/models/doctor.dart';
import 'package:hackathon/core/services/doctor_service.dart';
import 'package:hackathon/features/partner/widgets/doctor_card.dart';

enum PartnerFilter { matchCondition, lowestPrice, highestPrice }

class ProfessionalPartnerPage extends StatefulWidget {
  const ProfessionalPartnerPage({super.key});

  @override
  State<ProfessionalPartnerPage> createState() => _ProfessionalPartnerState();
}

class _ProfessionalPartnerState extends State<ProfessionalPartnerPage> {
  final TextEditingController _searchController = TextEditingController();
  final DoctorService _doctorService = DoctorService();
  late final Future<List<Doctor>> _doctorsFuture;
  Set<PartnerFilter> _filters = {PartnerFilter.matchCondition};

  @override
  void initState() {
    super.initState();
    _doctorsFuture = _doctorService.fetchDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Doctor> _applySearchAndFilter(List<Doctor> doctors) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = doctors.where((doctor) {
      if (query.isEmpty) return true;
      return doctor.name.toLowerCase().contains(query) ||
          doctor.specialization.toLowerCase().contains(query) ||
          doctor.location.toLowerCase().contains(query) ||
          doctor.condition.toLowerCase().contains(query);
    }).toList();

    if (_filters.contains(PartnerFilter.lowestPrice)) {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_filters.contains(PartnerFilter.highestPrice)) {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    return filtered;
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
                        if (_filters.contains(value)) {
                          if (_filters.length > 1) _filters.remove(value);
                        } else {
                          _filters.add(value);
                        }
                      });
                    },
                    offset: const Offset(0, 52.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        bottomLeft: Radius.circular(16.0),
                        topRight: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                      ), // Atur tingkat kelengkungan
                    ),
                    // Tutup popup secara manual agar bisa multi-select
                    // (popup menutup sendiri setelah onSelected, ini perilaku default Flutter)
                    color: Colors.white,

                    elevation: 4,
                    itemBuilder: (context) {
                      return PartnerFilter.values.map((filter) {
                        final isSelected = _filters.contains(filter);
                        return PopupMenuItem<PartnerFilter>(
                          value: filter,
                          padding: EdgeInsets.zero,
                          child: StatefulBuilder(
                            builder: (context, setItemState) {
                              return Container(
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
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(24),
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF1F4C7A)
                                        : const Color(0xFFBFD0E6),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _filterLabel(filter),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF1F4C7A),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign
                                            .center, // Memastikan teks di tengah alignment expanded
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }).toList();
                    },
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
            Expanded(
              child: FutureBuilder<List<Doctor>>(
                future: _doctorsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Gagal memuat data.'));
                  }

                  final doctors = _applySearchAndFilter(snapshot.data ?? []);
                  if (doctors.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada psikolog yang cocok.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      return DoctorCard(doctor: doctors[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
