// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../utils/date_time_helper.dart';
import '../../services/location_service.dart';
import '../../utils/app_localizations.dart';
import 'package:intl/intl.dart';

class RecipientHistoryScreen extends StatefulWidget {
  const RecipientHistoryScreen({super.key});

  @override
  State<RecipientHistoryScreen> createState() => _RecipientHistoryScreenState();
}

class _RecipientHistoryScreenState extends State<RecipientHistoryScreen> {
  final _apiService = ApiService();
  List<Map<String, dynamic>> _acceptedDonations = [];
  List<Map<String, dynamic>> _filteredDonations = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _showDistance = false;
  bool _isGettingLocation = false;
  String _searchQuery = ''; // Search query for food name

  // Filter variables
  String _selectedTimeFilter = 'All';
  String _selectedFoodTypeFilter = 'All';

  // Theme colors
  final Color primaryGreen = Color(0xFF2E7D32); // Dark Green
  final Color secondaryGreen = Color(0xFF4CAF50); // Medium Green
  final Color lightGreen = Color(0xFFAED581); // Light Green
  final Color accentGreen = Color(0xFF8BC34A); // Lime Green
  final Color backgroundColor = Color(0xFFF5F9F5); // Very Light Green

  @override
  void initState() {
    super.initState();
    _fetchAcceptedDonations();
  }

  Future<void> _fetchAcceptedDonations() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print('Fetching recipient donation history...');

      // Use the version with distance information
      final donations = await _apiService.getRecipientDonationsWithDistance();
      print('Fetched ${donations.length} accepted donations');

