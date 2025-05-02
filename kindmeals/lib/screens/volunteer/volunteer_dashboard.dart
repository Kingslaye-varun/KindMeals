// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../services/firebase_service.dart';
import '../../utils/date_time_helper.dart';
import 'volunteerhistory.dart';
import 'volunteerprofile.dart';

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
          if (kDebugMode) {
            print(
              'Filtered out ${opportunities.length - validOpportunities.length} invalid opportunities');
          }
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

      // Reload all data including profile and opportunities
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error accepting delivery: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept delivery: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _firebaseService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    }
  }

  // Launch Maps with directions between origin and destination (updated to use coordinates when available)
  Future<void> launchGoogleMapsDirections({
    required String origin,
    required String destination,
    Map<String, dynamic>? coordinates,
  }) async {
    try {
      // Check if we have valid coordinates from the API
      final hasValidCoordinates = coordinates != null &&
          coordinates['donor'] != null &&
          coordinates['recipient'] != null &&
          coordinates['donor']['latitude'] != null &&
          coordinates['donor']['longitude'] != null &&
          coordinates['recipient']['latitude'] != null &&
          coordinates['recipient']['longitude'] != null;

      if (kDebugMode) {
        print('Using coordinates for directions: $hasValidCoordinates');
        if (hasValidCoordinates) {
          print(
              'Donor coordinates: ${coordinates['donor']['latitude']}, ${coordinates['donor']['longitude']}');
          print(
              'Recipient coordinates: ${coordinates['recipient']['latitude']}, ${coordinates['recipient']['longitude']}');
        }
      }

      // Handle case where origin and destination are the same
      if (origin == destination && !hasValidCoordinates) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Origin and destination addresses are the same. Please contact the donor or recipient for more details.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Try multiple approaches for launching maps
      bool launched = false;

      if (Platform.isAndroid) {
        // Try Android-specific intent with coordinates if available
        if (hasValidCoordinates) {
          try {
            final donorLat = coordinates['donor']['latitude'];
            final donorLng = coordinates['donor']['longitude'];
            final recipientLat = coordinates['recipient']['latitude'];
            final recipientLng = coordinates['recipient']['longitude'];

            final String url =
                'https://www.google.com/maps/dir/?api=1&origin=$donorLat,$donorLng&destination=$recipientLat,$recipientLng&travelmode=driving';
            final Uri uri = Uri.parse(url);

            if (kDebugMode) {
              print('Trying Google Maps with coordinates: $url');
            }

            if (await canLaunchUrl(uri)) {
              launched = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error with coordinates Google Maps URI: $e');
            }
            // If coordinates fail, we'll fall back to addresses below
          }
        }

        // If coordinates failed or weren't available, try with addresses
        if (!launched) {
          // Try Android-specific intent first with geo: scheme
          try {
            final String geoString = 'geo:0,0?q=$destination';
            final Uri geoUri = Uri.parse(geoString);

            if (kDebugMode) {
              print('Trying Android geo URI: $geoUri');
            }

            if (await canLaunchUrl(geoUri)) {
              launched = await launchUrl(geoUri);
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error with geo URI: $e');
            }
          }

          // If geo URI failed, try with google maps app
          if (!launched) {
            try {
              final String encodedOrigin = Uri.encodeComponent(origin);
              final String encodedDestination =
                  Uri.encodeComponent(destination);
              final Uri uri = Uri.parse(
                  'https://www.google.com/maps/dir/?api=1&origin=$encodedOrigin&destination=$encodedDestination&travelmode=driving');

              if (kDebugMode) {
                print('Trying Google Maps URI: $uri');
              }

              if (await canLaunchUrl(uri)) {
                launched = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error with Google Maps URI: $e');
              }
            }
          }
        }
      } else if (Platform.isIOS) {
        // iOS approach - try with coordinates first if available
        if (hasValidCoordinates) {
          try {
            final donorLat = coordinates['donor']['latitude'];
            final donorLng = coordinates['donor']['longitude'];
            final recipientLat = coordinates['recipient']['latitude'];
            final recipientLng = coordinates['recipient']['longitude'];

            final String url =
                'https://maps.apple.com/?saddr=$donorLat,$donorLng&daddr=$recipientLat,$recipientLng&dirflg=d';
            final Uri uri = Uri.parse(url);

            if (kDebugMode) {
              print('Trying Apple Maps with coordinates: $url');
            }

            if (await canLaunchUrl(uri)) {
              launched = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error with coordinates Apple Maps URI: $e');
            }
            // Fall back to addresses below
          }
        }

        // If coordinates failed or weren't available, try with addresses
        if (!launched) {
          // iOS approach - try Apple Maps first, then Google Maps
          try {
            final String encodedDestination = Uri.encodeComponent(destination);
            final Uri uri = Uri.parse(
                'https://maps.apple.com/?q=$encodedDestination&dirflg=d');

            if (kDebugMode) {
              print('Trying Apple Maps URI: $uri');
            }

            if (await canLaunchUrl(uri)) {
              launched = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error with Apple Maps URI: $e');
            }
          }

          // If Apple Maps failed, try Google Maps
          if (!launched) {
            try {
              final String encodedDestination =
                  Uri.encodeComponent(destination);
              final Uri uri =
                  Uri.parse('comgooglemaps://?q=$encodedDestination');

              if (kDebugMode) {
                print('Trying Google Maps iOS app URI: $uri');
              }

              if (await canLaunchUrl(uri)) {
                launched = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error with Google Maps iOS app URI: $e');
              }
            }
          }
        }
      }

      // Last resort - try web URL if all else failed
      if (!launched) {
        final String encodedDestination = Uri.encodeComponent(destination);
        final Uri uri = Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$encodedDestination');

        if (kDebugMode) {
          print('Trying web fallback: $uri');
        }

        if (await canLaunchUrl(uri)) {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw Exception('Could not launch maps on this device');
        }
      }

      if (!launched) {
        throw Exception('Could not launch maps on this device');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error launching Maps: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Could not open maps application. Please try using Google Maps manually.'),
            action: SnackBarAction(
              label: 'DISMISS',
              onPressed: () {},
            ),
            backgroundColor: Colors.red,
          ),
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
              '/login',
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
                mainAxisAlignment: MainAxisAlignment.start,
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
    final deliveries = _volunteerProfile['deliveries'] ?? 0;
    final rating = _volunteerProfile['rating'] ?? 0.0;
    final profileImage = _volunteerProfile['profileImage'];

    if (kDebugMode) {
      print('Volunteer profile data: $_volunteerProfile');
      print(
          'Name: $name, Deliveries: $deliveries, Rating: $rating, ProfileImage: $profileImage');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildProfileImage(profileImage),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.local_shipping_rounded,
                          size: 16,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$deliveries Deliveries',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
    );
  }

  Widget _buildProfileImage(dynamic profileImage) {
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
        radius: 30,
        backgroundImage: NetworkImage(imageUrl),
        onBackgroundImageError: (e, stackTrace) {
          if (kDebugMode) {
            print('Error loading profile image: $e');
          }
        },
        backgroundColor: Colors.green.shade100,
      );
    }

    if (kDebugMode) {
      print('Using default profile image icon');
    }

    // Default case: no image or invalid image path
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.green.shade100,
      child: Icon(
        Icons.person,
        size: 30,
        color: Colors.green.shade700,
      ),
    );
  }

  Widget _buildDeliveryRequestCard(Map<String, dynamic> donation) {
    // Get donor information with improved fallbacks
    final donorInfo = donation['donorInfo'] ?? {};
    final donorName = donorInfo['donorname'] ??
        donorInfo['donorName'] ??
        donation['donorName'] ??
        'Unknown Donor';
    final donorContact = donorInfo['donorcontact'] ??
        donorInfo['donorContact'] ??
        donation['donorContact'] ??
        donation['donorcontact'] ??
        'Contact not available';
    final donorAddress = donorInfo['donoraddress'] ??
        donorInfo['donorAddress'] ??
        donation['donorAddress'] ??
        donation['donoraddress'] ??
        donation['location']?['address'] ??
        'Address not available';

    // Get recipient information with improved fallbacks
    final recipientInfo = donation['recipientInfo'] ?? {};
    final recipientName = recipientInfo['recipientName'] ??
        donation['recipientName'] ??
        'Unknown Recipient';
    final recipientContact = recipientInfo['recipientContact'] ??
        donation['recipientContact'] ??
        'Contact not available';
    final recipientAddress = recipientInfo['recipientAddress'] ??
        donation['recipientAddress'] ??
        'Address not available';

    // Other donation details
    final acceptedTime = _getAcceptedTimeString(donation['acceptedAt']);
    final foodName = donation['foodName'] ?? 'Food Donation';
    final quantity = donation['quantity'] ?? 0;
    final description = donation['description'] ?? 'No description provided';
    final expiryDateTime = donation['expiryDateTime'];
    final foodType = donation['foodType']?.toString().toLowerCase() ?? '';

    // Get GPS coordinates for directions if available
    final locationCoordinates = donation['locationCoordinates'];

    // Get food image if available
    String? imageUrl;
    if (donation['imageUrl'] != null &&
        donation['imageUrl'].toString().isNotEmpty) {
      imageUrl = ApiConfig.getImageUrl(donation['imageUrl'].toString());
      if (kDebugMode) {
        print('Food image URL: $imageUrl');
      }
    }

    // Food type icon and color mapping
    final (IconData foodTypeIcon, Color foodTypeColor) =
        _getFoodTypeIcon(foodType);

    // Card state management
    final ValueNotifier<bool> isExpanded = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: isExpanded,
      builder: (context, expanded, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
              // Food Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Food type icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: foodTypeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        foodTypeIcon,
                        color: foodTypeColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Food name and details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: foodTypeColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: foodTypeColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  foodType.isEmpty
                                      ? 'MIXED'
                                      : foodType.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: foodTypeColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.people_alt_outlined,
                                      size: 10,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "$quantity servings",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                acceptedTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Donor & Recipient Information Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Donor information
                    _buildInfoItem(
                      'Donor',
                      donorName,
                      Icons.storefront_outlined,
                      Colors.green.shade700,
                      [
                        _buildInfoDetail(
                          Icons.phone_outlined,
                          donorContact,
                          onTap: donorContact != 'Contact not available'
                              ? () => _launchPhoneCall(donorContact)
                              : null,
                        ),
                        _buildInfoDetail(
                          Icons.location_on_outlined,
                          donorAddress,
                        ),
                      ],
                      phoneNumber: donorContact,
                    ),

                    // Directions Button - Now directly launches Google Maps
                    if (donorAddress != 'Address not available' &&
                        recipientAddress != 'Address not available')
                      ElevatedButton.icon(
                        onPressed: () {
                          // Directly launch Google Maps with coordinates
                          launchGoogleMapsDirections(
                            origin: donorAddress,
                            destination: recipientAddress,
                            coordinates: locationCoordinates,
                          );
                        },
                        icon: const Icon(Icons.directions),
                        label: Text(locationCoordinates != null &&
                                locationCoordinates['donor'] != null &&
                                locationCoordinates['donor']['latitude'] != null
                            ? 'Navigate with GPS Coordinates'
                            : 'Get Directions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          minimumSize: const Size(double.infinity, 36),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Recipient information
                    _buildInfoItem(
                      'Recipient',
                      recipientName,
                      Icons.person,
                      Colors.orange.shade700,
                      [
                        _buildInfoDetail(
                          Icons.phone_outlined,
                          recipientContact,
                          onTap: recipientContact != 'Contact not available'
                              ? () => _launchPhoneCall(recipientContact)
                              : null,
                        ),
                        _buildInfoDetail(
                          Icons.location_on_outlined,
                          recipientAddress,
                        ),
                      ],
                      phoneNumber: recipientContact,
                    ),
                  ],
                ),
              ),

              // Divider
              Divider(height: 1, color: Colors.grey.shade200),

              // View Details button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Expand/Collapse button
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          isExpanded.value = !isExpanded.value;
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: expanded
                              ? Colors.grey.shade100
                              : Colors.blue.shade50,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: expanded
                                  ? Colors.grey.shade300
                                  : Colors.blue.shade200,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              expanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 18,
                              color: expanded
                                  ? Colors.grey.shade700
                                  : Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              expanded ? 'Hide Details' : 'View Details',
                              style: TextStyle(
                                color: expanded
                                    ? Colors.grey.shade700
                                    : Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Expanded section with food details
              if (expanded)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food image if available
                      if (imageUrl != null)
                        Container(
                          height: 180,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180,
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey.shade400,
                                        size: 40,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Image not available',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      // Food description
                      Container(
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
                                  Icons.description_outlined,
                                  size: 18,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Food Description',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                                height: 1.4,
                              ),
                            ),
                            if (expiryDateTime != null) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color: Colors.red.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Expires on: ${_formatDateTime(expiryDateTime)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Accept Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: donation['_id'] != null
                      ? () => _acceptDeliveryOpportunity(donation['_id'])
                      : null,
                  icon: const Icon(Icons.delivery_dining),
                  label: const Text('ACCEPT DELIVERY'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon,
      Color iconColor, List<Widget> details,
      {String? phoneNumber}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: iconColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ...details.map((detail) => Padding(
                          padding: const EdgeInsets.only(
                              left: 18, top: 2, bottom: 2),
                          child: detail,
                        )),
                  ],
                ],
              ),
            ),
            // Add larger call button if phone number is provided
            if (phoneNumber != null && phoneNumber != 'Contact not available')
              Container(
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.call,
                    size: 16,
                    color: Colors.blue.shade600,
                  ),
                  onPressed: () => _launchPhoneCall(phoneNumber),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  iconSize: 16,
                  padding: const EdgeInsets.all(8),
                  splashRadius: 20,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoDetail(
    IconData icon,
    String text, {
    double fontSize = 13,
    VoidCallback? onTap,
  }) {
    // Remove onTap functionality for address entries
    final bool isAddress = icon == Icons.location_on_outlined;
    if (isAddress) {
      onTap = null;
    }

    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: fontSize,
            color: onTap != null ? Colors.blue.shade600 : Colors.grey.shade600,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color:
                    onTap != null ? Colors.blue.shade600 : Colors.grey.shade700,
                decoration: onTap != null ? TextDecoration.underline : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format time since acceptance
  String _getAcceptedTimeString(String? acceptedAt) {
    if (acceptedAt == null) return 'Recently';
    try {
      final acceptedTime = DateTime.parse(acceptedAt);
      final now = DateTime.now();
      final difference = now.difference(acceptedTime);

      if (difference.inDays > 0) {
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
        print('Error parsing date: $e');
      }
      return 'Recently';
    }
  }

  // Helper function to get food type icon and color
  (IconData, Color) _getFoodTypeIcon(String foodType) {
    if (foodType == 'veg') {
      return (Icons.eco, Colors.green.shade600);
    } else if (foodType == 'nonveg') {
      return (FontAwesomeIcons.drumstickBite, Colors.red.shade600);
    } else if (foodType == 'jain') {
      return (Icons.spa, Colors.green.shade800);
    } else {
      return (Icons.restaurant, Colors.grey.shade700);
    }
  }

  // Helper method to format date time in IST
  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Unknown';
    try {
      if (kDebugMode) {
        print('===== FORMATTING DATE IN VOLUNTEER DASHBOARD =====');
        print('Input date string from API: $dateTimeStr');
      }

      // Parse the string to a DateTime object and convert to local time (IST)
      final dateTime = DateTimeHelper.parseToIST(dateTimeStr);

      if (kDebugMode) {
        print('Parsed to IST DateTime: $dateTime');
        print('Formatting using DateTimeHelper.formatDateTime');
      }

      // Format using DateTimeHelper to ensure consistent display
      final formatted = DateTimeHelper.formatDateTime(dateTime);

      if (kDebugMode) {
        print('Final formatted output: $formatted');
        print('===========================================');
      }

      return formatted;
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting date in volunteer dashboard: $e');
      }
      return 'Unknown';
    }
  }

  // Launch phone call intent - fixed to directly open phone app
  void _launchPhoneCall(String phoneNumber) async {
    try {
      // Clean up phone number to ensure it's just digits, plus sign, and dashes
      final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d\+\-]'), '');

      // Create the tel: URI
      final Uri uri = Uri.parse('tel:$cleanedNumber');

      if (kDebugMode) {
        print('Attempting to launch phone app with: $uri');
      }

      // Use launchUrl instead of canLaunch/launch for more reliable behavior
      final bool launched = await launchUrl(uri);

      if (!launched) {
        if (kDebugMode) {
          print('Could not launch phone app with URI: $uri');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Could not open phone app. Please dial $phoneNumber manually.'),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'COPY',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: phoneNumber));
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error launching phone call: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not make call: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'COPY',
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: phoneNumber));
              },
            ),
          ),
        );
      }
    }
  }

  // Open address in maps
}
