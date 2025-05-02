// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class DonorLeaderboardScreen extends StatefulWidget {
  final List<Map<String, dynamic>> donors;

  const DonorLeaderboardScreen({super.key, required this.donors});

  @override
  State<DonorLeaderboardScreen> createState() => _DonorLeaderboardScreenState();
}

class _DonorLeaderboardScreenState extends State<DonorLeaderboardScreen> {
  final _apiService = ApiService();
  String _sortBy = 'meals'; // Default sort by meals donated
  bool _ascending = false; // Default descending order
  bool _isRefreshing = false;
  List<Map<String, dynamic>> _donorsList = [];

  @override
  void initState() {
    super.initState();
    _donorsList = List<Map<String, dynamic>>.from(widget.donors);
    if (_donorsList.isEmpty) {
      _refreshDonorData();
    }
  }

  Future<void> _refreshDonorData() async {
    if (mounted) {
      setState(() {
        _isRefreshing = true;
      });
    }

    try {
      // Fetch top donors
      final donors = await _apiService.getTopDonors(limit: 20);
      if (donors.isNotEmpty && mounted) {
        setState(() {
          _donorsList = donors.map((donor) {
            return {
              'name': donor['donorname'] ?? donor['orgName'] ?? 'Donor',
              'meals': donor['donationCount'] ?? 0,
              'avatar': donor['profileImage'],
            };
          }).toList();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching donor data: $e');
      }
      // If API fails, we'll use existing data
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create a copy of the donors list to sort
    final sortedDonors = List<Map<String, dynamic>>.from(_donorsList);

    // Sort the list based on current sort settings
    if (_sortBy == 'meals') {
      sortedDonors.sort((a, b) => _ascending
          ? a['meals'].compareTo(b['meals'])
          : b['meals'].compareTo(a['meals']));
    } else if (_sortBy == 'name') {
      sortedDonors.sort((a, b) => _ascending
          ? a['name'].compareTo(b['name'])
          : b['name'].compareTo(a['name']));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Donor Leaderboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade600,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDonorData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  // Toggle ascending/descending if the same sort option is selected
                  _ascending = !_ascending;
                } else {
                  // Set new sort option and default to descending for 'meals' or ascending for 'name'
                  _sortBy = value;
                  _ascending = value == 'name';
                }
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'meals',
                child: Text('Sort by Meals Donated'),
              ),
              const PopupMenuItem<String>(
                value: 'name',
                child: Text('Sort by Name'),
              ),
            ],
          ),
        ],
      ),
      body: _isRefreshing
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
              children: [
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
                          'Total Donors', '${sortedDonors.length}'),
                      _buildStatColumn('Total Meals',
                          '${sortedDonors.fold<int>(0, (sum, item) => sum + (item['meals'] as int))}'),
                      _buildStatColumn(
                          'Avg Donation',
                          sortedDonors.isEmpty
                              ? '0'
                              : (sortedDonors.fold<int>(
                                          0,
                                          (sum, item) =>
                                              sum + (item['meals'] as int)) /
                                      sortedDonors.length)
                                  .toStringAsFixed(1)),
                    ],
                  ),
                ),

                // Table Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                          width: 50,
                          child: Text(
                            'Rank',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      Expanded(
                        child: Text(
                          'Donor',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          'Meals',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                // Donor List
                sortedDonors.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No donors available',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _refreshDonorData,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Refresh'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Expanded(
                        child: RefreshIndicator(
                          onRefresh: _refreshDonorData,
                          color: Colors.green.shade600,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: sortedDonors.length,
                            itemBuilder: (context, index) {
                              final donor = sortedDonors[index];
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

                                      // Avatar and donor info
                                      Expanded(
                                        child: Row(
                                          children: [
                                            // Avatar
                                            _buildDonorAvatar(donor['avatar']),
                                            const SizedBox(width: 16),
                                            // Name and subtitle
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    donor['name'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    '${donor['meals']} meals donated',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Meals count with food icon
                                      SizedBox(
                                        width: 80,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.restaurant,
                                              size: 16,
                                              color: Colors.green.shade700,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${donor['meals']}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.green.shade800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ],
            ),
    );
  }

  Widget _buildDonorAvatar(dynamic profileImage) {
    // If profile image is null or empty, show a placeholder
    if (profileImage == null || profileImage.toString().isEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.green.shade100,
        child: Icon(
          Icons.store,
          color: Colors.green.shade700,
          size: 26,
        ),
      );
    }

    String imageUrl = '';

    // Process the image URL based on its format
    if (profileImage.toString().startsWith('/')) {
      // Image from backend
      imageUrl = ApiConfig.getImageUrl(profileImage);
    } else {
      // Direct URL
      imageUrl = profileImage.toString();
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.green.shade100,
      backgroundImage: NetworkImage(imageUrl),
      onBackgroundImageError: (e, stackTrace) {
        if (kDebugMode) {
          print('Error loading profile image: $e');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.green.shade200,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getMedalColor(rank),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    } else {
      // Regular rank indicator for others
      return Container(
        width: 36,
        height: 36,
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

  Color _getMedalColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade700; // Gold
      case 2:
        return Colors.blueGrey.shade400; // Silver
      case 3:
        return Colors.brown.shade400; // Bronze
      default:
        return Colors.blue;
    }
  }
}
