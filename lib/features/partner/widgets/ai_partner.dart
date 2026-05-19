import 'package:flutter/material.dart';
import 'package:hackathon/core/theme/app_gradients.dart';

class AIPartner extends StatelessWidget {
  const AIPartner({super.key, this.onChat, this.onVoice});

  final VoidCallback? onChat;
  final VoidCallback? onVoice;

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF2F6FB4);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border(left: BorderSide(color: Color(0xFF578BB3), width: 12)),
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
                child: const Icon(
                  Icons.psychology_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'AI Partner',
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
            'AI Partner siap menemanimu kapan saja untuk mendengarkan, '
            'memahami, dan membantu menenangkan pikiranmu.',
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Color(0xFF1B517A),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: const Text('Chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    iconColor: Color(0xFF1B517A),
                    side: const BorderSide(color: Color(0xFF1B517A)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B517A),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  // 1. Bungkus dengan Container dan beri dekorasi Gradasi
                  decoration: BoxDecoration(
                    gradient: AppGradients
                        .horizontal, // <-- Gradasi kamu di-apply di sini
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Harus sama dengan radius tombol
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.mic, size: 16),
                    label: const Text('Voice'),
                    style: ElevatedButton.styleFrom(
                      // 2. Buat background tombol bawaan menjadi transparan agar gradasi di belakangnya kelihatan
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors
                          .transparent, // Hilangkan shadow bawaan agar tidak merusak warna gradasi
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
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
