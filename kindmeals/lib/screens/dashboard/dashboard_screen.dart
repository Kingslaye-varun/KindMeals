// ignore_for_file: deprecated_member_use, duplicate_ignore, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:kindmeals/screens/dashboard/post_donation_screen.dart';
import 'package:kindmeals/screens/dashboard/recipient_history_screen.dart';
import 'package:kindmeals/screens/leaderboard/donorleaderboard.dart';
import 'package:kindmeals/screens/leaderboard/volunteerleaderboard.dart';
import 'package:kindmeals/screens/profile/donor_history_screen.dart';
import 'package:kindmeals/screens/profile/profile_screen.dart';
// import 'package:kindmeals/screens/volunteer/volunteerdashboard.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/firebase_service.dart';
import '../../services/api_service.dart';
import '../../utils/app_localizations.dart';
import 'view_donations_screen.dart';
import 'volunteers_screen.dart';
import '../notifications/notification_screen.dart';
import '../charity/charity_donation_screen.dart';
import 'package:flutter/foundation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _firebaseService = FirebaseService();
  final _apiService = ApiService();
  int _selectedIndex = 0;
  bool _isInitialized = false;
  String _userType = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final directProfile = await _apiService.getDirectUserProfile();

      setState(() {
        _isInitialized = true;
        _userType = directProfile['userType'] ?? '';
      });

      if (kDebugMode) {
        print('User type detected: $_userType');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user profile: $e');
      }
      setState(() {
        _isInitialized = true;
      });
    }
  }

  List<Widget> _getScreensForUserType() {
    if (_userType.toLowerCase() == 'recipient') {
      // Screens for recipient users
      return [
        const _HomeScreen(),
        const RecipientHistoryScreen(), // Show history screen instead of post donation
        ViewDonationsScreen(onDonationAccepted: () {
          // Switch to history tab for recipients when donation is accepted
          setState(() {
            _selectedIndex = 1; // History tab
          });
        }),
        const VolunteersScreen(),
        const ProfileScreen(),
      ];
    } else {
      // Default screens (for donors)
      return [
        const _HomeScreen(),
        const DonorHistoryScreen(),
        const PostDonationScreen(),
        const VolunteersScreen(),
        const ProfileScreen(),
      ];
    }
  }

  List<BottomNavigationBarItem> _getNavigationItemsForUserType() {
    if (_userType.toLowerCase() == 'recipient') {
      // Nav items for recipient users
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_rounded),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.visibility_rounded),
          label: 'View Donations',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.volunteer_activism_rounded),
          label: 'Volunteers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ];
    } else {
      // Default nav items (for donors)
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_rounded),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_rounded),
          label: 'Post Donation',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.volunteer_activism_rounded),
          label: 'Volunteers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Get screens and nav items based on user type
    final screens = _getScreensForUserType();
    final navItems = _getNavigationItemsForUserType();

    return WillPopScope(
      onWillPop: () async {
        final shouldLogout = await showDialog<bool>(
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

        if (shouldLogout == true) {
          await _firebaseService.signOut();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        }
        return false;
      },
      child: Scaffold(
        body: screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          elevation: 15,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: navItems,
        ),
      ),
    );
  }
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  int _currentCarouselIndex = 0;
  bool _isLoadingLeaderboards = false;
  final _apiService = ApiService();

  // These will be populated with real data from API
  List<Map<String, dynamic>> _volunteerLeaderboard = [];
  List<Map<String, dynamic>> _donorLeaderboard = [];

  final List<Map<String, dynamic>> _carouselItems = [
    {
      'image': 'assets/images/food1.jpg',
      'title': 'Share Food, Share Love',
      'subtitle': 'Help us fight hunger in your community',
      'color': Colors.green,
    },
    {
      'image': 'assets/images/food2.jpg',
      'title': 'Join 1000+ Donors',
      'subtitle': 'Make a difference today',
      'color': Colors.blue,
    },
    {
      'image': 'assets/images/food3.jpg',
      'title': 'Fresh Food Donations',
      'subtitle': 'Reducing waste, feeding people',
      'color': Colors.orange,
    },
    {
      'image': 'assets/images/food4.jpg',
      'title': 'Become a Volunteer',
      'subtitle': 'Your time can change lives',
      'color': Colors.purple,
    },
  ];

  // Charity donation options
  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'Rohit',
      'rating': 5,
      'comment':
          'This app made donating leftover food from our Vadapav stall so easy! The volunteers picked up everything within 30 minutes.',
      'date': '2 days ago',
      'avatar': 'assets/images/user1.jpg',
    },
    {
      'name': 'Dhoni',
      'rating': 5,
      'comment':
          'As a recipient, I am so grateful for this platform. The food donations have helped my CSK family during tough times.',
      'date': '1 week ago',
      'avatar': 'assets/images/user2.jpg',
    },
    {
      'name': 'Kohli',
      'rating': 4,
      'comment':
          'Great initiative! I deliver Ram ji ke Chole Kulche weekly and the app makes coordination seamless.',
      'date': '2 weeks ago',
      'avatar': 'assets/images/user3.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchLeaderboardData();
  }

  Future<void> _fetchLeaderboardData() async {
    if (mounted) {
      setState(() {
        _isLoadingLeaderboards = true;
        // Clear existing data before fetching to avoid stale data
        _volunteerLeaderboard = [];
        _donorLeaderboard = [];
      });
    }

    try {
      if (kDebugMode) {
        print('=== FETCHING FRESH LEADERBOARD DATA ===');
      }

      // Fetch top volunteers with increased debug info
      final volunteers = await _apiService.getTopVolunteers(limit: 5);
      if (kDebugMode) {
        print('Volunteer data returned from API:');
        for (var volunteer in volunteers) {
          print('${volunteer['name']}: ${volunteer['donations']} deliveries');
        }
      }

      if (volunteers.isNotEmpty && mounted) {
        setState(() {
          _volunteerLeaderboard = volunteers;
        });

        if (kDebugMode) {
          print(
              'Updated volunteer leaderboard with ${volunteers.length} entries');
        }
      } else {
        if (kDebugMode) {
          print('No volunteer data returned from API');
        }
      }

      // Fetch top donors with debugging
      final donors = await _apiService.getTopDonors(limit: 5);
      if (kDebugMode) {
        print('==== DEBUG: FETCHED TOP DONORS DATA ====');
        print('Donors data length: ${donors.length}');
        for (var donor in donors) {
          print('Donor data: $donor');
        }
      }

      if (donors.isNotEmpty && mounted) {
        setState(() {
          _donorLeaderboard = donors;
        });

        if (kDebugMode) {
          print('Transformed donor leaderboard:');
          for (var donor in _donorLeaderboard) {
            print('${donor['name']}: ${donor['meals']} meals');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching leaderboard data: $e');
      }
      // If API fails, we'll use default data
    } finally {
      // If no data was fetched, use some default placeholder data
      if (_volunteerLeaderboard.isEmpty && mounted) {
        setState(() {
          _volunteerLeaderboard = [
            {
              'name': 'Sarah Johnson',
              'donations': 32,
              'avatar': 'assets/images/volunteer1.jpg',
            },
            {
              'name': 'Michael Chen',
              'donations': 28,
              'avatar': 'assets/images/volunteer2.jpg',
            },
            {
              'name': 'Priya Patel',
              'donations': 25,
              'avatar': 'assets/images/volunteer3.jpg',
            },
          ];
        });
      }

      if (_donorLeaderboard.isEmpty && mounted) {
        setState(() {
          _donorLeaderboard = [
            {
              'name': 'Green Bistro',
              'meals': 210,
              'avatar': 'assets/images/restaurant1.jpg',
            },
            {
              'name': 'Fresh Harvest',
              'meals': 185,
              'avatar': 'assets/images/restaurant2.jpg',
            },
            {
              'name': 'Spice Garden',
              'meals': 150,
              'avatar': 'assets/images/restaurant3.jpg',
            },
          ];
        });
      }

      if (mounted) {
        setState(() {
          _isLoadingLeaderboards = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _fetchLeaderboardData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header with Gradient
                _buildWelcomeHeader(),

                // Featured Carousel
                _buildCarousel(),

                // Volunteer Leaderboard Section
                _buildVolunteerLeaderboard(),

                // Donor Leaderboard Section
                _buildDonorLeaderboard(),

                // Charity Donation Section (moved above reviews)
                _buildCharitySection(),

                // Reviews Section (moved below charity)
                _buildReviews(),

                // Footer with Social Links
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade800,
            Colors.green.shade600,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('welcome_to'),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        localizations.translate('app_name'),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        const SizedBox(height: 20),
        CarouselSlider.builder(
          itemCount: _carouselItems.length,
          itemBuilder: (context, index, realIndex) {
            final item = _carouselItems[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Stack(
                  children: [
                    Image.asset(
                      item['image'],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['subtitle'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
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
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height * 0.35,
            viewportFraction: 0.9,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 15),
        AnimatedSmoothIndicator(
          activeIndex: _currentCarouselIndex,
          count: _carouselItems.length,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: Colors.green.shade600,
            dotColor: Colors.grey.shade300,
            spacing: 5,
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildVolunteerLeaderboard() {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.translate('top_volunteers'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              Row(
                children: [
                  // Add refresh button
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                    onPressed: () {
                      if (kDebugMode) {
                        print('Manual refresh of volunteer leaderboard');
                      }
                      _fetchLeaderboardData();
                    },
                    tooltip: 'Refresh leaderboard',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          _isLoadingLeaderboards
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.green.shade600,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _volunteerLeaderboard.isEmpty
                      ? _buildEmptyLeaderboardState(localizations.translate('no_volunteers_found'), true)
                      : Column(
                          children: [
                            // Header row
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.green.shade200,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 40),
                                  Expanded(
                                    child: Text(
                                      localizations.translate('name'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    localizations.translate('deliveries'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Top 3 volunteers with medals
                            ...List.generate(
                                _volunteerLeaderboard.length > 3
                                    ? 3
                                    : _volunteerLeaderboard.length, (index) {
                              final volunteer = _volunteerLeaderboard[index];
                              // Safety check for name
                              final name = volunteer['name'] ?? 'Volunteer';
                              if (name == 'Volunteer' && kDebugMode) {
                                if (kDebugMode) {
                                  print(
                                      'Warning: Missing volunteer name at index $index: $volunteer');
                                }
                              }
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _getMedalColor(index),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: SizedBox(
                                        width: 36,
                                        height: 36,
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundImage: _getImageProvider(
                                              volunteer['avatar']),
                                          onBackgroundImageError: (_, __) {},
                                          backgroundColor: Colors.grey.shade300,
                                          child: volunteer['avatar']
                                                      .toString()
                                                      .isEmpty ||
                                                  (!(volunteer['avatar']
                                                              .toString()
                                                              .startsWith(
                                                                  'http') ||
                                                          volunteer['avatar']
                                                              .toString()
                                                              .startsWith(
                                                                  'https')) &&
                                                      !volunteer['avatar']
                                                          .toString()
                                                          .startsWith(
                                                              'assets/') &&
                                                      !volunteer['avatar']
                                                          .toString()
                                                          .startsWith(
                                                              '/uploads'))
                                              ? const Icon(Icons.person,
                                                  color: Colors.white)
                                              : null,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      volunteer['donations'].toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                ),
          const SizedBox(height: 16),
          // "View All" button at bottom in a rounded box
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VolunteerLeaderboardScreen(
                      volunteers: _volunteerLeaderboard,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade50,
                foregroundColor: Colors.green.shade700,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: Colors.green.shade300),
                ),
              ),
              child: Text(
                localizations.translate('view_full_leaderboard'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLeaderboardState(String message, bool isVolunteer) {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.shade50,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isVolunteer ? Icons.volunteer_activism : Icons.store,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              _fetchLeaderboardData();
            },
            icon: const Icon(Icons.refresh),
            label: Text(localizations.translate('refresh_data')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorLeaderboard() {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.translate('top_donors'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              Row(
                children: [
                  // Add refresh button
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                    onPressed: () {
                      if (kDebugMode) {
                        print('Manual refresh of donor leaderboard');
                      }
                      _fetchLeaderboardData();
                    },
                    tooltip: 'Refresh leaderboard',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          _isLoadingLeaderboards
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.green.shade600,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                    boxShadow: [
                      BoxShadow(
                        // ignore: duplicate_ignore
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _donorLeaderboard.isEmpty
                      ? _buildEmptyLeaderboardState(localizations.translate('no_donors_found'), false)
                      : Column(
                          children: [
                            // Header row
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.green.shade200,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 40),
                                  Expanded(
                                    child: Text(
                                      localizations.translate('name'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    localizations.translate('meals'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Top 3 donors with medals
                            ...List.generate(
                                _donorLeaderboard.length > 3
                                    ? 3
                                    : _donorLeaderboard.length, (index) {
                              final donor = _donorLeaderboard[index];
                              // Safety check for name
                              final name = donor['name'] ??
                                  donor['donorname'] ??
                                  donor['orgName'] ??
                                  'Donor';
                              if ((name == 'Donor' || name.isEmpty) &&
                                  kDebugMode) {
                                if (kDebugMode) {
                                  print(
                                      'Warning: Missing donor name at index $index: $donor');
                                }
                              }
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _getMedalColor(index),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: SizedBox(
                                        width: 36,
                                        height: 36,
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundImage: _getImageProvider(
                                              donor['avatar']),
                                          onBackgroundImageError: (_, __) {},
                                          backgroundColor: Colors.grey.shade300,
                                          child: donor['avatar']
                                                      .toString()
                                                      .isEmpty ||
                                                  (!(donor['avatar']
                                                              .toString()
                                                              .startsWith(
                                                                  'http') ||
                                                          donor['avatar']
                                                              .toString()
                                                              .startsWith(
                                                                  'https')) &&
                                                      !donor['avatar']
                                                          .toString()
                                                          .startsWith(
                                                              'assets/') &&
                                                      !donor['avatar']
                                                          .toString()
                                                          .startsWith(
                                                              '/uploads'))
                                              ? const Icon(Icons.storefront,
                                                  color: Colors.white)
                                              : null,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      donor['meals'].toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                ),
          const SizedBox(height: 16),
          // "View All" button at bottom in a rounded box
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DonorLeaderboardScreen(
                      donors: _donorLeaderboard,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade50,
                foregroundColor: Colors.green.shade700,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: Colors.green.shade300),
                ),
              ),
              child: Text(
                localizations.translate('view_full_leaderboard'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
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
        return Colors.blue;
    }
  }

  Widget _buildReviews() {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.translate('reviews_feedback'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _reviews.length,
            itemBuilder: (context, index) {
              final review = _reviews[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: Image.asset(
                              review['avatar'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                review['date'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(
                            review['rating'],
                            (i) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      review['comment'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // "View All" button at bottom in a rounded box
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to all reviews
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade50,
                foregroundColor: Colors.green.shade700,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: Colors.green.shade300),
                ),
              ),
              child: Text(
                localizations.translate('view_all_reviews'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharitySection() {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.translate('support_a_cause'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: 200,
                width: constraints.maxWidth,
                padding: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/charity_bg.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Color.fromRGBO(0, 0, 0, 0.3),
                      BlendMode.darken,
                    ),
                  ),
                  border: Border.all(
                    color: Colors.green.shade200,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.volunteer_activism,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        localizations.translate('donate_to_kindmeals'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Color.fromARGB(150, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.translate('donate_subtitle'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Color.fromARGB(150, 0, 0, 0),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CharityDonationScreen(
                                  charity: {
                                    'id': 'kindmeals-main',
                                    'name': 'KindMeals',
                                    'description':
                                        'Support our mission to reduce food waste and hunger through the KindMeals platform.',
                                    'recommendedAmounts': [
                                      100,
                                      500,
                                      1000,
                                      5000
                                    ],
                                    'imageUrl': 'assets/images/charity_bg.jpg',
                                  },
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green.shade700,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(color: Colors.green.shade300),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            localizations.translate('donate_now'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/charities');
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green.shade50,
                foregroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: Colors.green.shade200),
                ),
              ),
              child: Text(
                localizations.translate('view_all_charities'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildFooter() {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      color: Colors.green.shade800,
      child: Column(
        children: [
          Text(
            localizations.translate('app_name'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            localizations.translate('app_slogan'),
            style: TextStyle(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(Icons.facebook),
              _buildSocialIcon(FontAwesomeIcons.whatsapp),
              _buildSocialIcon(Icons.telegram),
              _buildSocialIcon(Icons.email_rounded),
              _buildSocialIcon(Icons.language_rounded),
            ],
          ),
          const SizedBox(height: 25),
          const Divider(color: Colors.white24),
          const SizedBox(height: 15),
          Text(
            '${localizations.translate('privacy_policy')} | ${localizations.translate('terms_of_service')} | ${localizations.translate('contact_us')}',
            style: TextStyle(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            localizations.translate('all_rights_reserved'),
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get the appropriate image provider based on the URL
  ImageProvider _getImageProvider(dynamic imageUrl) {
    if (imageUrl == null || imageUrl.toString().isEmpty) {
      return const AssetImage('assets/images/volunteer1.jpg');
    }

    final url = imageUrl.toString();

    if (url.startsWith('http') || url.startsWith('https')) {
      // Network image
      return NetworkImage(url);
    } else if (url.startsWith('/uploads')) {
      // API server image (needs full URL)
      return NetworkImage('${ApiService.baseUrl}$url');
    } else if (url.startsWith('assets/')) {
      // Asset image
      return AssetImage(url);
    } else {
      // Default fallback
      return const AssetImage('assets/images/volunteer1.jpg');
    }
  }
}
