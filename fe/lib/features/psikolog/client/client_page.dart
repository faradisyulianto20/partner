import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackathon/core/constants.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/core/shared_widgets/header.dart';
import 'package:hackathon/core/shared_widgets/psychologist_detail_sheet.dart';
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

  late final ApiClient _apiClient = ApiClient(
    baseUrl: AppConstants.baseUrl,
    autoLoadToken: true,
  );

  bool _isLoading = true;
  List<_ClientItem> _clients = [];
  int _countAll = 0;
  int _countActive = 0;
  int _countCompleted = 0;

  _ClientFilter _filter = _ClientFilter.all;

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _statusParam {
    switch (_filter) {
      case _ClientFilter.all:
        return 'ALL';
      case _ClientFilter.active:
        return 'ACTIVE';
      case _ClientFilter.done:
        return 'COMPLETED';
    }
  }

  Future<void> _fetchClients() async {
    setState(() => _isLoading = true);

    try {
      final query = <String, String>{
        'status': _statusParam,
      };
      final searchText = _searchController.text.trim();
      if (searchText.isNotEmpty) {
        query['search'] = searchText;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/psychologist/me/clients',
        query: query,
      );

      if (!mounted) return;

      if (response.isSuccess) {
        final data = response.data;
        final counts = data['counts'] as Map<String, dynamic>?;

        setState(() {
          _countAll = (counts?['all'] as num?)?.toInt() ?? 0;
          _countActive = (counts?['active'] as num?)?.toInt() ?? 0;
          _countCompleted = (counts?['completed'] as num?)?.toInt() ?? 0;

          final raw = data['items'];
          if (raw is List) {
            _clients = raw.map((c) {
              final item = c as Map<String, dynamic>;
              final genderRaw = (item['gender'] as String?) ?? '';
              final genderLabel = genderRaw == 'MALE' ? 'Laki-laki' : 'Perempuan';
              final ageRaw = item['age'];

              return _ClientItem(
                name: item['name'] as String? ?? '',
                age: ageRaw != null ? '$ageRaw Tahun' : '',
                gender: genderLabel,
                sessionDate: item['lastSessionLabel'] as String? ?? '',
                statusLabel: item['statusLabel'] as String? ?? '',
                status: item['status'] as String? ?? '',
                photoUrl: item['photoUrl'] as String?,
                latestMoodLabel: item['latestMoodLabel'] as String?,
                latestSummary: item['latestSummary'] as String?,
              );
            }).toList();
          } else {
            _clients = [];
          }
        });
      }
    } catch (e) {
      debugPrint('Fetch clients error: $e');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
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
                onChanged: (value) => _fetchClients(),
              ),
              _buildFilterRow(),
              const SizedBox(height: 32),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_clients.isEmpty)
                _buildEmptyState()
              else
                ListView.separated(
                  itemCount: _clients.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildClientCard(_clients[index]);
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
        _buildFilterChip(
          label: 'Semua',
          filter: _ClientFilter.all,
          count: _countAll,
        ),
        const SizedBox(width: 10),
        _buildFilterChip(
          label: 'Aktif',
          filter: _ClientFilter.active,
          count: _countActive,
        ),
        const SizedBox(width: 10),
        _buildFilterChip(
          label: 'Selesai',
          filter: _ClientFilter.done,
          count: _countCompleted,
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required _ClientFilter filter,
    required int count,
  }) {
    final isSelected = _filter == filter;

    return InkWell(
      onTap: () {
        setState(() => _filter = filter);
        _fetchClients();
      },
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
          '$label ($count)',
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
    return GestureDetector(
      onTap: () => _openClientDetail(client),
      child: Container(
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
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE3ECF6),
              backgroundImage: client.photoUrl != null
                  ? NetworkImage(client.photoUrl!)
                  : null,
              child: client.photoUrl == null
                  ? const Icon(Icons.person, color: Color(0xFF4D6E8A))
                  : null,
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
                  if (client.age.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${client.age}  •  ${client.gender}',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ],
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
                          client.statusLabel,
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (client.sessionDate.isNotEmpty) ...[
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
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: _primaryColor),
          ],
        ),
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

  void _openClientDetail(_ClientItem client) {
    PsychologistDetailMode mode;
    switch (client.status) {
      case 'COMPLETED':
        mode = PsychologistDetailMode.done;
        break;
      case 'ACTIVE':
        mode = PsychologistDetailMode.session;
        break;
      default:
        mode = PsychologistDetailMode.request;
    }

    showPsychologistDetailSheet(
      context: context,
      data: PsychologistDetailData(
        name: client.name,
        age: client.age,
        gender: client.gender,
        time: client.sessionDate,
        type: client.statusLabel,
        mood: client.latestMoodLabel ?? '-',
        note: client.latestSummary ?? '',
      ),
      mode: mode,
    );
  }
}

enum _ClientFilter { all, active, done }

class _ClientItem {
  final String name;
  final String age;
  final String gender;
  final String sessionDate;
  final String statusLabel;
  final String status;
  final String? photoUrl;
  final String? latestMoodLabel;
  final String? latestSummary;

  const _ClientItem({
    required this.name,
    required this.age,
    required this.gender,
    required this.sessionDate,
    required this.statusLabel,
    required this.status,
    this.photoUrl,
    this.latestMoodLabel,
    this.latestSummary,
  });
}
