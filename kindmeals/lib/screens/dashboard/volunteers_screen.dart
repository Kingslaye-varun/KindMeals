import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../services/api_service.dart';
import '../../utils/app_localizations.dart';
import 'package:flutter/foundation.dart';

// Motivational content function that builds localized content
List<Map<String, dynamic>> getMotivationalContent(BuildContext context) {
  final localizations = AppLocalizations.of(context);
  
  return [
    {
      'image': 'assets/images/food1.jpg',
      'title': localizations.translate('feed_smile'),
      'subtitle': localizations.translate('meal_brighten'),
      'color': Colors.green,
    },
    {
      'image': 'assets/images/food2.jpg',
      'title': localizations.translate('share_table'),
      'subtitle': localizations.translate('no_hunger'),
      'color': Colors.blue,
    },
    {
      'image': 'assets/images/food3.jpg',
      'title': localizations.translate('food_waste'),
      'subtitle': localizations.translate('rescue_food'),
      'color': Colors.orange,
    },
    {
      'image': 'assets/images/food4.jpg',
      'title': localizations.translate('donate_what'),
      'subtitle': localizations.translate('every_contribution'),
      'color': Colors.purple,
    },
    {
      'image': 'assets/images/food1.jpg',
      'title': localizations.translate('hunger_stat'),
      'subtitle': localizations.translate('change_stat'),
      'color': Colors.teal,
    },
  ];
}

class VolunteersScreen extends StatefulWidget {
  const VolunteersScreen({super.key});

  @override
  State<VolunteersScreen> createState() => _VolunteersScreenState();
}

