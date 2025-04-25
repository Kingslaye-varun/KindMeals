// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'donation_detail_screen.dart';
import '../../utils/date_time_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_localizations.dart';

class ViewDonationsScreen extends StatefulWidget {
  final VoidCallback? onDonationAccepted;

  const ViewDonationsScreen({
    super.key,
    this.onDonationAccepted,
  });

  @override
  State<ViewDonationsScreen> createState() => _ViewDonationsScreenState();
}

class _ViewDonationsScreenState extends State<ViewDonationsScreen> {
  final _apiService = ApiService();
  List<Map<String, dynamic>> _donations = [];
  List<Map<String, dynamic>> _filteredDonations = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Filter states
  String _selectedFoodType = 'all';
  String _selectedSortBy = 'expiry';
  double _maxDistance = 10.0; // Default distance in km
  bool _showNeedsVolunteer = false;
  String _searchQuery = ''; // Search query for food name

  final List<String> _foodTypes = ['all', 'veg', 'nonveg', 'jain'];
  final List<String> _sortOptions = ['expiry', 'distance', 'quantity'];

  final Color _primaryGreen = const Color(0xFF4CAF50);
  final Color _lightGreen = const Color(0xFFE8F5E9);
  final Color _mediumGreen = const Color(0xFFA5D6A7);

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  Future<void> _fetchDonations() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      if (kDebugMode) {
        print('Fetching live donations...');
      }
      final donations = await _apiService.getLiveDonations();
      if (kDebugMode) {
        print('Fetched ${donations.length} donations');
      }

      setState(() {
        _donations = donations;
        _applyFilters(); // Apply filters to the fetched donations
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching donations: $e');
      }
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      
      final AppLocalizations localizations = AppLocalizations.of(context);

      // Provide more user-friendly error messages
      if (errorMsg.contains('User not found in database')) {
        errorMsg = localizations.translate('profile_not_found_recipient');
      } else if (errorMsg.contains('Failed to get live donations')) {
        errorMsg = localizations.translate('unable_to_load_donations');
      } else if (errorMsg.contains('No authenticated user found')) {
        errorMsg = localizations.translate('sign_in_to_view_donations');
      }

      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filteredList = List.from(_donations);

    // Filter by food type
    if (_selectedFoodType != 'all') {
      filteredList = filteredList
          .where((donation) => donation['foodType'] == _selectedFoodType)
          .toList();
    }

    // Filter by volunteer needs
    if (_showNeedsVolunteer) {
      filteredList = filteredList
          .where((donation) => donation['needsVolunteer'] == true)
          .toList();
    }


    // Apply search query filter
    if (_searchQuery.isNotEmpty) {
      final String query = _searchQuery.toLowerCase();
      filteredList = filteredList.where((donation) {
        final String foodName = (donation['foodName'] ?? '').toLowerCase();
        return foodName.contains(query);
      }).toList();
    }

    // Sort the donations
    switch (_selectedSortBy) {
      case 'expiry':
        filteredList.sort((a, b) {
          final DateTime expiryA = DateTime.parse(
              a['expiryDateTime'] ?? DateTime.now().toIso8601String());
          final DateTime expiryB = DateTime.parse(
              b['expiryDateTime'] ?? DateTime.now().toIso8601String());
          return expiryA.compareTo(expiryB);
        });
        break;
      case 'distance':
        // In a real app, this would calculate actual distance
        // For now, we'll just use a random sort as placeholder
        filteredList.sort((a, b) => (a['_id'] ?? '').compareTo(b['_id'] ?? ''));
        break;
      case 'quantity':
        filteredList
            .sort((a, b) => (b['quantity'] ?? 0).compareTo(a['quantity'] ?? 0));
        break;
    }

    setState(() {
      _filteredDonations = filteredList;
    });
  }

