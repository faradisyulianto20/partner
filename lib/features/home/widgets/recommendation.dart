import 'package:flutter/material.dart';

class RecommendationItem {
  const RecommendationItem({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
  });

  final String title;
  final String description;
  final Color color;
  final IconData icon;
}

class Recommendation extends StatelessWidget {
  const Recommendation({
    super.key,
    this.ai = true,
    this.human = true,
    this.profesional = true,
    this.title = 'Rekomendasi Dukungan Untukmu',
  });

  final bool ai;
  final bool human;
  final bool profesional;
  final String title;

  List<RecommendationItem> get _defaultItems => [
    if (ai)
      const RecommendationItem(
        title: 'AI Partner',
        description:
            'AI Partner dapat membantu menemanimu berbicara, menenangkan pikiran, dan memberikan refleksi emosional secara perlahan.',
        color: Color(0xFF2F6FB4),
        icon: Icons.psychology_alt,
      ),
    if (human)
      const RecommendationItem(
        title: 'Human Partner',
        description:
            'Jika kamu ingin merasa lebih dipahami secara emosional, kamu juga bisa mencoba berbicara dengan Human Partner secara anonim.',
        color: Color(0xFF2EA66B),
        icon: Icons.group_outlined,
      ),
    if (profesional)
      const RecommendationItem(
        title: 'Professional Partner',
        description:
            'Konsultasi dengan profesional akan membantumu menemukan cara yang lebih tepat untuk menghadapi emosi dan tekanan.',
        color: Color(0xFF8B5FB4),
        icon: Icons.medical_services_outlined,
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<RecommendationItem> data = _defaultItems;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey, width: 1.5),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B517A),
            ),
          ),
          const SizedBox(height: 12),
          for (final RecommendationItem item in data) ...[
            _RecommendationCard(item: item),
            if (item != data.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.item});

  final RecommendationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: item.color, width: 6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, size: 24, color: item.color),
              SizedBox(width: 6),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: item.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              height: 1.4,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
