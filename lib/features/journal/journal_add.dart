import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class JournalAdd extends StatefulWidget {
  const JournalAdd({super.key});

  @override
  State<JournalAdd> createState() => _JournalAddState();
}

class _JournalAddState extends State<JournalAdd> {
  final TextEditingController _titleController = TextEditingController(
    text: 'AKU NGERASA CAPEKK BANGET HARI INI',
  );
  final TextEditingController _bodyController = TextEditingController(
    text:
        'iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari iniCape banget sih hari ini',
  );

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
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
        title: const Text(
          'Jurnal Baru',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
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
                  onPressed: () => context.go('/journal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F4C7A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Simpan Jurnal',
                    style: TextStyle(fontWeight: FontWeight.w700),
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
