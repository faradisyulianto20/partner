import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackathon/core/theme/app_gradients.dart';

class Review extends StatefulWidget {
  const Review({super.key});

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  final Color _primaryColor = const Color(0xFF1B517A);
  final Color _softBlue = const Color(0xFF7DA0C4);

  final List<_ReviewItem> _reviews = const [
    _ReviewItem(
      name: 'Amanda R',
      daysAgo: '2 hari lalu',
      rating: 5,
      comment:
          'Dr. Sarah sangat membantu saya mengatasi kecemasan. Pendekatannya sangat profesional dan membuat saya merasa nyaman.',
    ),
    _ReviewItem(
      name: 'Amanda R',
      daysAgo: '2 hari lalu',
      rating: 5,
      comment:
          'Dr. Sarah sangat membantu saya mengatasi kecemasan. Pendekatannya sangat profesional dan membuat saya merasa nyaman.',
    ),
    _ReviewItem(
      name: 'Amanda R',
      daysAgo: '2 hari lalu',
      rating: 5,
      comment:
          'Dr. Sarah sangat membantu saya mengatasi kecemasan. Pendekatannya sangat profesional dan membuat saya merasa nyaman.',
    ),
    _ReviewItem(
      name: 'Amanda R',
      daysAgo: '2 hari lalu',
      rating: 5,
      comment:
          'Dr. Sarah sangat membantu saya mengatasi kecemasan. Pendekatannya sangat profesional dan membuat saya merasa nyaman.',
    ),
  ];

  final Map<int, int> _ratingCounts = const {
    5: 236,
    4: 145,
    3: 44,
    2: 56,
    1: 2,
  };

  @override
  Widget build(BuildContext context) {
    final totalReviews = _ratingCounts.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Ulasan',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 16),
              Text(
                'Penilaian',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              _buildRatingSummary(totalReviews),
              const SizedBox(height: 14),
              Text(
                'Filter berdasarkan',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  _buildRatingBar(5, totalReviews),
                  _buildRatingBar(4, totalReviews),
                  _buildRatingBar(3, totalReviews),
                  _buildRatingBar(2, totalReviews),
                  _buildRatingBar(1, totalReviews),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${totalReviews.toString()} Ulasan',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: _reviews
                    .map(
                      (review) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildReviewCard(review),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF1F4C7A), Color(0xFF0E3A63)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ulasan & Feedback dari Klien',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pantau rating, ulasan, dan pengalaman klien dari setiap sesi.',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(int totalReviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            5,
            (index) => Icon(Icons.star, color: _primaryColor, size: 28),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '4.5  •  ${totalReviews.toString()} Ulasan',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar(int rating, int totalReviews) {
    final count = _ratingCounts[rating] ?? 0;
    final percent = totalReviews == 0 ? 0.0 : count / totalReviews;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              rating.toString(),
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _primaryColor,
              ),
            ),
          ),
          const Icon(Icons.star, color: Color(0xFF1B517A), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 6,
                backgroundColor: const Color(0xFFCBD5E1),
                valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 28,
            child: Text(
              count.toString(),
              textAlign: TextAlign.right,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(_ReviewItem review) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  gradient: AppGradients.horizontal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            review.name,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              Icons.star,
                              size: 14,
                              color: index < review.rating
                                  ? const Color(0xFFF5B400)
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          review.daysAgo,
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewItem {
  final String name;
  final String daysAgo;
  final int rating;
  final String comment;

  const _ReviewItem({
    required this.name,
    required this.daysAgo,
    required this.rating,
    required this.comment,
  });
}
