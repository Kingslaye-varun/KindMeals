import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'volunteer_dashboard.dart';
import 'volunteerprofile.dart';

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
  TextEditingController _searchController = TextEditingController();

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

      // ALSO fetch pending deliveries that need volunteer
      final pendingDeliveries =
          await _apiService.getAcceptedDonationsForVolunteer();

      // Combine both types of donations
      final allDonations = [...donations, ...pendingDeliveries];

      setState(() {
        _acceptedDonations = allDonations;
        _filteredDonations = allDonations;
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
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');
    final acceptedAt = donation['acceptedAt'] != null
        ? dateFormat.format(DateTime.parse(donation['acceptedAt']))
        : 'Unknown date';

    // Estimate delivery stats (for demonstration)
    final deliveryTime = '25 minutes';
    final distanceTraveled = '3.8 km';
    final carbonSaved = '0.76 kg';

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
                            (donation['foodType'] ?? 'Unknown').toUpperCase()),
                        _buildDetailRow('Quantity',
                            '${donation['quantity'] ?? 0} servings'),
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
                        _buildDetailRow(
                            'Name', donation['donorName'] ?? 'Unknown'),
                        _buildDetailRow('Contact',
                            donation['donorContact'] ?? 'Not available'),
                        _buildDetailRow('Address',
                            donation['donorAddress'] ?? 'Not available'),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Recipient details
                    _buildDetailSection(
                      'Recipient Information',
                      Icons.person_outline,
                      [
                        _buildDetailRow(
                            'Name', donation['recipientName'] ?? 'Unknown'),
                        _buildDetailRow('Contact',
                            donation['recipientContact'] ?? 'Not available'),
                        _buildDetailRow('Address',
                            donation['recipientAddress'] ?? 'Not available'),
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

  Widget _buildDetailRow(String label, String value) {
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery History'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistoryData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHistoryData,
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search deliveries...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      onChanged: _searchDonations,
                    ),
                  ),

                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        _buildFilterChip('Last Week'),
                        _buildFilterChip('Last Month'),
                        _buildFilterChip('Veg'),
                        _buildFilterChip('Non-Veg'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Results count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.history,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Showing ${_filteredDonations.length} deliveries',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // List of deliveries
                  Expanded(
                    child: _filteredDonations.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history_toggle_off,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'No delivery history found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _acceptedDonations.isEmpty
                                      ? 'Start accepting donations from the dashboard'
                                      : 'Try changing your filters',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                if (_acceptedDonations.isEmpty)
                                  ElevatedButton.icon(
                                    onPressed: _navigateToDashboard,
                                    icon: const Icon(Icons.home),
                                    label: const Text('Go to Dashboard'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _filteredDonations.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () => _showDeliveryDetails(
                                    _filteredDonations[index]),
                                child: _buildDonationHistoryCard(
                                    _filteredDonations[index]),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
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
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.green,
        elevation: 8,
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterCriteria == label;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          _filterDonations(label);
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: Colors.green.shade100,
        checkmarkColor: Colors.green.shade700,
        labelStyle: TextStyle(
          color: isSelected ? Colors.green.shade700 : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildDonationHistoryCard(Map<String, dynamic> donation) {
    // Format dates
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');
    final acceptedAt = donation['acceptedAt'] != null
        ? dateFormat.format(DateTime.parse(donation['acceptedAt']))
        : 'Unknown date';

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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade50,
                  child: Icon(
                    Icons.restaurant,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donation['donorName'] ?? 'Unknown Donor',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Accepted on $acceptedAt',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Delivered',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(foodTypeIcon, size: 16, color: foodTypeColor),
                      const SizedBox(width: 8),
                      Text(
                        donation['foodType']?.toString().toUpperCase() ??
                            'FOOD',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: foodTypeColor,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.people, size: 14, color: Colors.blue.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Served ${donation['quantity']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    donation['foodName'] ?? 'Unknown Food',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    donation['description'] ?? 'No description provided',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DONOR',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        donation['donorName'] ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RECIPIENT',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        donation['recipientName'] ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showDeliveryDetails(donation),
                  icon: Icon(Icons.info_outline,
                      size: 16, color: Colors.green.shade700),
                  label: Text(
                    'View Details',
                    style: TextStyle(color: Colors.green.shade700),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
