import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'donation_detail_screen.dart';

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

      print('Fetching live donations...');
      final donations = await _apiService.getLiveDonations();
      print('Fetched ${donations.length} donations');

      setState(() {
        _donations = donations;
        _applyFilters(); // Apply filters to the fetched donations
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching donations: $e');
      String errorMsg = e.toString().replaceAll('Exception: ', '');

      // Provide more user-friendly error messages
      if (errorMsg.contains('User not found in database')) {
        errorMsg =
            'Your profile was not found. Please ensure you are registered as a recipient to view donations.';
      } else if (errorMsg.contains('Failed to get live donations')) {
        errorMsg =
            'Unable to load donations at this time. Please try again later.';
      } else if (errorMsg.contains('No authenticated user found')) {
        errorMsg = 'Please sign in to view donations.';
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

  Future<void> _acceptDonation(String donationId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('Accepting donation $donationId');
      final acceptedDonation = await _apiService.acceptDonation(
        donationId: donationId,
        needsVolunteer: _showNeedsVolunteer,
      );
      print('Donation accepted with ID: ${acceptedDonation['_id']}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation accepted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );

        // Wait for the snackbar to show briefly before redirecting
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            // Show a dialog confirming the donation was accepted
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Donation Accepted!'),
                content: const Text(
                  'The donation has been accepted successfully. You can view it in your donation history.',
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog

                      // Navigate back to dashboard and use a notification
                      // to tell the parent screen to switch to history tab
                      if (widget.onDonationAccepted != null) {
                        widget.onDonationAccepted!();
                      }
                    },
                    child: const Text('View History'),
                  ),
                ],
              ),
            );
          }
        });
      }

      // Refresh the donations list
      await _fetchDonations();
    } catch (e) {
      print('Error accepting donation: $e');

      String errorMessage = e.toString().replaceAll('Exception: ', '');
      String displayMessage = errorMessage;

      // Provide user-friendly error messages for common errors
      if (errorMessage
          .contains('Only registered recipients can accept donations')) {
        displayMessage =
            'You need to be registered as a recipient to accept donations. Please complete your recipient profile.';
      } else if (errorMessage.contains('No authenticated user found')) {
        displayMessage = 'You need to sign in to accept donations.';
      } else if (errorMessage.contains('Donation not found')) {
        displayMessage =
            'This donation is no longer available. It may have been accepted by someone else.';
      } else if (errorMessage.contains('This donation has expired')) {
        displayMessage =
            'This donation has expired and is no longer available.';
      } else if (errorMessage.contains('User not found in database')) {
        displayMessage =
            'Your recipient profile was not found. Please ensure you have completed registration as a recipient.';
      } else if (errorMessage.contains('User is not a recipient')) {
        displayMessage =
            'Only recipients can accept donations. Please register as a recipient to accept donations.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $displayMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Donations'),
        centerTitle: true,
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Filter button removed from here
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
                      'Filter Donations',
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
                  'Food Type',
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
                            type.toUpperCase(),
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
                  'Sort By',
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
                      String displayName = option == 'expiry'
                          ? 'Expiry Date'
                          : option == 'distance'
                              ? 'Distance'
                              : 'Quantity';
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            displayName,
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
                      'Maximum Distance: ${_maxDistance.toStringAsFixed(1)} km',
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
                    const Text('Show donations needing volunteer assistance'),
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
                      child: const Text('Reset'),
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
                      child: const Text('Apply Filters'),
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
                'Error: $_errorMessage',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchDonations,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            if (_errorMessage.contains('profile was not found')) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
                icon: const Icon(Icons.person),
                label: const Text('Go to Profile'),
                style: TextButton.styleFrom(
                  foregroundColor: _primaryGreen,
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (_filteredDonations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fastfood_outlined,
              size: 70,
              color: _primaryGreen.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No available donations found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _donations.isEmpty
                  ? 'Check back later for new donations'
                  : 'Try changing your filters to see more donations',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchDonations,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // New filter button row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Donations (${_filteredDonations.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _primaryGreen,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showFilterBottomSheet,
                icon: const Icon(Icons.filter_list, size: 18),
                label: const Text('Filter'),
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

        // Active filter indicators
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
                        label: Text('${_selectedFoodType.toUpperCase()}'),
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
                      label: const Text('Needs Volunteer'),
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

        // Donation list
        Expanded(
          child: RefreshIndicator(
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

  Widget _buildDonationCard(Map<String, dynamic> donation) {
    final String foodName = donation['foodName'] ?? 'Unknown';
    final String description = donation['description'] ?? 'No description';
    final String foodType = donation['foodType'] ?? 'Unknown';
    final String address =
        donation['location']?['address'] ?? 'Unknown location';
    final String donorName = donation['donorName'] ?? 'Anonymous';
    final bool needsVolunteer = donation['needsVolunteer'] == true;

    // Format expiry date
    final DateTime expiryDateTime = donation['expiryDateTime'] != null
        ? DateTime.parse(donation['expiryDateTime'])
        : DateTime.now();
    final String expiryDate =
        '${expiryDateTime.day}/${expiryDateTime.month}/${expiryDateTime.year} at ${expiryDateTime.hour}:${expiryDateTime.minute.toString().padLeft(2, '0')}';

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

    print('DEBUG: Donation image URL: $imageUrl');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
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
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        print(
                            'Image URL attempted: ${ApiConfig.getImageUrl(imageUrl)}');
                        return Container(
                          height: 200,
                          width: double.infinity,
                          color: _lightGreen,
                          child: Icon(
                            Icons.fastfood,
                            size: 50,
                            color: _primaryGreen,
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
                    ),
                    child: Icon(
                      Icons.restaurant,
                      size: 60,
                      color: _primaryGreen,
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
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.volunteer_activism,
                              color: Colors.orange[800], size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Needs Volunteer',
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
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer, color: Colors.red[800], size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Expiring Soon',
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
                      Expanded(
                        child: Text(
                          foodName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: foodTypeBgColor,
                          borderRadius: BorderRadius.circular(15),
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
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.restaurant, color: _primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Quantity: ${donation['quantity'] ?? 'Unknown'} servings',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Donation details
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Donated by: $donorName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: _primaryGreen, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
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
                          'Expires: $expiryDate',
                          style: TextStyle(
                            fontSize: 13,
                            color: isExpiringSoon ? Colors.red : null,
                            fontWeight: isExpiringSoon ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _acceptDonation(donation['_id']),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Accept'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryGreen,
                          side: BorderSide(color: _primaryGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
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
                        label: const Text('View Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
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
      ),
    );
  }
}