      setState(() {
        _acceptedDonations = donations;
        _applyFilters(); // Apply any active filters
        _isLoading = false;
        _showDistance = donations.any((donation) =>
            donation.containsKey('distance') && donation['distance'] != null);
      });
    } catch (e) {
      print('Error fetching accepted donations: $e');
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      
      final AppLocalizations localizations = AppLocalizations.of(context);

      // Provide more user-friendly error messages
      if (errorMsg.contains('Not found')) {
        errorMsg = localizations.translate('no_donation_history_found');
      } else if (errorMsg.contains('No authenticated user found')) {
        errorMsg = localizations.translate('sign_in_to_view_donations');
      } else {
        // General error message for any other error
        errorMsg = localizations.translate('unable_to_load_donations');
      }

      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
        // Initialize with empty list to prevent null errors
        _acceptedDonations = [];
      });
    }
  }

  Future<void> _refreshWithLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final AppLocalizations localizations = AppLocalizations.of(context);
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        await _fetchAcceptedDonations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  localizations.translate('location_updated_donations_refreshed')),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  localizations.translate('could_not_get_location')),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location: $e');
      }
      if (mounted) {
        final AppLocalizations localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.translate('error_updating_location')}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  // Apply filters based on selected criteria
  void _applyFilters() {
    setState(() {
      _filteredDonations = _acceptedDonations.where((donation) {
        // Apply time filter
        if (_selectedTimeFilter != 'All') {
          final DateTime acceptedAt = donation['acceptedAt'] != null
              ? DateTime.parse(donation['acceptedAt'])
              : DateTime.now();

          final int daysDifference =
              DateTime.now().difference(acceptedAt).inDays;

          switch (_selectedTimeFilter) {
            case 'Today':
              if (daysDifference > 0) return false;
              break;
            case 'This Week':
              if (daysDifference > 7) return false;
              break;
            case 'This Month':
              if (daysDifference > 30) return false;
              break;
          }
        }

        // Apply food type filter
        if (_selectedFoodTypeFilter != 'All') {
          final String foodType = donation['foodType'] ?? 'unknown';
          if (foodType.toLowerCase() != _selectedFoodTypeFilter.toLowerCase()) {
            return false;
          }
        }
        
        // Apply search query filter
        if (_searchQuery.isNotEmpty) {
          final String query = _searchQuery.toLowerCase();
          final String foodName = (donation['foodName'] ?? '').toLowerCase();
          return foodName.contains(query);
        }

        return true;
      }).toList();
    });
  }

  Future<void> _addFeedback(String donationId, String currentFeedback) async {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final TextEditingController feedbackController =
        TextEditingController(text: currentFeedback);

    final feedbackResult = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.translate('add_feedback')),
        content: TextField(
          controller: feedbackController,
          decoration: InputDecoration(
            hintText: localizations.translate('share_experience_hint'),
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, feedbackController.text),
            child: Text(localizations.translate('submit')),
          ),
        ],
      ),
    );

    if (feedbackResult != null && feedbackResult.isNotEmpty) {
      try {
        setState(() {
          _isLoading = true;
        });

        await _apiService.addFeedback(
          acceptedDonationId: donationId,
          feedback: feedbackResult,
        );

        // Update the donation in the local list
        await _fetchAcceptedDonations();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.translate('feedback_submitted_successfully')),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error adding feedback: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${localizations.translate('error_submitting_feedback')}: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                      localizations.translate('filter_donation_history'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: primaryGreen),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Time Period Filter
                Text(
                  localizations.translate('time_period'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Today', 'This Week', 'This Month'].map((type) {
                      bool isSelected = _selectedTimeFilter == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            localizations.translate(type.toLowerCase().replaceAll(' ', '_')),
                            style: TextStyle(
                              color: isSelected ? Colors.white : primaryGreen,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: primaryGreen,
                          backgroundColor: lightGreen,
                          onSelected: (selected) {
                            setStateModal(() {
                              _selectedTimeFilter = type;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Food Type Filter
                Text(
                  localizations.translate('food_type'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Veg', 'NonVeg', 'Jain'].map((type) {
                      bool isSelected = _selectedFoodTypeFilter == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            localizations.translate(type.toLowerCase()),
                            style: TextStyle(
                              color: isSelected ? Colors.white : primaryGreen,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: primaryGreen,
                          backgroundColor: lightGreen,
                          onSelected: (selected) {
                            setStateModal(() {
                              _selectedFoodTypeFilter = type;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Apply and Reset Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        setStateModal(() {
                          _selectedTimeFilter = 'All';
                          _selectedFoodTypeFilter = 'All';
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryGreen,
                        side: BorderSide(color: primaryGreen),
                      ),
                      child: Text(localizations.translate('reset')),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Update state in parent
                        setState(() {
                          _selectedTimeFilter = _selectedTimeFilter;
                          _selectedFoodTypeFilter = _selectedFoodTypeFilter;
                        });
                        // Apply filters
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(localizations.translate('donation_history'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (_showDistance)
            IconButton(
              icon: _isGettingLocation
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.my_location),
              onPressed: _isGettingLocation ? null : _refreshWithLocation,
              tooltip: localizations.translate('update_location'),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAcceptedDonations,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildFilterSection() {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final displayDonations =
        (_selectedTimeFilter == 'All' && _selectedFoodTypeFilter == 'All' && _searchQuery.isEmpty)
            ? _acceptedDonations
            : _filteredDonations;
            
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${localizations.translate('donation_history')} (${displayDonations.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showFilterBottomSheet,
            icon: const Icon(Icons.filter_list, size: 18),
            label: Text(localizations.translate('filter')),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActiveFilters() {
    final AppLocalizations localizations = AppLocalizations.of(context);
    if (_selectedTimeFilter == 'All' && _selectedFoodTypeFilter == 'All' && _searchQuery.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_selectedTimeFilter != 'All')
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Chip(
                  label: Text('${localizations.translate('time')}: ${localizations.translate(_selectedTimeFilter.toLowerCase().replaceAll(' ', '_'))}'),
                  deleteIcon: const Icon(Icons.close, size: 15),
                  onDeleted: () {
                    setState(() {
                      _selectedTimeFilter = 'All';
                      _applyFilters();
                    });
                  },
                  backgroundColor: lightGreen,
                  labelStyle: TextStyle(color: primaryGreen),
                ),
              ),
            if (_selectedFoodTypeFilter != 'All')
              Chip(
                label: Text('${localizations.translate('type')}: ${localizations.translate(_selectedFoodTypeFilter.toLowerCase())}'),
                deleteIcon: const Icon(Icons.close, size: 15),
                onDeleted: () {
                  setState(() {
                    _selectedFoodTypeFilter = 'All';
                    _applyFilters();
                  });
                },
                backgroundColor: lightGreen,
                labelStyle: TextStyle(color: primaryGreen),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final AppLocalizations localizations = AppLocalizations.of(context);
    
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
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
              onPressed: _fetchAcceptedDonations,
              icon: const Icon(Icons.refresh),
              label: Text(localizations.translate('retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_acceptedDonations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 70,
              color: lightGreen,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.translate('no_donation_history_found'),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.translate('accept_donations_to_see'),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to the ViewDonationsScreen
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
              icon: const Icon(Icons.search),
              label: Text(localizations.translate('browse_donations')),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Add search bar - always visible
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
              prefixIcon: Icon(Icons.search, color: primaryGreen),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: lightGreen),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: lightGreen),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: primaryGreen, width: 2.0),
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
        
        // Filter button row - always visible
        _buildFilterSection(),
        
        // Active filter indicators - only visible when filters are active
        _buildActiveFilters(),
        
        // Donation list or no results state
        Expanded(
          child: _filteredDonations.isEmpty && 
                (_selectedTimeFilter != 'All' || _selectedFoodTypeFilter != 'All' || _searchQuery.isNotEmpty)
              ? _buildNoResultsState()
              : RefreshIndicator(
                  onRefresh: _fetchAcceptedDonations,
                  color: primaryGreen,
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

  // New widget to show when filters return no results
  Widget _buildNoResultsState() {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_alt_off,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.translate('no_donations_match_criteria'),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _searchQuery.isNotEmpty
                    ? '${localizations.translate('no_results_for')} "$_searchQuery"'
                    : localizations.translate('try_adjusting_filters'),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedTimeFilter = 'All';
                      _selectedFoodTypeFilter = 'All';
                      _searchQuery = '';
                      _applyFilters();
                    });
                  },
                  icon: const Icon(Icons.clear),
                  label: Text(localizations.translate('clear_all_filters')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: secondaryGreen,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _fetchAcceptedDonations,
                  icon: const Icon(Icons.refresh),
                  label: Text(localizations.translate('refresh')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
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
    final String donorName = donation['donorName'] ?? localizations.translate('anonymous');
    final String deliveredBy = donation['deliveredby'] ?? localizations.translate('self_pickup');
    final String feedback = donation['feedback'] ?? '';
    final double? distance = donation['distance'];

    // Format dates using DateTimeHelper to ensure IST timezone
    final DateTime acceptedAt = donation['acceptedAt'] != null
        ? DateTimeHelper.parseToIST(donation['acceptedAt'])
        : DateTime.now();
    final String acceptedDate = DateTimeHelper.formatDate(acceptedAt);
    final String acceptedTime = DateTimeHelper.formatTime(acceptedAt);

    final DateTime expiryDateTime = donation['expiryDateTime'] != null
        ? DateTimeHelper.parseToIST(donation['expiryDateTime'])
        : DateTime.now();

    // Just prepare the expiry date in case we need it
    DateTimeHelper.formatDate(expiryDateTime);

    // Get image URL if available
    String? imageUrl;
    if (donation.containsKey('imageUrl') && donation['imageUrl'] != null) {
      imageUrl = donation['imageUrl'];
    }

    // Determine the card border color based on how recent the donation is
    final int daysSinceAccepted = DateTime.now().difference(acceptedAt).inDays;
    Color borderColor;
    if (daysSinceAccepted <= 1) {
      borderColor = primaryGreen;
    } else if (daysSinceAccepted <= 7) {
      borderColor = accentGreen;
    } else {
      borderColor = lightGreen;
    }

    // Determine food type color and icon
    IconData foodTypeIcon;
    Color foodTypeColor;
    switch (foodType.toLowerCase()) {
      case 'veg':
        foodTypeIcon = Icons.eco;
        foodTypeColor = Colors.green;
        break;
      case 'nonveg':
        foodTypeIcon = Icons.restaurant;
        foodTypeColor = Colors.red;
        break;
      case 'jain':
        foodTypeIcon = Icons.spa;
        foodTypeColor = Colors.teal;
        break;
      default:
        foodTypeIcon = Icons.restaurant_menu;
        foodTypeColor = Colors.amber;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    ApiConfig.getImageUrl(imageUrl),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      if (kDebugMode) {
                        print('Error loading image: $error');
                      }
                      return Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.fastfood,
                          size: 50,
                          color: lightGreen,
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: lightGreen.withOpacity(0.2),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Icon(
                    Icons.fastfood,
                    size: 50,
                    color: lightGreen,
                  ),
                ),

              // Badge for showing days since accepted
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: borderColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        daysSinceAccepted == 0
                            ? localizations.translate('today')
                            : daysSinceAccepted == 1
                                ? localizations.translate('yesterday')
                                : '${daysSinceAccepted} ${localizations.translate('days_ago')}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: borderColor,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        foodName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: foodTypeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: foodTypeColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            foodTypeIcon,
                            size: 16,
                            color: foodTypeColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            localizations.translate(foodType.toLowerCase()),
                            style: TextStyle(
                              color: foodTypeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${localizations.translate('quantity')}: ${donation['quantity'] ?? localizations.translate('unknown')} ${localizations.translate('servings')}',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey[200], height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.person, color: accentGreen, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${localizations.translate('donated_by')}: $donorName',
                        style: TextStyle(color: Colors.grey[800]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, color: accentGreen, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${localizations.translate('accepted_on')}: $acceptedDate ${localizations.translate('at')} $acceptedTime',
                        style: TextStyle(color: Colors.grey[800]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.delivery_dining, color: accentGreen, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${localizations.translate('delivery_method')}: $deliveredBy',
                        style: TextStyle(color: Colors.grey[800]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Show distance information if available (useful for volunteers)
                if (distance != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.map, color: accentGreen, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${localizations.translate('distance')}: ${distance.toStringAsFixed(1)} ${localizations.translate('km')}',
                          style: TextStyle(
                            color: distance > 10
                                ? Colors.red[700]
                                : Colors.grey[800],
                            fontWeight: distance > 10
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),
                // Feedback section
                if (feedback.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.rate_review,
                                color: primaryGreen, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${localizations.translate('your_feedback')}:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          feedback,
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _addFeedback(donation['_id'], feedback),
                    icon: Icon(Icons.edit, size: 16, color: secondaryGreen),
                    label: Text(
                      localizations.translate('edit_feedback'),
                      style: TextStyle(color: secondaryGreen),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _addFeedback(donation['_id'], ''),
                    icon: const Icon(Icons.rate_review, size: 16),
                    label: Text(localizations.translate('add_feedback')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

