import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon/core/theme/app_gradients.dart';

class HumanPartner extends StatelessWidget {
  const HumanPartner({
    super.key,
    this.onFindPartner,
    this.onChat,
    this.onVoice,
    this.onVideo,
  });

  final VoidCallback? onFindPartner;
  final VoidCallback? onChat;
  final VoidCallback? onVoice;
  final VoidCallback? onVideo;

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2F6FB4);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: const Border(
          left: BorderSide(color: Color(0xFF578BB3), width: 12),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  gradient: AppGradients.horizontal,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Human Partner',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B517A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Bertemu dengan Human Partner anonim untuk saling menemani, '
            'berbagi keluh kesah, dan memberikan dukungan emosional satu sama lain.',
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Color(0xFF1B517A),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity, // <-- Tetap mempertahankan lebar penuh
            decoration: BoxDecoration(
              gradient: AppGradients
                  .horizontal, // <-- Gradasi horizontal kamu di sini
              borderRadius: BorderRadius.circular(
                12,
              ), // Harus sama dengan radius tombol
            ),
            child: ElevatedButton(
              onPressed: () {
                context.go('/partner/human-partner');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .transparent, // <-- Dibuat transparan agar gradasi terlihat
                shadowColor:
                    Colors.transparent, // <-- Hilangkan bayangan bawaan
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: const Text('Cari Partner'),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Opsi komunikasi:',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF6B778C),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline, size: 14),
                  label: const Text('Chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5B6777),
                    side: const BorderSide(color: Color(0xFFB7C1CE)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.mic, size: 14),
                  label: const Text('Voice'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5B6777),
                    side: const BorderSide(color: Color(0xFFB7C1CE)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.videocam_outlined, size: 14),
                  label: const Text('Video'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5B6777),
                    side: const BorderSide(color: Color(0xFFB7C1CE)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
