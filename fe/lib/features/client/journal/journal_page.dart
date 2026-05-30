import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/constants.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/core/services/auth_state.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  static final String _baseUrl = AppConstants.baseUrl;

  late final ApiClient _apiClient = ApiClient(
    baseUrl: _baseUrl,
    autoLoadToken: true,
  );

  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _entries = [];

  @override
  void initState() {
    super.initState();
    _fetchJournals();
  }

  @override
  void dispose() {
    _apiClient.close();
    super.dispose();
  }

  Future<void> _fetchJournals({int limit = 20, int offset = 0}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiClient.get(
        '/journal',
        query: {
          'userId': authState.userId ?? '',
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      debugPrint(
        '📥 GET /journal — status: ${response.statusCode} | data: ${response.data}',
      );

      if (response.statusCode != 200) {
        setState(() {
          _errorMessage = 'Gagal memuat jurnal.';
          _isLoading = false;
        });
        return;
      }

      final data = response.data;
      List<Map<String, dynamic>> items = [];
      if (data is Map && data['items'] is List) {
        items = (data['items'] as List).cast<Map<String, dynamic>>();
      } else if (data is List) {
        items = data.cast<Map<String, dynamic>>();
      }

      setState(() {
        _entries = items;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ GET /journal error: $e');
      setState(() {
        _errorMessage = 'Terjadi kesalahan. Coba lagi.';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteJournal(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Hapus Jurnal Ini?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F4C7A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Jurnal yang dihapus tidak dapat dikembalikan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black45),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5D8CB8), Color(0xFF2D608F)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Hapus'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1F4C7A),
                        side: const BorderSide(
                          color: Color(0xFF1F4C7A),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await _apiClient.delete(
        '/journal/$id',
        query: {'userId': authState.userId ?? ''},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        _fetchJournals();
      } else {
        _showSnackBar('Gagal menghapus jurnal.');
      }
    } catch (e) {
      debugPrint('❌ DELETE /journal error: $e');
      _showSnackBar('Terjadi kesalahan.');
    }
  }

  Future<void> _editJournal(String id) async {
    await context.push('/journal/add', extra: id);
    if (mounted) _fetchJournals();
  }

  Future<void> _goToAdd() async {
    await context.push('/journal/add');
    if (mounted) _fetchJournals();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    final parsed = DateTime.tryParse(isoString);
    if (parsed == null) return '';
    final local = parsed.toLocal();
    final months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${local.day} ${months[local.month]} ${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchJournals,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _GreetingCard(onTap: _goToAdd),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: CircularProgressIndicator(),
                  )
                else if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Column(
                      children: [
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _fetchJournals,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                else if (_entries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: Text(
                      'Belum ada jurnal. Yuk tulis ceritamu!',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                else
                  Column(
                    children: _entries
                        .map(
                          (entry) => _JournalCard(
                            title: entry['title']?.toString() ?? '',
                            date: _formatDate(entry['createdAt']?.toString()),
                            body: entry['content']?.toString() ?? '',
                            tag: entry['moodLabel']?.toString() ?? '',
                            onTap: () =>
                                _editJournal(entry['id']?.toString() ?? ''),
                            onDelete: () =>
                                _deleteJournal(entry['id']?.toString() ?? ''),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1F4C7A),
        onPressed: _goToAdd,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final VoidCallback onTap;

  const _GreetingCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF5D8CB8), Color(0xFF2D608F)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Selamat ${_greeting()}, ${authState.displayNameOrEmail}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Bagaimana perasaanmu hari ini? Kamu boleh tulis\ncerita apapun disini yaa! 🤗',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'Pagi';
    if (hour < 15) return 'Siang';
    if (hour < 18) return 'Sore';
    return 'Malam';
  }
}

class _JournalCard extends StatelessWidget {
  final String title;
  final String date;
  final String body;
  final String tag;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _JournalCard({
    required this.title,
    required this.date,
    required this.body,
    required this.tag,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBFD0E6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color(0xFF1F3B59),
                        ),
                      ),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A94A6),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0EE),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE46E63)),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Color(0xFFE46E63),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6D7C93),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            if (tag.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF7EA2C8)),
                  color: const Color(0xFFEAF2FA),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF1F4C7A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
