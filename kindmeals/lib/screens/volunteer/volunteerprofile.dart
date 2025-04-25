import 'package:flutter/material.dart';
import 'package:kindmeals/screens/volunteer/volunteerhistory.dart';
import '../../services/api_service.dart';
import 'package:flutter/foundation.dart';
import '../../config/api_config.dart';

class VolunteerProfileScreen extends StatefulWidget {
  const VolunteerProfileScreen({super.key});

  @override
  State<VolunteerProfileScreen> createState() => _VolunteerProfileScreenState();
}

class _VolunteerProfileScreenState extends State<VolunteerProfileScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic> _volunteerProfile = {};
  List<Map<String, dynamic>> _achievements = [];
  List<Map<String, dynamic>> _upcomingEvents = [];
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch volunteer profile data from API
      final userProfile = await _apiService.getDirectUserProfile();

      if (kDebugMode) {
        print('Volunteer profile data: ${userProfile.toString()}');
      }

      if (userProfile['profile'] != null) {
        // Set the volunteer profile data
        setState(() {
          _volunteerProfile = {
            'name': userProfile['profile']['volunteerName'] ?? 'Unknown',
            'avatar': userProfile['profile']['profileImage'] ?? '',
            'deliveries': userProfile['profile']['deliveries'] ?? 0,
            'rating': userProfile['profile']['rating'] ?? 0.0,
            'status': _isAvailable ? 'Available' : 'Unavailable',
            'email': userProfile['profile']['email'] ?? '',
            'phone': userProfile['profile']['volunteercontact'] ?? '',
            'address': userProfile['profile']['volunteeraddress'] ?? '',
            'joinDate': _formatJoinDate(userProfile['profile']['createdAt']),
            'volunteerID': userProfile['profile']['_id'] ?? '',
            'bio':
                userProfile['profile']['volunteerabout'] ?? 'No bio available',
            'hasVehicle': userProfile['profile']['hasVehicle'] ?? false,
            'vehicleDetails': userProfile['profile']['vehicleDetails'] ?? {},
            'aadharID': userProfile['profile']['aadharID'] ?? '',
            'volunteerlocation': userProfile['profile']['volunteerlocation'] ??
                {'latitude': 0.0, 'longitude': 0.0},
          };
        });
      } else {
        if (kDebugMode) {
          print('No profile data found in response');
        }

        // Use mock data if API fails or returns no profile
        _setMockProfile();
      }

      // Keep mock data for achievements and events
      _setMockAchievementsAndEvents();

      setState(() {
        _isLoading = false;
        _isAvailable = _volunteerProfile['status'] == 'Available';
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading volunteer profile: $e');
      }

      // Use mock data if API fails
      _setMockProfile();
      _setMockAchievementsAndEvents();

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatJoinDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';

    try {
      final date = DateTime.parse(dateStr);

      // Format as Month Day, Year
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];

      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing date: $e');
      }
      return 'Unknown';
    }
  }

  void _setMockProfile() {
    setState(() {
      _volunteerProfile = {
        'name': 'John Smith',
        'avatar': 'assets/images/volunteer1.jpg',
        'deliveries': 27,
        'rating': 4.8,
        'status': 'Available',
        'email': 'john.smith@example.com',
        'phone': '+1 (555) 123-4567',
        'address': '123 Volunteer Street, Cityville, State 12345',
        'joinDate': 'March 15, 2024',
        'volunteerID': 'VOL-12345',
        'bio':
            'Passionate about reducing food waste and helping those in need. I have been volunteering with food rescue organizations for over 2 years.',
        'impactStats': {
          'mealsDelivered': 342,
          'carbonSaved': '120kg',
          'communitiesServed': 8,
          'totalHours': 64,
        },
        'preferences': {
          'maxDistance': '15km',
          'availableDays': ['Monday', 'Wednesday', 'Friday', 'Saturday'],
          'availableHours': '9:00 AM - 6:00 PM',
          'notificationsEnabled': true,
          'vehicleType': 'Car',
        },
      };
    });
  }

  void _setMockAchievementsAndEvents() {
    setState(() {
      _achievements = [
        {
          'id': '1',
          'title': 'First Delivery',
          'description': 'Completed your first food rescue mission',
          'icon': Icons.local_shipping,
          'date': 'Apr 2, 2024',
          'unlocked': true,
        },
        {
          'id': '2',
          'title': 'Regular Volunteer',
          'description': 'Completed 10 deliveries',
          'icon': Icons.repeat,
          'date': 'Apr 15, 2024',
          'unlocked': true,
        },
        {
          'id': '3',
          'title': 'Food Waste Hero',
          'description': 'Saved 100 meals from being wasted',
          'icon': Icons.eco,
          'date': 'May 3, 2024',
          'unlocked': true,
        },
        {
          'id': '4',
          'title': 'Community Champion',
          'description': 'Delivered to 5 different community organizations',
          'icon': Icons.people,
          'date': 'Apr 28, 2024',
          'unlocked': true,
        },
        {
          'id': '5',
          'title': 'Perfect Rating',
          'description': 'Maintained a 5-star rating for 15 deliveries',
          'icon': Icons.star,
          'date': 'May 10, 2024',
          'unlocked': false,
        },
      ];

      _upcomingEvents = [
        {
          'id': '1',
          'title': 'Volunteer Appreciation Day',
          'description':
              'Join us for a special celebration honoring all our dedicated volunteers',
          'date': 'Apr 20, 2025',
          'time': '3:00 PM - 6:00 PM',
          'location': 'Community Center, 123 Main St',
          'participating': true,
        },
        {
          'id': '2',
          'title': 'Food Rescue Training Workshop',
          'description': 'Learn advanced food handling and safety techniques',
          'date': 'Apr 25, 2025',
          'time': '10:00 AM - 12:00 PM',
          'location': 'Food Rescue HQ, 456 Oak St',
          'participating': false,
        },
        {
          'id': '3',
          'title': 'Community Food Drive',
          'description': 'Help collect and distribute food to local shelters',
          'date': 'May 2, 2025',
          'time': '9:00 AM - 2:00 PM',
          'location': 'City Park, Downtown',
          'participating': false,
        },
      ];
    });
  }

  void _navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  void _navigateToHistory() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const VolunteerHistoryScreen()),
    );
  }

  void _toggleAvailability() {
    setState(() {
      _isAvailable = !_isAvailable;
      _volunteerProfile['status'] = _isAvailable ? 'Available' : 'Unavailable';
    });

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'You are now ${_isAvailable ? 'available' : 'unavailable'} for deliveries'),
        backgroundColor: _isAvailable ? Colors.green : Colors.grey.shade600,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            _navigateToHome();
          } else if (index == 1) {
            _navigateToHistory();
          }
        },
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
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
      ),
    );
  }

  Widget _buildProfileView() {
    return CustomScrollView(
      slivers: [
        _buildAppBar('Volunteer Profile'),
        SliverToBoxAdapter(
          child: _buildProfileHeader(),
        ),
        SliverToBoxAdapter(
          child: _buildAvailabilityToggle(),
        ),
        SliverToBoxAdapter(
          child: _buildImpactStats(),
        ),
        SliverToBoxAdapter(
          child: _buildVolunteerInfo(),
        ),
        SliverToBoxAdapter(
          child: _buildPreferences(),
        ),
        SliverToBoxAdapter(
          child: _buildAchievementsSection(),
        ),
        SliverToBoxAdapter(
          child: _buildUpcomingEventsSection(),
        ),
        SliverToBoxAdapter(
          child: const SizedBox(height: 20),
        ),
      ],
    );
  }

  Widget _buildAppBar(String title) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: Colors.green.shade800,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // Show notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            // Open settings
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade900,
                Colors.green.shade700,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProfileImage(),
          const SizedBox(height: 16),
          Text(
            _volunteerProfile['name'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ID: ${_volunteerProfile['volunteerID'].toString().substring(0, 8)}',
              style: TextStyle(
                color: Colors.green.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatCard(
                '${_volunteerProfile['deliveries']}',
                'Deliveries',
                Icons.delivery_dining,
              ),
              const SizedBox(width: 20),
              _buildStatCard(
                '${_volunteerProfile['rating']}',
                'Rating',
                Icons.star,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _volunteerProfile['bio'],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    final profileImage = _volunteerProfile['avatar'];

    // Handle different profile image scenarios
    if (profileImage != null && profileImage.toString().isNotEmpty) {
      if (kDebugMode) {
        print('Profile image path: $profileImage');
      }

      // Use ApiConfig helper to get correct URL
      String imageUrl = ApiConfig.getImageUrl(profileImage.toString());
      if (kDebugMode) {
        print('Converted profile image URL: $imageUrl');
      }

      return CircleAvatar(
        radius: 60,
        backgroundImage: NetworkImage(imageUrl),
        onBackgroundImageError: (e, stackTrace) {
          if (kDebugMode) {
            print('Error loading profile image: $e');
          }
        },
        backgroundColor: Colors.green.shade100,
      );
    }

    // Default case: no image or invalid image path
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.green.shade100,
      child: Icon(
        Icons.person,
        size: 60,
        color: Colors.green.shade700,
      ),
    );
  }

  Widget _buildAvailabilityToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isAvailable ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isAvailable ? Colors.green.shade200 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isAvailable ? Icons.check_circle : Icons.do_not_disturb_on,
            color: _isAvailable ? Colors.green.shade700 : Colors.grey.shade600,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isAvailable
                      ? 'Available for Deliveries'
                      : 'Not Available for Deliveries',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _isAvailable
                        ? Colors.green.shade700
                        : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isAvailable
                      ? 'You are currently receiving delivery requests'
                      : 'You will not receive new delivery requests',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isAvailable,
            onChanged: (value) => _toggleAvailability(),
            activeColor: Colors.green.shade700,
            activeTrackColor: Colors.green.shade200,
          ),
        ],
      ),
    );
  }

  Widget _buildImpactStats() {
    // Create impact stats from the deliveries count
    final deliveries = _volunteerProfile['deliveries'] ?? 0;

    final impactStats = {
      'mealsDelivered':
          deliveries * 10, // Assuming average 10 meals per delivery
      'carbonSaved':
          '${(deliveries * 2.5).toStringAsFixed(1)}kg', // Rough estimate
      'communitiesServed': (deliveries / 5).ceil(), // Estimate
      'totalHours': deliveries * 2, // Assuming 2 hours per delivery
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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
            // ignore: deprecated_member_use
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.volunteer_activism,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Your Impact',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildImpactStatItem(
                impactStats['mealsDelivered'].toString(),
                'Meals\nDelivered',
                Icons.restaurant,
              ),
              _buildImpactStatItem(
                impactStats['carbonSaved'],
                'Carbon\nSaved',
                Icons.eco,
              ),
              _buildImpactStatItem(
                impactStats['communitiesServed'].toString(),
                'Communities\nServed',
                Icons.people,
              ),
              _buildImpactStatItem(
                impactStats['totalHours'].toString(),
                'Total\nHours',
                Icons.schedule,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpactStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVolunteerInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.person,
                size: 20,
                color: Colors.black87,
              ),
              SizedBox(width: 8),
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email, 'Email', _volunteerProfile['email']),
          _buildInfoRow(Icons.phone, 'Phone', _volunteerProfile['phone']),
          _buildInfoRow(Icons.home, 'Address', _volunteerProfile['address']),
          _buildInfoRow(Icons.calendar_today, 'Member Since',
              _volunteerProfile['joinDate']),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: () {
                // Edit profile functionality
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green.shade700,
                side: BorderSide(color: Colors.green.shade700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              child: const Text('EDIT PROFILE'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferences() {
    // Create preferences based on vehicle details
    final hasVehicle = _volunteerProfile['hasVehicle'] ?? false;
    final vehicleDetails = _volunteerProfile['vehicleDetails'] ?? {};

    final preferences = {
      'maxDistance': '10km', // Default value
      'availableDays': [
        'Monday',
        'Wednesday',
        'Friday',
        'Saturday'
      ], // Default value
      'availableHours': '9:00 AM - 6:00 PM', // Default value
      'notificationsEnabled': true, // Default value
      'vehicleType': hasVehicle
          ? (vehicleDetails['vehicleType'] ?? 'Not specified')
          : 'None',
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.settings,
                size: 20,
                color: Colors.black87,
              ),
              SizedBox(width: 8),
              Text(
                'Delivery Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
              Icons.directions_car, 'Vehicle Type', preferences['vehicleType']),
          _buildInfoRow(
              Icons.place, 'Maximum Distance', preferences['maxDistance']),
          _buildInfoRow(Icons.calendar_view_week, 'Available Days',
              preferences['availableDays'].join(', ')),
          _buildInfoRow(Icons.access_time, 'Available Hours',
              preferences['availableHours']),
          _buildInfoRow(Icons.notifications, 'Notifications',
              preferences['notificationsEnabled'] ? 'Enabled' : 'Disabled'),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: () {
                // Edit preferences functionality
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green.shade700,
                side: BorderSide(color: Colors.green.shade700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              child: const Text('EDIT PREFERENCES'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // View all achievements
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _achievements.length,
              itemBuilder: (context, index) {
                final achievement = _achievements[index];
                return _buildAchievementCard(achievement);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: achievement['unlocked']
              ? Colors.green.shade200
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: achievement['unlocked']
                  ? Colors.green.shade100
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement['icon'],
              color: achievement['unlocked']
                  ? Colors.green.shade700
                  : Colors.grey.shade400,
              size: 32,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              achievement['title'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: achievement['unlocked']
                    ? Colors.black87
                    : Colors.grey.shade500,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              achievement['unlocked'] ? achievement['date'] : 'Locked',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Events',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // View all events
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._upcomingEvents.map((event) => _buildEventCard(event)),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.event,
                color: Colors.green.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${event['date']} • ${event['time']}',
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
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8, left: 44),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.grey.shade600,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  event['location'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: event['participating']
                ? Colors.green.shade100
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            event['participating'] ? 'Participating' : 'Not Participating',
            style: TextStyle(
              color: event['participating']
                  ? Colors.green.shade700
                  : Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  event['description'],
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // View event details
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green.shade700,
                          side: BorderSide(color: Colors.green.shade700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('VIEW DETAILS'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Toggle participation
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: event['participating']
                              ? Colors.red.shade100
                              : Colors.green.shade700,
                          foregroundColor: event['participating']
                              ? Colors.red.shade700
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          event['participating'] ? 'CANCEL' : 'JOIN',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
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
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 2),
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