  // Launch phone call intent when the donor contact is clicked
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
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error launching phone call: $e');
      }
    }
  }

  // Launch Google Maps with directions from recipient to donor
  Future<void> _launchMapsDirections(String destinationAddress) async {
    try {
      // Try multiple approaches for launching maps based on platform
      bool launched = false;

      if (Platform.isAndroid) {
        // Try Android-specific intent
        try {
          final String encodedDestination =
              Uri.encodeComponent(destinationAddress);
          final Uri uri = Uri.parse(
              'https://www.google.com/maps/dir/?api=1&destination=$encodedDestination&travelmode=driving');

          if (kDebugMode) {
            print('Trying Google Maps URI for Android: $uri');
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
      } else if (Platform.isIOS) {
        // iOS approach - try Apple Maps first
        try {
          final String encodedDestination =
              Uri.encodeComponent(destinationAddress);
          final Uri uri = Uri.parse(
              'https://maps.apple.com/?daddr=$encodedDestination&dirflg=d');

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
      }

      // Last resort - try web URL if all else failed
      if (!launched) {
        final String encodedDestination =
            Uri.encodeComponent(destinationAddress);
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
    } catch (e) {
      if (kDebugMode) {
        print('Error launching Maps: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.translate('available_donations'),
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDonations,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_lightGreen.withOpacity(0.3), Colors.white],
            stops: const [0.0, 0.3],
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  void _showFilterBottomSheet() {
    final AppLocalizations localizations = AppLocalizations.of(context);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizations.translate('filter_donations'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _primaryGreen,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: _primaryGreen),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Food Type Filter
                Text(
                  localizations.translate('food_type'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _primaryGreen,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _foodTypes.map((type) {
                      bool isSelected = _selectedFoodType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            localizations.translate(type).toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : _primaryGreen,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: _primaryGreen,
                          backgroundColor: _lightGreen,
                          onSelected: (selected) {
                            setStateModal(() {
                              _selectedFoodType = type;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Sort By
                Text(
                  localizations.translate('sort_by'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _primaryGreen,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _sortOptions.map((option) {
                      bool isSelected = _selectedSortBy == option;
                      String displayKey = 'sort_by_$option';
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            localizations.translate(displayKey),
                            style: TextStyle(
                              color: isSelected ? Colors.white : _primaryGreen,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: _primaryGreen,
                          backgroundColor: _lightGreen,
                          onSelected: (selected) {
                            setStateModal(() {
                              _selectedSortBy = option;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Maximum Distance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${localizations.translate('maximum_distance')}: ${_maxDistance.toStringAsFixed(1)} ${localizations.translate('km')}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _primaryGreen,
                      ),
                    ),
                    Text(
                      _maxDistance.toStringAsFixed(1),
                      style: TextStyle(color: _primaryGreen),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _primaryGreen,
                    inactiveTrackColor: _lightGreen,
                    thumbColor: _primaryGreen,
                    overlayColor: _primaryGreen.withOpacity(0.2),
                  ),
                  child: Slider(
                    min: 1.0,
                    max: 30.0,
                    divisions: 29,
                    value: _maxDistance,
                    onChanged: (value) {
                      setStateModal(() {
                        _maxDistance = value;
                      });
                    },
                  ),
                ),

                // Volunteer Needs Filter
                Row(
                  children: [
                    Checkbox(
                      value: _showNeedsVolunteer,
                      activeColor: _primaryGreen,
                      onChanged: (value) {
                        setStateModal(() {
                          _showNeedsVolunteer = value ?? false;
                        });
                      },
                    ),
                    Text(localizations.translate('show_needs_volunteer')),
                  ],
                ),

                const SizedBox(height: 20),

                // Apply and Reset Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        setStateModal(() {
                          _selectedFoodType = 'all';
                          _selectedSortBy = 'expiry';
                          _maxDistance = 10.0;
                          _showNeedsVolunteer = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primaryGreen,
                        side: BorderSide(color: _primaryGreen),
                      ),
                      child: Text(localizations.translate('reset')),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Update state in parent
                        setState(() {
                          _selectedFoodType = _selectedFoodType;
                          _selectedSortBy = _selectedSortBy;
                          _maxDistance = _maxDistance;
                          _showNeedsVolunteer = _showNeedsVolunteer;
                        });
                        // Apply filters
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(localizations.translate('apply_filters')),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    final AppLocalizations localizations = AppLocalizations.of(context);
    
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_primaryGreen),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '${localizations.translate('error')}: $_errorMessage',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchDonations,
              icon: const Icon(Icons.refresh),
              label: Text(localizations.translate('retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            if (_errorMessage.contains(localizations.translate('profile_not_found_recipient'))) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
                icon: const Icon(Icons.person),
                label: Text(localizations.translate('go_to_profile')),
                style: TextButton.styleFrom(
                  foregroundColor: _primaryGreen,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        // Add search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _applyFilters();
              });
            },
            decoration: InputDecoration(
              hintText: localizations.translate('search_food'),
              prefixIcon: Icon(Icons.search, color: _primaryGreen),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: _mediumGreen),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: _mediumGreen),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: _primaryGreen, width: 2.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _applyFilters();
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),

        // Filter button row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${localizations.translate('available_donations')} (${_filteredDonations.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _primaryGreen,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showFilterBottomSheet,
                icon: const Icon(Icons.filter_list, size: 18),
                label: Text(localizations.translate('filter')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),

        // Active filter indicators - only showing food type and volunteer indicators
        if (_selectedFoodType != 'all' || _showNeedsVolunteer)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (_selectedFoodType != 'all')
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(localizations.translate(_selectedFoodType).toUpperCase()),
                        deleteIcon: const Icon(Icons.close, size: 15),
                        onDeleted: () {
                          setState(() {
                            _selectedFoodType = 'all';
                            _applyFilters();
                          });
                        },
                        backgroundColor: _lightGreen,
                        labelStyle: TextStyle(color: _primaryGreen),
                      ),
                    ),
                  if (_showNeedsVolunteer)
                    Chip(
                      label: Text(localizations.translate('needs_volunteer')),
                      deleteIcon: const Icon(Icons.close, size: 15),
                      onDeleted: () {
                        setState(() {
                          _showNeedsVolunteer = false;
                          _applyFilters();
                        });
                      },
                      backgroundColor: _lightGreen,
                      labelStyle: TextStyle(color: _primaryGreen),
                    ),
                ],
              ),
            ),
          ),

        // Donation list or empty state
        Expanded(
          child: _filteredDonations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchDonations,
                  color: _primaryGreen,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredDonations.length,
                    itemBuilder: (context, index) {
                      final donation = _filteredDonations[index];
                      return _buildDonationCard(donation);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final AppLocalizations localizations = AppLocalizations.of(context);
    // Create a text controller to clear the search field


    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fastfood_outlined,
              size: 70,
              color: _primaryGreen.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.translate('no_available_donations'),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? '${localizations.translate('no_results_for')} "$_searchQuery"'
                  : _donations.isEmpty
                      ? localizations.translate('check_back_later')
                      : localizations.translate('try_changing_filters'),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_searchQuery.isNotEmpty ||
                    _selectedFoodType != 'all' ||
                    _showNeedsVolunteer)
                if (_searchQuery.isNotEmpty ||
                    _selectedFoodType != 'all' ||
                    _showNeedsVolunteer)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Clear the search bar text using controller
                        setState(() {
                          _searchQuery = '';
                          _selectedFoodType = 'all';
                          _showNeedsVolunteer = false;
                          _applyFilters();
                        });
                      },
                      icon: const Icon(Icons.clear),
                      label: Text(localizations.translate('clear_filters')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primaryGreen,
                      ),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: _fetchDonations,
                  icon: const Icon(Icons.refresh),
                  label: Text(localizations.translate('refresh')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    
    final String foodName = donation['foodName'] ?? localizations.translate('unknown');
    final String description = donation['description'] ?? localizations.translate('no_description');
    final String foodType = donation['foodType'] ?? localizations.translate('unknown');
    final String address =
        donation['location']?['address'] ?? localizations.translate('unknown_location');
    final String donorName = donation['donorName'] ?? localizations.translate('anonymous');
    final bool needsVolunteer = donation['needsVolunteer'] == true;

    // Format expiry date
    final DateTime expiryDateTime = donation['expiryDateTime'] != null
        ? DateTime.parse(donation['expiryDateTime'])
        : DateTime.now();
    final String expiryDate = DateTimeHelper.formatDateTime(expiryDateTime);

    // Calculate time remaining
    final Duration timeRemaining = expiryDateTime.difference(DateTime.now());
    final bool isExpiringSoon = timeRemaining.inHours < 6;

    // Get food type color
    Color foodTypeColor;
    Color foodTypeBgColor;
    switch (foodType) {
      case 'veg':
        foodTypeColor = Colors.green[800]!;
        foodTypeBgColor = Colors.green[100]!;
        break;
      case 'nonveg':
        foodTypeColor = Colors.red[800]!;
        foodTypeBgColor = Colors.red[100]!;
        break;
      case 'jain':
        foodTypeColor = Colors.teal[800]!;
        foodTypeBgColor = Colors.teal[100]!;
        break;
      default:
        foodTypeColor = Colors.amber[800]!;
        foodTypeBgColor = Colors.amber[100]!;
    }

    // Get image URL if available - check multiple possible field names
    String? imageUrl;
    if (donation.containsKey('imageUrl') && donation['imageUrl'] != null) {
      imageUrl = donation['imageUrl'];
    } else if (donation.containsKey('foodImage') &&
        donation['foodImage'] != null) {
      imageUrl = donation['foodImage'];
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: _mediumGreen, width: 1.5),
      ),
      elevation: 4,
      shadowColor: _mediumGreen.withOpacity(0.5),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DonationDetailScreen(
                donation: donation,
                onDonationAccepted: widget.onDonationAccepted,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Image.network(
                      ApiConfig.getImageUrl(imageUrl),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _lightGreen,
                            gradient: LinearGradient(
                              colors: [
                                _lightGreen,
                                _lightGreen,
                                _mediumGreen.withOpacity(0.3)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                foodType.toLowerCase() == 'veg'
                                    ? Icons.eco
                                    : foodType.toLowerCase() == 'jain'
                                        ? Icons.spa
                                        : Icons.fastfood,
                                size: 60,
                                color: _primaryGreen,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                localizations.translate('no_image_available'),
                                style: TextStyle(
                                  color: _primaryGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 170,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _lightGreen,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      gradient: LinearGradient(
                        colors: [_lightGreen, _mediumGreen.withOpacity(0.3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          foodType.toLowerCase() == 'veg'
                              ? Icons.eco
                              : foodType.toLowerCase() == 'jain'
                                  ? Icons.spa
                                  : Icons.fastfood,
                          size: 60,
                          color: _primaryGreen,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations.translate('no_image_available'),
                          style: TextStyle(
                            color: _primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Badge for volunteer assistance if needed
                if (needsVolunteer)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.volunteer_activism,
                              color: Colors.orange[800], size: 14),
                          const SizedBox(width: 4),
                          Text(
                            localizations.translate('needs_volunteer'),
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Expiring soon badge
                if (isExpiringSoon)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer, color: Colors.red[800], size: 14),
                          const SizedBox(width: 4),
                          Text(
                            localizations.translate('expiring_soon'),
                            style: TextStyle(
                              color: Colors.red[800],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: foodTypeBgColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: foodTypeColor.withOpacity(0.2),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          foodType.toUpperCase(),
                          style: TextStyle(
                            color: foodTypeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          foodName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.restaurant, color: _primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${localizations.translate('quantity')}: ${donation['quantity'] ?? localizations.translate('unknown')} ${localizations.translate('servings')}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      if (description.length > 80) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(localizations.translate('description')),
                            content: SingleChildScrollView(
                              child: Text(
                                description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  height: 1.3,
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(localizations.translate('close')),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${localizations.translate('description')}:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description.length > 80
                              ? '${description.substring(0, 80)}...'
                              : description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (description.length > 80)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              localizations.translate('tap_to_read_more'),
                              style: TextStyle(
                                fontSize: 12,
                                color: _primaryGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                  const SizedBox(height: 16),

                  // Donation details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue[50],
                        child: Icon(Icons.person,
                            color: Colors.blue[700], size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              donorName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              localizations.translate('donor'),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            // Add Contact button if available
                            if (donation['donorContact'] != null &&
                                donation['donorContact'].toString().isNotEmpty)
                              GestureDetector(
                                onTap: () => _launchPhoneCall(
                                    donation['donorContact'].toString()),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.phone,
                                          size: 14, color: Colors.blue[700]),
                                      const SizedBox(width: 4),
                                      Text(
                                        donation['donorContact'].toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[700],
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Phone icon to directly call donor
                      if (donation['donorContact'] != null &&
                          donation['donorContact'].toString().isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.call, color: Colors.blue[700]),
                          onPressed: () => _launchPhoneCall(
                              donation['donorContact'].toString()),
                          tooltip: localizations.translate('call_donor'),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: _primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      // Add navigation icon to open Google Maps
                      IconButton(
                        icon: Icon(Icons.directions, color: Colors.blue[700]),
                        onPressed: () => _launchMapsDirections(address),
                        tooltip: localizations.translate('get_directions'),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          color: isExpiringSoon ? Colors.red : Colors.orange,
                          size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${localizations.translate('expires')}: $expiryDate',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                isExpiringSoon ? Colors.red : Colors.grey[700],
                            fontWeight: isExpiringSoon ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Only View Details button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DonationDetailScreen(
                              donation: donation,
                              onDonationAccepted: widget.onDonationAccepted,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility),
                      label: Text(localizations.translate('view_details').toUpperCase()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
