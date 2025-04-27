// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'volunteer_dashboard.dart';
import 'volunteerprofile.dart';
import '../../config/api_config.dart';

class VolunteerHistoryScreen extends StatefulWidget {
  const VolunteerHistoryScreen({super.key});

  @override
  State<VolunteerHistoryScreen> createState() => _VolunteerHistoryScreenState();
}

class _VolunteerHistoryScreenState extends State<VolunteerHistoryScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _acceptedDonations = [];
  List<Map<String, dynamic>> _filteredDonations = [];
  String _filterCriteria = 'All'; // Default filter
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistoryData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch volunteer's accepted donations
      final donations = await _apiService.getVolunteerDonationHistory();

      // REMOVED: We don't want to show pending deliveries in the history view
      // The dashboard should show pending deliveries, not the history

      setState(() {
        _acceptedDonations = donations;
        _filteredDonations = donations;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading volunteer history: $e');
      }
      setState(() {
        _acceptedDonations = [];
        _filteredDonations = [];
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error loading history: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VolunteerDashboardScreen()),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VolunteerProfileScreen()),
    );
  }

  void _filterDonations(String criteria) {
    setState(() {
      _filterCriteria = criteria;

      if (criteria == 'All') {
        _filteredDonations = _acceptedDonations;
      } else if (criteria == 'Last Week') {
        final lastWeek = DateTime.now().subtract(const Duration(days: 7));
        _filteredDonations = _acceptedDonations.where((donation) {
          final acceptedAt = DateTime.parse(
              donation['acceptedAt'] ?? DateTime.now().toString());
          return acceptedAt.isAfter(lastWeek);
        }).toList();
      } else if (criteria == 'Last Month') {
        final lastMonth = DateTime.now().subtract(const Duration(days: 30));
        _filteredDonations = _acceptedDonations.where((donation) {
          final acceptedAt = DateTime.parse(
              donation['acceptedAt'] ?? DateTime.now().toString());
          return acceptedAt.isAfter(lastMonth);
        }).toList();
      } else if (criteria == 'Veg') {
        _filteredDonations = _acceptedDonations
            .where((donation) => donation['foodType'] == 'veg')
            .toList();
      } else if (criteria == 'Non-Veg') {
        _filteredDonations = _acceptedDonations
            .where((donation) => donation['foodType'] == 'nonveg')
            .toList();
      }
    });
  }

  void _searchDonations(String query) {
    if (query.isEmpty) {
      _filterDonations(_filterCriteria);
      return;
    }

    setState(() {
      _filteredDonations = _acceptedDonations.where((donation) {
        final donorName = (donation['donorName'] ?? '').toLowerCase();
        final foodName = (donation['foodName'] ?? '').toLowerCase();
        final recipientName = (donation['recipientName'] ?? '').toLowerCase();
        final description = (donation['description'] ?? '').toLowerCase();
        final searchLower = query.toLowerCase();

        return donorName.contains(searchLower) ||
            foodName.contains(searchLower) ||
            recipientName.contains(searchLower) ||
            description.contains(searchLower);
      }).toList();
    });
  }

  void _showDeliveryDetails(Map<String, dynamic> donation) {
    // Format dates
    final acceptedAt = donation['acceptedAt'] != null
        ? _formatDateTimeIST(donation['acceptedAt'])
        : 'Unknown date';

    final expiryDateTime = donation['expiryDateTime'] != null
        ? _formatDateTimeIST(donation['expiryDateTime'])
        : 'Unknown date';

    // Estimate delivery stats (for demonstration)
    final deliveryTime = '25 minutes';
    final distanceTraveled = '3.8 km';
    final carbonSaved = '0.76 kg';

    // Get food image URL with updated API config
    String? imageUrl;
    if (donation['imageUrl'] != null &&
        donation['imageUrl'].toString().isNotEmpty) {
      imageUrl = ApiConfig.getImageUrl(donation['imageUrl']);
      if (kDebugMode) {
        print('Image URL for food: $imageUrl');
      }
    }

    // Get donor information with improved fallbacks
    final donorInfo = donation['donorInfo'] ?? {};
    final donorName = donorInfo['donorname'] ??
        donorInfo['donorName'] ??
        donation['donorName'] ??
        'Unknown Donor';
    final donorContact = donation['donorContact'] ??
        donorInfo['donorContact'] ??
        'Contact not available';
    final donorAddress = donation['donorAddress'] ??
        donation['location']?['address'] ??
        donorInfo['donorAddress'] ??
        'Address not available';

    final recipientInfo = donation['recipientInfo'] ?? {};
    final recipientName = donation['recipientName'] ??
        recipientInfo['recipientName'] ??
        'Unknown Recipient';
    final recipientContact = donation['recipientContact'] ??
        recipientInfo['recipientContact'] ??
        'Contact not available';
    final recipientAddress = donation['recipientAddress'] ??
        recipientInfo['recipientAddress'] ??
        'Address not available';

    // Determine food type icon
    IconData foodTypeIcon = Icons.restaurant;
    Color foodTypeColor = Colors.grey;

    if (donation['foodType'] == 'veg') {
      foodTypeIcon = Icons.eco;
      foodTypeColor = Colors.green;
    } else if (donation['foodType'] == 'nonveg') {
      foodTypeIcon = FontAwesomeIcons.drumstickBite;
      foodTypeColor = Colors.red;
    } else if (donation['foodType'] == 'jain') {
      foodTypeIcon = Icons.spa;
      foodTypeColor = Colors.green.shade800;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 10),
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Delivery Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ),

            // Food image if available
            if (imageUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade400,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

            // Delivery info
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status and time
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green.shade50,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Delivery Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Completed on $acceptedAt',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Delivery stats
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery Stats',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                  Icons.timer, deliveryTime, 'Delivery Time'),
                              _buildStatItem(Icons.directions_car,
                                  distanceTraveled, 'Distance'),
                              _buildStatItem(
                                  Icons.eco, carbonSaved, 'Carbon Saved'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Food details
                    _buildDetailSection(
                      'Food Details',
                      Icons.restaurant,
                      [
                        _buildDetailRow(
                            'Food Name', donation['foodName'] ?? 'Unknown'),
                        _buildDetailRow('Food Type',
                            (donation['foodType'] ?? 'Unknown').toUpperCase(),
                            icon: foodTypeIcon, iconColor: foodTypeColor),
                        _buildDetailRow('Quantity',
                            '${donation['quantity'] ?? 0} servings'),
                        _buildDetailRow('Expires On', expiryDateTime),
                        _buildDetailRow(
                            'Description',
                            donation['description'] ??
                                'No description provided'),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Donor details
                    _buildDetailSection(
                      'Donor Information',
                      Icons.person,
                      [
                        _buildDetailRow('Name', donorName),
                        _buildDetailRow('Contact', donorContact),
                        _buildDetailRow('Address', donorAddress),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Recipient details
                    _buildDetailSection(
                      'Recipient Information',
                      Icons.person_outline,
                      [
                        _buildDetailRow('Name', recipientName),
                        _buildDetailRow('Contact', recipientContact),
                        _buildDetailRow('Address', recipientAddress),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Download & Share buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Generate and download delivery report
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Downloading delivery report...')),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('REPORT'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green.shade700,
                              side: BorderSide(color: Colors.green.shade700),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Share delivery details
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Sharing delivery details...')),
                              );
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('SHARE'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.green.shade700,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailSection(
      String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.green.shade700,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {IconData? icon, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: iconColor ?? Colors.grey),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  // App Bar with Hero Animation and Gradient
                  SliverAppBar(
                    expandedHeight: 180,
                    floating: true,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.refresh, size: 20),
                          ),
                          onPressed: _loadHistoryData,
                        ),
                      ),
                    ],
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade700.withOpacity(0.85),
                            Colors.green.shade500.withOpacity(0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: FlexibleSpaceBar(
                        title: const Text(
                          'Your Deliveries',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            shadows: [
                              Shadow(
                                offset: Offset(1.0, 1.0),
                                blurRadius: 3.0,
                                color: Color.fromARGB(150, 0, 0, 0),
                              ),
                            ],
                          ),
                        ),
                        background: Stack(
                          children: [
                            // Background image
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/food_del.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Gradient overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.1),
                                      Colors.green.shade700.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Content
                            Positioned(
                              bottom: 70,
                              left: 20,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delivery_dining,
                                          size: 16,
                                          color: Colors.green.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${_acceptedDonations.length} Deliveries',
                                          style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: Column(
                children: [
                  // Search and filter section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(
                        top: 16, left: 16, right: 16, bottom: 8),
                    child: Column(
                      children: [
                        // Modern search bar
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search deliveries...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade500,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.green.shade200),
                            ),
                          ),
                          onChanged: _searchDonations,
                        ),

                        const SizedBox(height: 16),

                        // Enhanced filter chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(
                                  'All', Icons.all_inclusive_outlined),
                              _buildFilterChip(
                                  'Last Week', Icons.calendar_today_outlined),
                              _buildFilterChip(
                                  'Last Month', Icons.date_range_outlined),
                              _buildFilterChip('Veg', Icons.eco_outlined),
                              _buildFilterChip(
                                  'Non-Veg', FontAwesomeIcons.drumstickBite,
                                  isSmall: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Results count
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.history_rounded,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          'Showing ${_filteredDonations.length} deliveries',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        // Sort dropdown
                        Row(
                          children: [
                            Icon(Icons.sort,
                                size: 14, color: Colors.grey.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'Recent first',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down,
                                size: 18, color: Colors.grey.shade700),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // List of deliveries
                  Expanded(
                    child: _filteredDonations.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _filteredDonations.length,
                            itemBuilder: (context, index) {
                              return _buildDeliveryCard(
                                  _filteredDonations[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: _filteredDonations.isNotEmpty
          ? FloatingActionButton(
              onPressed: _loadHistoryData,
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              elevation: 4,
              tooltip: 'Refresh deliveries',
              child: const Icon(Icons.refresh),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            _navigateToDashboard();
          } else if (index == 2) {
            _navigateToProfile();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.delivery_dining_outlined,
              size: 70,
              color: Colors.green.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No delivery history found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _acceptedDonations.isEmpty
                  ? 'Start accepting donations from the dashboard to see your delivery history'
                  : 'Try changing your search filters to find your deliveries',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          if (_acceptedDonations.isEmpty)
            ElevatedButton.icon(
              onPressed: _navigateToDashboard,
              icon: const Icon(Icons.dashboard),
              label: const Text('Go to Dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, {bool isSmall = false}) {
    final isSelected = _filterCriteria == label;

    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: isSmall ? 12 : 16,
          color: isSelected ? Colors.green.shade700 : Colors.grey.shade600,
        ),
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Colors.green.shade700 : Colors.grey.shade700,
        ),
        selected: isSelected,
        onSelected: (selected) {
          _filterDonations(label);
        },
        selectedColor: Colors.green.shade50,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: BorderSide(
            color: isSelected ? Colors.green.shade200 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
        elevation: 0,
        pressElevation: 0,
      ),
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> donation) {
    // Format dates
    final acceptedAt = donation['acceptedAt'] != null
        ? _formatRelativeTime(donation['acceptedAt'])
        : 'Recently';

    final foodName = donation['foodName'] ?? 'Unknown Food';
    final quantity = donation['quantity'] ?? 0;
    final foodType = donation['foodType']?.toString().toLowerCase() ?? '';

    // Get donor information with improved fallbacks
    final donorInfo = donation['donorInfo'] ?? {};
    final donorName = donorInfo['donorname'] ??
        donorInfo['donorName'] ??
        donation['donorName'] ??
        'Unknown Donor';

    // Get recipient information

    // Food type icon and color
    final (IconData foodTypeIcon, Color foodTypeColor) =
        _getFoodTypeUI(foodType);

    // Get food image URL with updated API config
    String? imageUrl;
    if (donation['imageUrl'] != null &&
        donation['imageUrl'].toString().isNotEmpty) {
      imageUrl = ApiConfig.getImageUrl(donation['imageUrl']);
      if (kDebugMode) {
        print('Image URL for food card: $imageUrl');
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Food image or icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: foodTypeColor.withOpacity(0.1),
                              child: Icon(
                                foodTypeIcon,
                                color: foodTypeColor,
                                size: 26,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: foodTypeColor.withOpacity(0.1),
                          child: Icon(
                            foodTypeIcon,
                            color: foodTypeColor,
                            size: 26,
                          ),
                        ),
                ),

                const SizedBox(width: 12),

                // Middle - Food and delivery details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food name
                      Text(
                        foodName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Type tag
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: foodTypeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  foodTypeIcon,
                                  size: 10,
                                  color: foodTypeColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  foodType.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: foodTypeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Quantity
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 10,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$quantity servings',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Donor and recipient names
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.storefront_outlined,
                                  size: 12,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    donorName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Delivery time
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                acceptedAt,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(color: Colors.grey.shade200, height: 1),

          // Status badge and View Details button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 12,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Delivered',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Direct link to Full Details popup
                TextButton.icon(
                  onPressed: () {
                    _showDeliveryDetails(donation);
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.blue,
                  ),
                  label: const Text(
                    'View Details',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color) _getFoodTypeUI(String foodType) {
    if (foodType == 'veg') {
      return (Icons.eco, Colors.green);
    } else if (foodType == 'nonveg') {
      return (FontAwesomeIcons.drumstickBite, Colors.red);
    } else if (foodType == 'jain') {
      return (Icons.spa, Colors.green.shade800);
    } else {
      return (Icons.restaurant, Colors.grey.shade700);
    }
  }

  String _formatRelativeTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Recently';
    try {
      final dateTime = DateTime.parse(dateTimeStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 7) {
        // Format as date when more than a week old
        return DateFormat('d MMM').format(dateTime);
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting relative time: $e');
      }
      return 'Recently';
    }
  }

  // Helper method to format date time in IST
  String _formatDateTimeIST(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Unknown';
    try {
      final dateTime = DateTime.parse(dateTimeStr).toLocal();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting date: $e');
      }
      return 'Unknown';
    }
  }
}
