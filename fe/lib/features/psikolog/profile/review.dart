import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hackathon/core/constants.dart';
import 'package:hackathon/core/services/api_client.dart';
import 'package:hackathon/core/theme/app_gradients.dart';

class Review extends StatefulWidget {
  const Review({super.key});

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  final Color _primaryColor = const Color(0xFF1B517A);
  final Color _softBlue = const Color(0xFF7DA0C4);

  late final ApiClient _apiClient = ApiClient(
    baseUrl: AppConstants.baseUrl,
    autoLoadToken: true,
  );

  bool _isLoading = true;
  double _averageRating = 0;
  int _totalReviews = 0;
  List<_RatingBreakdown> _breakdown = [];
  List<_ReviewItem> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/psychologist/me/reviews',
        query: {'limit': '20', 'page': '1'},
      );

      if (!mounted) return;

      if (response.isSuccess) {
        final data = response.data;
        final summary = data['summary'] as Map<String, dynamic>?;

        setState(() {
          _averageRating = (summary?['averageRating'] as num?)?.toDouble() ?? 0;
          _totalReviews = (summary?['totalReviews'] as num?)?.toInt() ?? 0;

          final rawBreakdown = summary?['breakdown'];
          if (rawBreakdown is List) {
            _breakdown = rawBreakdown.map((b) {
              final entry = b as Map<String, dynamic>;
              return _RatingBreakdown(
                rating: (entry['rating'] as num).toInt(),
                count: (entry['count'] as num).toInt(),
              );
            }).toList();
          } else {
            _breakdown = [];
          }

          final rawItems = data['items'];
          if (rawItems is List) {
            _reviews = rawItems.map((r) {
              final item = r as Map<String, dynamic>;
              return _ReviewItem(
                name: item['reviewerName'] as String? ?? 'Anonim',
                daysAgo: item['timeLabel'] as String? ?? '',
                rating: (item['rating'] as num?)?.toInt() ?? 0,
                comment: item['comment'] as String? ?? '',
                photoUrl: item['reviewerPhotoUrl'] as String?,
              );
            }).toList();
          } else {
            _reviews = [];
          }
        });
      }
    } catch (e) {
      debugPrint('Fetch reviews error: $e');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Ulasan',
          style: GoogleFonts.nunito(
            fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
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
                        fontSize: 18, fontWeight: FontWeight.w800, color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildRatingSummary(),
                    const SizedBox(height: 14),
                    Text(
                      'Filter berdasarkan',
                      style: GoogleFonts.nunito(
                        fontSize: 14, fontWeight: FontWeight.w700, color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: _breakdown
                          .map((b) => _buildRatingBar(b.rating, b.count))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$_totalReviews Ulasan',
                      style: GoogleFonts.nunito(
                        fontSize: 14, fontWeight: FontWeight.w800, color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_reviews.isEmpty)
                      _buildEmptyState()
                    else
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _softBlue, width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.rate_review_outlined, size: 48, color: _softBlue),
          const SizedBox(height: 12),
          Text(
            'Belum ada ulasan',
            style: GoogleFonts.nunito(
              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54,
            ),
          ),
        ],
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
              fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pantau rating, ulasan, dan pengalaman klien dari setiap sesi.',
            style: GoogleFonts.nunito(
              fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              Icons.star,
              color: index < _averageRating.round()
                  ? const Color(0xFFF5B400)
                  : const Color(0xFFE5E7EB),
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${_averageRating.toStringAsFixed(1)}  •  $_totalReviews Ulasan',
          style: GoogleFonts.nunito(
            fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar(int rating, int count) {
    final percent = _totalReviews == 0 ? 0.0 : count / _totalReviews;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              rating.toString(),
              style: GoogleFonts.nunito(
                fontSize: 12, fontWeight: FontWeight.w700, color: _primaryColor,
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
                fontSize: 12, fontWeight: FontWeight.w700, color: _primaryColor,
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
                decoration: BoxDecoration(
                  gradient: AppGradients.horizontal,
                  shape: BoxShape.circle,
                  image: review.photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(review.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: review.photoUrl == null
                    ? const Icon(Icons.person, color: Colors.white, size: 18)
                    : null,
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
                              fontSize: 12, fontWeight: FontWeight.w800, color: _primaryColor,
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
                            fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black45,
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
          if (review.comment.isNotEmpty) ...[
            Text(
              textAlign: TextAlign.left,
              review.comment,
              style: GoogleFonts.nunito(
                fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RatingBreakdown {
  final int rating;
  final int count;

  const _RatingBreakdown({required this.rating, required this.count});
}

class _ReviewItem {
  final String name;
  final String daysAgo;
  final int rating;
  final String comment;
  final String? photoUrl;

  const _ReviewItem({
    required this.name,
    required this.daysAgo,
    required this.rating,
    required this.comment,
    this.photoUrl,
  });
}