class _VolunteersScreenState extends State<VolunteersScreen> {
  int _currentCarouselIndex = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _volunteers = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchVolunteers();
  }

  Future<void> _fetchVolunteers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch volunteers from API
      final volunteers = await _apiService.getTopVolunteers(limit: 20);

      if (volunteers.isNotEmpty) {
        if (mounted) {
          setState(() {
            _volunteers = volunteers;

            if (volunteers.isNotEmpty) {
              // Debug log the first item to verify structure
              print('First volunteer data: ${volunteers[0]}');
            }
          });
        }
      } else {
        // Fall back to demo data if API returns empty list
        _setDemoData();
      }
    } catch (e) {
      print('Error fetching volunteers: $e');
      // Fall back to demo data on error
      _setDemoData();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _setDemoData() {
    setState(() {
      _volunteers = [
        {
          'name': 'Emma Thompson',
          'since': '2023',
          'rating': 4.8,
          'avatar': 'https://via.placeholder.com/150',
          'donations': 47,
        },
        {
          'name': 'James Wilson',
          'since': '2022',
          'rating': 4.6,
          'avatar': 'https://via.placeholder.com/150',
          'donations': 63,
        },
        {
          'name': 'Sarah Johnson',
          'since': '2023',
          'rating': 4.9,
          'avatar': 'https://via.placeholder.com/150',
          'donations': 32,
        },
        {
          'name': 'Michael Chen',
          'since': '2021',
          'rating': 4.7,
          'avatar': 'https://via.placeholder.com/150',
          'donations': 78,
        },
        {
          'name': 'Olivia Rodriguez',
          'since': '2022',
          'rating': 4.5,
          'avatar': 'https://via.placeholder.com/150',
          'donations': 41,
        },
        {
          'name': 'William Davis',
          'since': '2023',
          'rating': 4.4,
          'avatar': 'https://via.placeholder.com/150',
          'donations': 28,
        },
        {
          'name': 'Lisa Kumar',
          'since': '2021',
          'rating': 4.9,
          'avatar': 'https://via.placeholder.com/150',
          'donations': 85,
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get translated motivational content
    final motivationalContent = getMotivationalContent(context);
    final localizations = AppLocalizations.of(context);
    
    // Debug print to diagnose data structure
    if (_volunteers.isNotEmpty && kDebugMode) {
      print('Volunteer data sample: ${_volunteers[0]}');
    }

    // Sort volunteers by donations in descending order
    final sortedVolunteers = List<Map<String, dynamic>>.from(_volunteers);
    sortedVolunteers
        .sort((a, b) => (b['donations'] ?? 0).compareTo(a['donations'] ?? 0));

    if (kDebugMode) {
      print('Sorted ${sortedVolunteers.length} volunteers by donations');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('volunteers')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchVolunteers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Motivational Carousel
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 160,
                            viewportFraction: 0.9,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: true,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 5),
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentCarouselIndex = index;
                              });
                            },
                          ),
                          items: motivationalContent.map((item) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: item['color'] as Color,
                                    borderRadius: BorderRadius.circular(16),
                                    image: DecorationImage(
                                      image:
                                          AssetImage(item['image'] as String),
                                      fit: BoxFit.cover,
                                      colorFilter: ColorFilter.mode(
                                        (item['color'] as Color)
                                            .withOpacity(0.7),
                                        BlendMode.srcATop,
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          item['title'] as String,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item['subtitle'] as String,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              motivationalContent.asMap().entries.map((entry) {
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentCarouselIndex == entry.key
                                    ? Colors.green
                                    : Colors.grey.shade300,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // Leaderboard Section
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                    child: Text(
                      localizations.translate('volunteer_leaderboard'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Stats Container
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                            localizations.translate('total_volunteers'), '${sortedVolunteers.length}'),
                        _buildStatColumn(
                          localizations.translate('total_deliveries'),
                          '${sortedVolunteers.fold<int>(0, (sum, item) => sum + (item['donations'] as int))}',
                        ),
                        _buildStatColumn(
                          localizations.translate('avg_deliveries'),
                          sortedVolunteers.isEmpty
                              ? '0'
                              : (sortedVolunteers.fold<int>(
                                          0,
                                          (sum, item) =>
                                              sum +
                                              (item['donations'] as int)) /
                                      sortedVolunteers.length)
                                  .toStringAsFixed(1),
                        ),
                      ],
                    ),
                  ),

                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text(
                            localizations.translate('rank'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            localizations.translate('volunteer'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                            localizations.translate('deliveries'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Volunteer List
                  sortedVolunteers.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              localizations.translate('no_volunteers_found'),
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sortedVolunteers.length,
                          itemBuilder: (context, index) {
                            final volunteer = sortedVolunteers[index];
                            final rank = index + 1;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              elevation: 0.5,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 8),
                                child: Row(
                                  children: [
                                    // Rank with medal for top 3
                                    SizedBox(
                                      width: 50,
                                      child: _buildRankWidget(rank),
                                    ),

                                    // Avatar and volunteer info
                                    Expanded(
                                      child: Row(
                                        children: [
                                          // Avatar
                                          _buildVolunteerAvatar(
                                              volunteer['avatar']),
                                          const SizedBox(width: 16),
                                          // Name and subtitle
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  volunteer['name'] as String,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  '${volunteer['donations']} ${localizations.translate('deliveries_made')}',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Donations count
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        '${volunteer['donations']}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/register/volunteer');
        },
        icon: const Icon(Icons.volunteer_activism),
        label: Text(localizations.translate('become_volunteer')),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildVolunteerAvatar(dynamic profileImage) {
    if (profileImage == null || profileImage.toString().isEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey.shade200,
        child: Icon(
          Icons.person,
          color: Colors.grey.shade500,
          size: 30,
        ),
      );
    }

    final imageUrl = profileImage.toString();

    try {
      // Handle API server uploads
      if (imageUrl.startsWith('/uploads')) {
        return CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(
            '${ApiService.baseUrl}${imageUrl}',
          ),
          onBackgroundImageError: (e, stackTrace) {
            if (kDebugMode) {
              print('Error loading profile image from API server: $e');
            }
          },
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person, color: Colors.white),
        );
      }
      // Handle network URLs (http/https)
      else if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
        return CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(imageUrl),
          onBackgroundImageError: (e, stackTrace) {
            if (kDebugMode) {
              print('Error loading profile image from URL: $e');
            }
          },
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person, color: Colors.white),
        );
      }
      // Handle asset paths
      else if (imageUrl.startsWith('assets/')) {
        return CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage(imageUrl),
          backgroundColor: Colors.grey.shade200,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling avatar image: $e');
      }
    }

    // Default case: no image or invalid image path
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey.shade200,
      child: Icon(
        Icons.person,
        color: Colors.grey.shade500,
        size: 30,
      ),
    );
  }

  Widget _buildStatColumn(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildRankWidget(int rank) {
    if (rank <= 3) {
      // Medal for top 3
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getMedalColor(rank - 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: _getMedalIcon(rank),
        ),
      );
    } else {
      // Regular rank indicator for others
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Center(
          child: Text(
            '$rank',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
  }

  Widget _getMedalIcon(int rank) {
    switch (rank) {
      case 1:
        return const Icon(Icons.emoji_events, color: Colors.white, size: 24);
      case 2:
        return const Icon(Icons.emoji_events, color: Colors.white, size: 22);
      case 3:
        return const Icon(Icons.emoji_events, color: Colors.white, size: 20);
      default:
        return Text(
          '$rank',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }

  Color _getMedalColor(int position) {
    switch (position) {
      case 0:
        return Colors.amber.shade700; // Gold
      case 1:
        return Colors.blueGrey.shade400; // Silver
      case 2:
        return Colors.brown.shade400; // Bronze
      default:
        return Colors.grey.shade500;
    }
  }
}
