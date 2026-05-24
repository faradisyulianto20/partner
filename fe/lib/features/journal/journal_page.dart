import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final List<Map<String, String>> _entries = [
    {
      'title': 'Kegiatanku waktu kuliah',
      'date': '10 Juni 2026',
      'body':
          'Hari ini aku kaya ngerasa cape banget, tugasku numpuk banget sedangkan aku harus nyelesain proyek lomba ku juga...',
      'tag': 'kelelahan',
    },
    {
      'title': 'Kegiatanku waktu kuliah',
      'date': '10 Juni 2026',
      'body':
          'Hari ini aku kaya ngerasa cape banget, tugasku numpuk banget sedangkan aku harus nyelesain proyek lomba ku juga...',
      'tag': 'kelelahan',
    },
    {
      'title': 'Kegiatanku waktu kuliah',
      'date': '10 Juni 2026',
      'body':
          'Hari ini aku kaya ngerasa cape banget, tugasku numpuk banget sedangkan aku harus nyelesain proyek lomba ku juga...',
      'tag': 'kelelahan',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _GreetingCard(onTap: () => context.push('/journal/add')),
              const SizedBox(height: 16),
              Column(
                children: _entries
                    .map(
                      (entry) => _JournalCard(
                        title: entry['title'] ?? '',
                        date: entry['date'] ?? '',
                        body: entry['body'] ?? '',
                        tag: entry['tag'] ?? '',
                        onDelete: () {},
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1F4C7A),
        onPressed: () => context.push('/journal/add'),
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
          children: const [
            Text(
              'Selamat Malam, Dinda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            Text(
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
}

class _JournalCard extends StatelessWidget {
  final String title;
  final String date;
  final String body;
  final String tag;
  final VoidCallback onDelete;

  const _JournalCard({
    required this.title,
    required this.date,
    required this.body,
    required this.tag,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
    );
  }
}
