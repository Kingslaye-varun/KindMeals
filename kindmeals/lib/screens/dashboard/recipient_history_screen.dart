import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
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
      final donations = await _apiService.getRecipientDonations();
      print('Fetched ${donations.length} accepted donations');

      setState(() {
        _acceptedDonations = donations;
        _applyFilters(); // Apply any active filters
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching accepted donations: $e');
      String errorMsg = e.toString().replaceAll('Exception: ', '');

      // Provide more user-friendly error messages
      if (errorMsg.contains('Not found')) {
        errorMsg = 'No donation history found. Please try again later.';
      } else if (errorMsg.contains('No authenticated user found')) {
        errorMsg = 'Please sign in to view your donation history.';
      } else {
        // General error message for any other error
        errorMsg = 'Unable to load donations. Please try again later.';
      }

      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
        // Initialize with empty list to prevent null errors
        _acceptedDonations = [];
      });
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

        return true;
      }).toList();
    });
  }

  Future<void> _addFeedback(String donationId, String currentFeedback) async {
    final TextEditingController feedbackController =
        TextEditingController(text: currentFeedback);

    final feedbackResult = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Feedback'),
        content: TextField(
          controller: feedbackController,
          decoration: const InputDecoration(
            hintText: 'Share your experience about this donation...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, feedbackController.text),
            child: const Text('Submit'),
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
            const SnackBar(
              content: Text('Feedback submitted successfully!'),
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
                  'Error submitting feedback: ${e.toString().replaceAll('Exception: ', '')}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Donation History',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAcceptedDonations,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Donations',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Time filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    labelText: 'Time',
                    labelStyle: TextStyle(color: secondaryGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: lightGreen),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: lightGreen),
                    ),
                  ),
                  value: _selectedTimeFilter,
                  items: ['All', 'Today', 'This Week', 'This Month']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedTimeFilter = newValue;
                        _applyFilters();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Food type filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    labelText: 'Food Type',
                    labelStyle: TextStyle(color: secondaryGreen),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: lightGreen),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: lightGreen),
                    ),
                  ),
                  value: _selectedFoodTypeFilter,
                  items: ['All', 'Veg', 'NonVeg', 'Jain'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedFoodTypeFilter = newValue;
                        _applyFilters();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Reset filters button
          Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedTimeFilter = 'All';
                  _selectedFoodTypeFilter = 'All';
                  _applyFilters();
                });
              },
              icon: Icon(Icons.clear, color: secondaryGreen, size: 16),
              label: Text(
                'Reset Filters',
                style: TextStyle(color: secondaryGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
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
                'Error: $_errorMessage',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchAcceptedDonations,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
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
            const Text(
              'No donation history found',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Accept donations to see them here',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to the ViewDonationsScreen
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
              icon: const Icon(Icons.search),
              label: const Text('Browse Donations'),
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

    // Check for filtered results
    if (_filteredDonations.isEmpty &&
        (_selectedTimeFilter != 'All' || _selectedFoodTypeFilter != 'All')) {
      return Center(
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
              'No donations match your filters',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedTimeFilter = 'All';
                  _selectedFoodTypeFilter = 'All';
                  _applyFilters();
                });
              },
              icon: Icon(Icons.clear, size: 16),
              label: Text('Clear Filters'),
              style: TextButton.styleFrom(
                foregroundColor: secondaryGreen,
              ),
            ),
          ],
        ),
      );
    }

    final displayDonations =
        (_selectedTimeFilter == 'All' && _selectedFoodTypeFilter == 'All')
            ? _acceptedDonations
            : _filteredDonations;

    return RefreshIndicator(
      onRefresh: _fetchAcceptedDonations,
      color: primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: displayDonations.length,
        itemBuilder: (context, index) {
          final donation = displayDonations[index];
          return _buildDonationCard(donation);
        },
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation) {
    final String foodName = donation['foodName'] ?? 'Unknown';
    final String description = donation['description'] ?? 'No description';
    final String foodType = donation['foodType'] ?? 'Unknown';
    final String donorName = donation['donorName'] ?? 'Anonymous';
    final String deliveredBy = donation['deliveredby'] ?? 'Self-pickup';
    final String feedback = donation['feedback'] ?? '';

    // Format dates
    final DateTime acceptedAt = donation['acceptedAt'] != null
        ? DateTime.parse(donation['acceptedAt'])
        : DateTime.now();
    final String acceptedDate = DateFormat('MM/dd/yyyy').format(acceptedAt);
    final String acceptedTime = DateFormat('hh:mm a').format(acceptedAt);

    final DateTime expiryDateTime = donation['expiryDateTime'] != null
        ? DateTime.parse(donation['expiryDateTime'])
        : DateTime.now();
    DateFormat('MM/dd/yyyy').format(expiryDateTime);

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
                      print('Error loading image: $error');
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
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: Offset(0, 1),
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
                      SizedBox(width: 4),
                      Text(
                        daysSinceAccepted == 0
                            ? 'Today'
                            : daysSinceAccepted == 1
                                ? 'Yesterday'
                                : '$daysSinceAccepted days ago',
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
                          SizedBox(width: 4),
                          Text(
                            foodType.toUpperCase(),
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
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Quantity: ${donation['quantity'] ?? 'Unknown'} servings',
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
                        'Donated by: $donorName',
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
                        'Accepted on: $acceptedDate at $acceptedTime',
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
                        'Delivery method: $deliveredBy',
                        style: TextStyle(color: Colors.grey[800]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
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
                            SizedBox(width: 4),
                            Text(
                              'Your Feedback:',
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
                      'Edit Feedback',
                      style: TextStyle(color: secondaryGreen),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _addFeedback(donation['_id'], ''),
                    icon: const Icon(Icons.rate_review, size: 16),
                    label: const Text('Add Feedback'),
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
