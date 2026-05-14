import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmotionDescriptionPage extends StatefulWidget {
  const EmotionDescriptionPage({super.key});

  @override
  State<EmotionDescriptionPage> createState() => _EmotionDescriptionPageState();
}

class _EmotionDescriptionPageState extends State<EmotionDescriptionPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Header(),
            Label(),
            Expanded(child: EmotionDescription()),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B517A)),
          ),
          Expanded(
            child: Text(
              'Deskripsi Emosi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B517A),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class Label extends StatelessWidget {
  const Label({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          border: const Border(
            left: BorderSide(width: 12, color: Color(0xFF578BB3)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.edit_document,
                  size: 40,
                  color: Color(0xFF1B517A),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ceritakan Perasaanmu Hari Ini',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: const Color(0xFF1B517A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Tuliskan apa yang sedang kamu rasakan hari ini. Ceritamu akan membantu AI memahami kondisi emosimu dan memberikan dukungan yang sesuai.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmotionDescription extends StatefulWidget {
  const EmotionDescription({super.key});

  @override
  State<EmotionDescription> createState() => _EmotionDescriptionState();
}

class _EmotionDescriptionState extends State<EmotionDescription> {
  final TextEditingController _controller = TextEditingController();
  final List<String> emotionTags = [
    'Aku merasa lelah',
    'Aku sedang overthinking',
    'Hari ini terasa berat',
    'Aku merasa usil',
    'Aku sedang penasaran',
    'Aku merasa lega',
  ];

  // ✅ Fungsi untuk mengisi TextField dengan teks dari shortcut tag
  void _onTagTapped(String tag) {
    final current = _controller.text.trim();
    if (current.isEmpty) {
      _controller.text = tag;
    } else {
      _controller.text = '$current $tag';
    }
    // Pindahkan kursor ke akhir teks
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul
          Text(
            'Tulis perasaanmu',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B517A),
            ),
          ),
          const SizedBox(height: 16),

          const SizedBox(height: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F9FC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFB0C8DC), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _controller,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText:
                            'Apa yang sedang memenuhi pikiranmu hari ini? Ceritakan...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1B517A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // ✅ Shortcut Label (Quick message) dengan fungsi onTap
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: emotionTags.map((tag) {
                        return GestureDetector(
                          onTap: () => _onTagTapped(tag),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black38,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black38,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Analysis Button & Voice Button
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF2D5F8D), Color(0xFF1B3E5F)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MaterialButton(
                    onPressed: () {},
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Analisis Perasaanku',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1B517A), width: 2),
                ),
                child: IconButton(
                  onPressed: () => context.push('/voice-input'),
                  icon: const Icon(
                    Icons.mic,
                    color: Color(0xFF1B517A),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Disclaimer text
          Center(
            child: Text(
              'Ceritakan aman dan hanya digunakan untuk membantumu memahami emosi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
