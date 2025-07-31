import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/review.dart';

class FeedbackListScreen extends StatefulWidget {
  final String riderId;
  const FeedbackListScreen({super.key, required this.riderId});

  @override
  State<FeedbackListScreen> createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {
  String _sortBy = 'newest';
  String _filterBy = 'all';

  final List<String> _sortOptions = ['newest', 'oldest', 'highest', 'lowest'];
  final List<String> _filterOptions = [
    'all',
    '5-star',
    '4-star',
    '3-star',
    '2-star',
    '1-star'
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern SliverAppBar with gradient
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: themeProvider.accentColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      themeProvider.accentColor,
                      themeProvider.accentColor.withOpacity(0.8),
                      themeProvider.accentColor.withOpacity(0.9),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40), // Space for back button
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Passenger Reviews',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  'Your rating & feedback',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Main Content
          StreamBuilder<QuerySnapshot>(
            key: ValueKey('${_sortBy}_$_filterBy'),
            stream: FirebaseFirestore.instance
                .collection('reviews')
                .where('riderId', isEqualTo: widget.riderId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: _buildErrorState(),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: _buildEmptyState(),
                );
              }

              final reviews = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Review.fromFirestore(doc);
              }).toList();

              // Apply filtering first, then sorting
              final filteredReviews = _applyFilters(reviews);
              final sortedReviews = _applySorting(filteredReviews);

              return SliverList(
                delegate: SliverChildListDelegate([
                  // Statistics Card
                  _buildStatisticsCard(reviews),

                  // Rating Distribution
                  _buildRatingDistribution(reviews),

                  // Filter and Sort Controls
                  _buildFilterSortControls(),

                  // Reviews List
                  ...sortedReviews
                      .map((review) => _buildReviewCard(review))
                      ,

                  const SizedBox(height: 20),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(List<Review> reviews) {
    if (reviews.isEmpty) return const SizedBox();

    final totalReviews = reviews.length;
    final averageRating =
        reviews.fold(0.0, (sum, review) => sum + review.rating) / totalReviews;
    final ratingCounts = <int, int>{};

    for (int i = 1; i <= 5; i++) {
      ratingCounts[i] =
          reviews.where((review) => review.rating.floor() == i).length;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.grey)
                .withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Provider.of<ThemeProvider>(context)
                      .accentColor
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.analytics,
                  color: Provider.of<ThemeProvider>(context).accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Rating Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Average Rating Display
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Provider.of<ThemeProvider>(context)
                      .accentColor
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Provider.of<ThemeProvider>(context).accentColor,
                      ),
                    ),
                    _buildRatingStars(averageRating, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      '$totalReviews reviews',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, ratingCounts[5] ?? 0, totalReviews),
                    _buildRatingBar(4, ratingCounts[4] ?? 0, totalReviews),
                    _buildRatingBar(3, ratingCounts[3] ?? 0, totalReviews),
                    _buildRatingBar(2, ratingCounts[2] ?? 0, totalReviews),
                    _buildRatingBar(1, ratingCounts[1] ?? 0, totalReviews),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Quick Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickStat(
                  'Excellent',
                  '${((ratingCounts[5] ?? 0) / totalReviews * 100).toStringAsFixed(0)}%',
                  Colors.green),
              _buildQuickStat(
                  'Good',
                  '${((ratingCounts[4] ?? 0) / totalReviews * 100).toStringAsFixed(0)}%',
                  Colors.blue),
              _buildQuickStat(
                  'Average',
                  '${((ratingCounts[3] ?? 0) / totalReviews * 100).toStringAsFixed(0)}%',
                  Colors.orange),
              _buildQuickStat(
                  'Poor',
                  '${(((ratingCounts[2] ?? 0) + (ratingCounts[1] ?? 0)) / totalReviews * 100).toStringAsFixed(0)}%',
                  Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int rating, int count, int total) {
    final percentage = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$rating',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Icon(Icons.star, size: 12, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getRatingColor(rating.toDouble()),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingDistribution(List<Review> reviews) {
    if (reviews.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.grey)
                .withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Provider.of<ThemeProvider>(context)
                      .accentColor
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: Provider.of<ThemeProvider>(context).accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Recent reviews summary
          Row(
            children: [
              Expanded(
                child: _buildActivityCard(
                  'This Month',
                  '${reviews.where((r) => r.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 30)))).length}',
                  Icons.calendar_today,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActivityCard(
                  'This Week',
                  '${reviews.where((r) => r.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 7)))).length}',
                  Icons.date_range,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActivityCard(
                  'Today',
                  '${reviews.where((r) => r.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 1)))).length}',
                  Icons.today,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSortControls() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.grey)
                .withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter & Sort',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sort by:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortBy,
                          isExpanded: true,
                          items: _sortOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(_getSortLabel(value)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null && newValue != _sortBy) {
                              setState(() {
                                _sortBy = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter by:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filterBy,
                          isExpanded: true,
                          items: _filterOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(_getFilterLabel(value)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null && newValue != _filterBy) {
                              setState(() {
                                _filterBy = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.grey)
                .withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Provider.of<ThemeProvider>(context)
                            .accentColor
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Provider.of<ThemeProvider>(context).accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Passenger',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildRatingStars(review.rating, size: 16),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getRatingColor(review.rating).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              _getRatingColor(review.rating).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '${review.rating.toStringAsFixed(1)} ⭐',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getRatingColor(review.rating),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(review.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Feedback
            if (review.feedback.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.format_quote,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Feedback',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.feedback,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Provider.of<ThemeProvider>(context)
                  .accentColor
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.rate_review_outlined,
              size: 60,
              color: Provider.of<ThemeProvider>(context).accentColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Reviews Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'You haven\'t received any passenger reviews yet. Complete some rides to start receiving feedback!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Back to Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Provider.of<ThemeProvider>(context).accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red.withOpacity(0.6),
          ),
          const SizedBox(height: 24),
          Text(
            'Unable to Load Reviews',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'There was an error loading your reviews. Please check your internet connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Provider.of<ThemeProvider>(context).accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: Colors.amber, size: size);
        } else if (index < rating) {
          return Icon(Icons.star_half, color: Colors.amber, size: size);
        } else {
          return Icon(Icons.star_border, color: Colors.grey[400], size: size);
        }
      }),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.0) return Colors.orange;
    if (rating >= 2.0) return Colors.deepOrange;
    return Colors.red;
  }

  String _getSortLabel(String sort) {
    switch (sort) {
      case 'newest':
        return 'Newest First';
      case 'oldest':
        return 'Oldest First';
      case 'highest':
        return 'Highest Rating';
      case 'lowest':
        return 'Lowest Rating';
      default:
        return 'Newest First';
    }
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'all':
        return 'All Reviews';
      case '5-star':
        return '5 Star Only';
      case '4-star':
        return '4 Star Only';
      case '3-star':
        return '3 Star Only';
      case '2-star':
        return '2 Star Only';
      case '1-star':
        return '1 Star Only';
      default:
        return 'All Reviews';
    }
  }

  List<Review> _applyFilters(List<Review> reviews) {
    if (_filterBy == 'all') return reviews;

    try {
      final rating = int.parse(_filterBy.split('-')[0]);
      return reviews.where((review) {
        // Check if the review rating matches the selected star rating
        final reviewRating = review.rating.round();
        return reviewRating == rating;
      }).toList();
    } catch (e) {
      // If parsing fails, return all reviews
      return reviews;
    }
  }

  List<Review> _applySorting(List<Review> reviews) {
    List<Review> sortedReviews = List.from(reviews);

    switch (_sortBy) {
      case 'newest':
        sortedReviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case 'oldest':
        sortedReviews.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case 'highest':
        sortedReviews.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'lowest':
        sortedReviews.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      default:
        sortedReviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    return sortedReviews;
  }
}
