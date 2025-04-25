// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class VolunteerLeaderboardScreen extends StatefulWidget {
  final List<Map<String, dynamic>> volunteers;

  const VolunteerLeaderboardScreen({super.key, required this.volunteers});

  @override
  State<VolunteerLeaderboardScreen> createState() =>
      _VolunteerLeaderboardScreenState();
}

class _VolunteerLeaderboardScreenState
    extends State<VolunteerLeaderboardScreen> {
  String _sortBy = 'donations'; // Default sort by donations
  bool _ascending = false; // Default descending order

  @override
  Widget build(BuildContext context) {
    // Create a copy of the volunteers list to sort
    final sortedVolunteers = List<Map<String, dynamic>>.from(widget.volunteers);

    // Sort the list based on current sort settings
    if (_sortBy == 'donations') {
      sortedVolunteers.sort((a, b) => _ascending
          ? a['donations'].compareTo(b['donations'])
          : b['donations'].compareTo(a['donations']));
    } else if (_sortBy == 'name') {
      sortedVolunteers.sort((a, b) => _ascending
          ? a['name'].compareTo(b['name'])
          : b['name'].compareTo(a['name']));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Leaderboard'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  // Toggle ascending/descending if the same sort option is selected
                  _ascending = !_ascending;
                } else {
                  // Set new sort option and default to descending for 'donations' or ascending for 'name'
                  _sortBy = value;
                  _ascending = value == 'name';
                }
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'donations',
                child: Text('Sort by Donations'),
              ),
              const PopupMenuItem<String>(
                value: 'name',
                child: Text('Sort by Name'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
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
                    'Total Volunteers', '${sortedVolunteers.length}'),
                _buildStatColumn('Total Deliveries',
                    '${sortedVolunteers.fold<int>(0, (sum, item) => sum + (item['donations'] as int))}'),
                _buildStatColumn(
                    'Avg Deliveries',
                    (sortedVolunteers.fold<int>(
                                0,
                                (sum, item) =>
                                    sum + (item['donations'] as int)) /
                            sortedVolunteers.length)
                        .toStringAsFixed(1)),
              ],
            ),
          ),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
            ),
            child: Row(
              children: [
                SizedBox(
                    width: 50,
                    child: Text(
                      'Rank',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                Expanded(
                  child: Text(
                    'Volunteer',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Deliveries',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Volunteer List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: sortedVolunteers.length,
              itemBuilder: (context, index) {
                final volunteer = sortedVolunteers[index];
                final rank = index + 1;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  elevation: 0.5,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: volunteer['avatar']
                                            .toString()
                                            .startsWith('http') ||
                                        volunteer['avatar']
                                            .toString()
                                            .startsWith('https')
                                    ? NetworkImage(volunteer['avatar'])
                                        as ImageProvider
                                    : AssetImage(volunteer['avatar']
                                            .toString()
                                            .isNotEmpty
                                        ? volunteer['avatar']
                                        : 'assets/images/volunteer1.jpg'),
                                backgroundColor: Colors.grey.shade200,
                                onBackgroundImageError: (_, __) {},
                                child: volunteer['avatar'].toString().isEmpty ||
                                        (!(volunteer['avatar']
                                                    .toString()
                                                    .startsWith('http') ||
                                                volunteer['avatar']
                                                    .toString()
                                                    .startsWith('https')) &&
                                            !volunteer['avatar']
                                                .toString()
                                                .startsWith('assets/'))
                                    ? const Icon(Icons.person,
                                        color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              // Name and subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      volunteer['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${volunteer['donations']} deliveries made',
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
                            style: TextStyle(
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
          ),
        ],
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
              offset: Offset(0, 2),
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
        return Icon(Icons.emoji_events, color: Colors.white, size: 24);
      case 2:
        return Icon(Icons.emoji_events, color: Colors.white, size: 22);
      case 3:
        return Icon(Icons.emoji_events, color: Colors.white, size: 20);
      default:
        return Text(
          '$rank',
          style: TextStyle(
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
