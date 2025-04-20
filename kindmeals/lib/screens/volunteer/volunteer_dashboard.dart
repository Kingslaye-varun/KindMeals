import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/firebase_service.dart';
import '../../services/api_service.dart';
import 'volunteerhistory.dart';
import 'volunteerprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  State<VolunteerDashboardScreen> createState() =>
      _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  final _firebaseService = FirebaseService();
  final _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _deliveryOpportunities = [];
  Map<String, dynamic> _volunteerProfile = {};
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get volunteer profile data from API
      try {
        final userProfile = await _apiService.getDirectUserProfile();
        if (userProfile['profile'] != null) {
          setState(() {
            _volunteerProfile = userProfile['profile'];
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching volunteer profile: $e');
        }
        // Use placeholder data when profile fetch fails
        setState(() {
          _volunteerProfile = {
            'volunteerName': 'Volunteer',
            'totalRatings': 0,
            'rating': 0.0,
          };
        });
      }

      // Get accepted donations that need volunteer delivery
      try {
        if (kDebugMode) {
          print('Fetching volunteer opportunities...');
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            print('Current volunteer user: ${user.uid}, ${user.email}');
          } else {
            print('No user signed in - cannot fetch opportunities');
          }
        }

        final opportunities =
            await _apiService.getAcceptedDonationsForVolunteer();

        if (kDebugMode) {
          print('Received ${opportunities.length} opportunities from API');
          if (opportunities.isNotEmpty) {
            print('Sample opportunity: ${opportunities[0]}');
          }
        }

        // Validate each opportunity to ensure it has all required fields
        final validOpportunities = opportunities.where((donation) {
          // Check for essential fields
          return donation.containsKey('_id') &&
              donation.containsKey('foodName') &&
              donation.containsKey('donorName');
        }).toList();

        if (validOpportunities.length < opportunities.length && kDebugMode) {
          print(
              'Filtered out ${opportunities.length - validOpportunities.length} invalid opportunities');
        }

        setState(() {
          _deliveryOpportunities = validOpportunities;
        });

        if (validOpportunities.isEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'No delivery opportunities available right now. Check back later!'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching delivery opportunities: $e');
        }

        setState(() {
          _deliveryOpportunities = [];
        });

        // Show error message only if mounted
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Error loading opportunities: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading data: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _acceptDeliveryOpportunity(String acceptedDonationId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Call API to accept donation delivery
      await _apiService.volunteerAcceptDelivery(
        acceptedDonationId: acceptedDonationId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh data
      _loadData();
    } catch (e) {
      if (kDebugMode) {
        print('Error accepting delivery: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to accept delivery: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  // Navigation to other screens
  void _navigateToVolunteerHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VolunteerHistoryScreen()),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VolunteerProfileScreen()),
    );
  }

  Future<void> _logOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _firebaseService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Do you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
        );

        if (result == true) {
          await _firebaseService.signOut();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            );
          }
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Volunteer Dashboard'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logOut,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildDashboardView(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 0) {
              // Already on dashboard
              setState(() {
                _selectedIndex = 0;
              });
            } else if (index == 1) {
              // Go to history
              _navigateToVolunteerHistory();
            } else if (index == 2) {
              // Go to profile
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Refresh available donations
            setState(() {
              _isLoading = true;
            });
            _loadData();
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  Widget _buildDashboardView() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildVolunteerProfile(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.delivery_dining, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        '${_deliveryOpportunities.length} Delivery ${_deliveryOpportunities.length == 1 ? 'Request' : 'Requests'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      // Force refresh with debug info
                      if (kDebugMode) {
                        print(
                            'DEBUG: Force refreshing volunteer opportunities...');

                        // Check current user and auth state
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          print(
                              'DEBUG: Current user: ${user.uid}, ${user.email}');
                          print('DEBUG: Token: ${await user.getIdToken(true)}');
                        } else {
                          print('DEBUG: No user is signed in!');
                        }
                      }
                      _loadData();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (_deliveryOpportunities.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.no_food,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No delivery requests available right now',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Delivery requests appear here when recipients need volunteer assistance.\n\nRecipients must accept donations and select "Need Volunteer Help" when accepting.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _loadData,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Refresh'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: _navigateToVolunteerHistory,
                                icon: const Icon(Icons.history),
                                label: const Text('View History'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return _buildDeliveryRequestCard(_deliveryOpportunities[index]);
              },
              childCount: _deliveryOpportunities.isEmpty
                  ? 1
                  : _deliveryOpportunities.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerProfile() {
    // Extract volunteer name and rating from profile data
    final name = _volunteerProfile['volunteerName'] ?? 'Volunteer';
    final deliveries = _volunteerProfile['totalRatings'] ?? 0;
    final rating = _volunteerProfile['rating'] ?? 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade500, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 36,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$deliveries Deliveries Completed',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
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
    );
  }

  Widget _buildDeliveryRequestCard(Map<String, dynamic> donation) {
    // Calculate time since acceptance with null safety
    String acceptedTime = 'Recently';
    if (donation['acceptedAt'] != null) {
      try {
        final acceptedAt = DateTime.parse(donation['acceptedAt']);
        final now = DateTime.now();
        final difference = now.difference(acceptedAt);

        if (difference.inDays > 0) {
          acceptedTime = '${difference.inDays} days ago';
        } else if (difference.inHours > 0) {
          acceptedTime = '${difference.inHours} hours ago';
        } else if (difference.inMinutes > 0) {
          acceptedTime = '${difference.inMinutes} minutes ago';
        } else {
          acceptedTime = 'Just now';
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing date: $e');
        }
        acceptedTime = 'Recently';
      }
    }

    // Get recipient information with enhanced null safety
    final recipientInfo = donation['recipientInfo'] ?? {};
    final recipientName = recipientInfo['recipientName'] ??
        donation['recipientName'] ??
        'Unknown Recipient';
    final recipientContact =
        recipientInfo['recipientContact'] ?? 'Contact not available';
    final recipientAddress =
        recipientInfo['recipientAddress'] ?? 'Address not available';

    // Food type icon and color with null safety
    IconData foodTypeIcon = Icons.restaurant;
    Color foodTypeColor = Colors.grey.shade700;

    final foodType = donation['foodType']?.toString().toLowerCase() ?? '';
    if (foodType == 'veg') {
      foodTypeIcon = Icons.eco;
      foodTypeColor = Colors.green;
    } else if (foodType == 'nonveg') {
      foodTypeIcon = FontAwesomeIcons.drumstickBite;
      foodTypeColor = Colors.red;
    } else if (foodType == 'jain') {
      foodTypeIcon = Icons.spa;
      foodTypeColor = Colors.green.shade800;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Icon(foodTypeIcon, color: foodTypeColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donation['foodName'] ?? 'Food Donation',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Accepted $acceptedTime',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${donation['quantity'] ?? 0} servings',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Donor Information
                _buildSectionTitle('From Donor'),
                _buildInfoRow(
                  Icons.person,
                  'Donor Name',
                  donation['donorName'] ?? 'Unknown Donor',
                ),

                const SizedBox(height: 16),

                // Recipient Information
                _buildSectionTitle('To Recipient'),
                _buildInfoRow(
                  Icons.person_outline,
                  'Recipient',
                  recipientName,
                ),
                _buildInfoRow(
                  Icons.phone,
                  'Contact',
                  recipientContact,
                ),
                _buildInfoRow(
                  Icons.location_on,
                  'Address',
                  recipientAddress,
                ),

                const SizedBox(height: 16),

                // Food Information
                _buildSectionTitle('Food Details'),
                Text(
                  donation['description'] ?? 'No description provided',
                  style: TextStyle(color: Colors.grey.shade800),
                ),

                const SizedBox(height: 24),

                // Accept Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: donation['_id'] != null
                        ? () => _acceptDeliveryOpportunity(donation['_id'])
                        : null,
                    icon: const Icon(Icons.delivery_dining),
                    label: const Text('ACCEPT DELIVERY REQUEST'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade800,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
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
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
