import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackathon/core/shared_widgets/header.dart';
import 'package:hackathon/core/shared_widgets/search_bar.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  final TextEditingController _searchController = TextEditingController();
  final Color _primaryColor = const Color(0xFF1B517A);
  final Color _softBlue = const Color(0xFF7DA0C4);

  final List<_ClientItem> _clients = const [
    _ClientItem(
      name: 'Alana Francisco',
      age: '32 Tahun',
      gender: 'Laki-laki',
      sessionDate: 'Sesi 10 November 2026',
      status: _ClientStatus.done,
    ),
    _ClientItem(
      name: 'Alana Francisco',
      age: '32 Tahun',
      gender: 'Laki-laki',
      sessionDate: 'Sesi 10 November 2026',
      status: _ClientStatus.active,
    ),
    _ClientItem(
      name: 'Alana Francisco',
      age: '32 Tahun',
      gender: 'Laki-laki',
      sessionDate: 'Sesi 10 November 2026',
      status: _ClientStatus.active,
    ),
    _ClientItem(
      name: 'Alana Francisco',
      age: '32 Tahun',
      gender: 'Laki-laki',
      sessionDate: 'Sesi 10 November 2026',
      status: _ClientStatus.done,
    ),
  ];

  _ClientFilter _filter = _ClientFilter.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredClients = _clients.where((client) {
      final matchesQuery = client.name.toLowerCase().contains(
        _query.toLowerCase().trim(),
      );

      final matchesFilter =
          _filter == _ClientFilter.all ||
          (_filter == _ClientFilter.active &&
              client.status == _ClientStatus.active) ||
          (_filter == _ClientFilter.done &&
              client.status == _ClientStatus.done);

      return matchesQuery && matchesFilter;
    }).toList();

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
              const SizedBox(height: 16),
              SearchBarWidget(
                controller: _searchController,
                hintText: 'Cari nama klien',
                onChanged: (value) => setState(() => _query = value),
              ),
              _buildFilterRow(),
              const SizedBox(height: 32),
              if (filteredClients.isEmpty)
                _buildEmptyState()
              else
                ListView.separated(
                  itemCount: filteredClients.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildClientCard(filteredClients[index]);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        _buildFilterChip(label: 'Semua', filter: _ClientFilter.all),
        const SizedBox(width: 10),
        _buildFilterChip(label: 'Aktif', filter: _ClientFilter.active),
        const SizedBox(width: 10),
        _buildFilterChip(label: 'Selesai', filter: _ClientFilter.done),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required _ClientFilter filter,
  }) {
    final isSelected = _filter == filter;

    return InkWell(
      onTap: () => setState(() => _filter = filter),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _softBlue, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : _primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildClientCard(_ClientItem client) {
    final isDone = client.status == _ClientStatus.done;
    final statusLabel = isDone ? 'Selesai' : 'Aktif';

    return Container(
      padding: const EdgeInsets.all(12),
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
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFE3ECF6),
            child: Icon(Icons.person, color: Color(0xFF4D6E8A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${client.age}  •  ${client.gender}',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      client.sessionDate,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: _primaryColor),
        ],
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
        'Tidak ada klien yang cocok dengan pencarian atau filter ini.',
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }
}

enum _ClientFilter { all, active, done }

enum _ClientStatus { active, done }

class _ClientItem {
  final String name;
  final String age;
  final String gender;
  final String sessionDate;
  final _ClientStatus status;

  const _ClientItem({
    required this.name,
    required this.age,
    required this.gender,
    required this.sessionDate,
    required this.status,
  });
}
