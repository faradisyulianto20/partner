import 'package:flutter/material.dart';
import 'package:hackathon/core/theme/app_gradients.dart';

class AIProfessional extends StatelessWidget {
  const AIProfessional({super.key, this.onFindPsychologist});

  final VoidCallback? onFindPsychologist;

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
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'AI Professional',
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
            'Temukan profesional yang siap membantu dan mendukung '
            'perjalanan emosionalmu dengan nyaman dan aman.',
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Color(0xFF1B517A),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline, size: 16),
              label: const Text('Cari Psikolog'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                iconColor: const Color(0xFF1B517A),
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
        ],
      ),
    );
  }
}
