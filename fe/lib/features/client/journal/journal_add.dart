import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/constants.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/core/services/auth_state.dart';

class JournalAdd extends StatefulWidget {
  const JournalAdd({super.key, this.journalId});

  final String? journalId;

  @override
  State<JournalAdd> createState() => _JournalAddState();
}

class _JournalAddState extends State<JournalAdd> {
  static final String _baseUrl = AppConstants.baseUrl;
  late final ApiClient _apiClient = ApiClient(
    baseUrl: _baseUrl,
    autoLoadToken: true,
  );

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool get _isEdit => widget.journalId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _fetchJournal();
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _apiClient.close();
    super.dispose();
  }

  Future<void> _fetchJournal() async {
    try {
      final response = await _apiClient.get(
        '/journal/${widget.journalId}',
        query: {'userId': authState.userId ?? ''},
      );
      debugPrint(
        '📥 GET /journal/${widget.journalId} — status: ${response.statusCode}',
      );
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        _titleController.text = data['title']?.toString() ?? '';
        _bodyController.text = data['content']?.toString() ?? '';
      }
    } catch (e) {
      debugPrint('❌ GET /journal error: $e');
      if (mounted) _showSnackBar('Gagal memuat jurnal.');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final content = _bodyController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      _showSnackBar('Judul dan isi jurnal harus diisi.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_isEdit) {
        final response = await _apiClient.put(
          '/journal/${widget.journalId}',
          body: {
            'userId': authState.userId ?? '',
            'title': title,
            'content': content,
          },
        );
        debugPrint(
          '📥 PUT /journal/${widget.journalId} — status: ${response.statusCode}',
        );
        if (response.statusCode != 200) {
          _showSnackBar(response.data?.toString() ?? 'Gagal memperbarui jurnal.');
          setState(() => _isSaving = false);
          return;
        }
      } else {
        final response = await _apiClient.post(
          '/journal',
          body: {
            'userId': authState.userId ?? '',
            'title': title,
            'content': content,
          },
        );
        debugPrint('📥 POST /journal — status: ${response.statusCode}');
        if (response.statusCode != 201 && response.statusCode != 200) {
          _showSnackBar(response.data?.toString() ?? 'Gagal menyimpan jurnal.');
          setState(() => _isSaving = false);
          return;
        }
      }

      if (!mounted) return;
      context.pop();
    } catch (e) {
      debugPrint('❌ Save journal error: $e');
      _showSnackBar('Terjadi kesalahan. Coba lagi.');
      setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4D79A6),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _isEdit ? 'Edit Jurnal' : 'Jurnal Baru',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(12),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _titleController,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  hintText: 'Isi judul jurnal anda...',
                                  hintStyle: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFB0C4D8),
                                  ),
                                  isDense: true,
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1F4C7A),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _bodyController,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  hintText: 'Isi jurnal anda di sini...',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFB0C4D8),
                                    height: 1.5,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1F3B59),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F4C7A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isEdit ? 'Simpan Perubahan' : 'Simpan Jurnal',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
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
