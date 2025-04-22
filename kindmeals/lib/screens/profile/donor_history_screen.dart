import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../utils/date_time_helper.dart';
import 'package:flutter/foundation.dart';
import '../../utils/app_localizations.dart';

class DonorHistoryScreen extends StatefulWidget {
  const DonorHistoryScreen({super.key});

  @override
  State<DonorHistoryScreen> createState() => _DonorHistoryScreenState();
}

class _DonorHistoryScreenState extends State<DonorHistoryScreen> {
  final _apiService = ApiService();
  List<Map<String, dynamic>> _donations = [];
  List<Map<String, dynamic>> _filteredDonations = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Filter options
  final List<String> _filterOptions = ['All', 'Active', 'Accepted', 'Expired'];

  @override
  void initState() {
    super.initState();
    _fetchDonorDonations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDonorDonations() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print('Fetching donor donation history...');
      final donationsData = await _apiService.getDonorDonations();

      setState(() {
        // Set all donation lists
        _donations =
            List<Map<String, dynamic>>.from(donationsData['combined'] ?? []);
        _applyFilter(_selectedFilter);
        _isLoading = false;
      });

      print('Fetched ${_donations.length} donations');
    } catch (e) {
      print('Error fetching donations: $e');
      String errorMsg = e.toString().replaceAll('Exception: ', '');

      // Provide more user-friendly error messages
      final AppLocalizations localizations = AppLocalizations.of(context);
      if (errorMsg.contains('Not found')) {
        errorMsg = localizations.translate('no_donation_history_found');
      } else if (errorMsg.contains('No authenticated user found')) {
        errorMsg = localizations.translate('sign_in_to_view_donations');
      }

      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
        _donations = [];
        _filteredDonations = [];
      });
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filterDonations();
    });
  }

  void _filterDonations() {
    List<Map<String, dynamic>> result = List.from(_donations);
    
    // Apply status filter if not 'All'
    if (_selectedFilter != 'All') {
      result = result.where((donation) {
        final status = donation['status'] ?? 'Active';
        return status == _selectedFilter;
      }).toList();
    }
    
    // Apply search query if not empty
    if (_searchQuery.isNotEmpty) {
      result = result.where((donation) {
        final foodName = (donation['foodName'] ?? '').toString().toLowerCase();
        return foodName.contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    setState(() {
      _filteredDonations = result;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterDonations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.translate('donation_history'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchDonorDonations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
              children: [
                _buildSearchBar(localizations),
                _buildFilterChips(),
                Expanded(
                  child: _buildBody(localizations),
                ),
              ],
            ),
    );
  }

  Widget _buildBody(AppLocalizations localizations) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.green));
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
              onPressed: _fetchDonorDonations,
              icon: const Icon(Icons.refresh),
              label: Text(localizations.translate('refresh')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    if (_donations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              size: 70,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.translate('no_donations_found'),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.translate('create_donations_to_see'),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add),
              label: Text(localizations.translate('create_donation')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return _buildDonationsList(localizations);
  }

  Widget _buildFilterChips() {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final List<String> translatedFilters = [
      localizations.translate('all'),
      localizations.translate('active'),
      localizations.translate('accepted'),
      localizations.translate('expired')
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filterOptions.length, (index) {
            final filter = _filterOptions[index];
            final translatedFilter = translatedFilters[index];
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(translatedFilter),
                selected: isSelected,
                onSelected: (_) => _applyFilter(filter),
                backgroundColor: Colors.grey.shade200,
                selectedColor: Colors.green.shade100,
                checkmarkColor: Colors.green.shade700,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.green.shade700 : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color:
                        isSelected ? Colors.green.shade300 : Colors.transparent,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDonationsList(AppLocalizations localizations) {
    if (_filteredDonations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.filter_list,
              size: 50,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                ? localizations.translate('no_filtered_donations_found').replaceFirst('{0}', localizations.translate(_selectedFilter.toLowerCase()))
                : localizations.translate('no_search_results_found').replaceFirst('{0}', _searchQuery),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchDonorDonations,
      color: Colors.green.shade600,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredDonations.length,
        itemBuilder: (context, index) {
          final donation = _filteredDonations[index];
          return _buildDonationCard(donation, localizations);
        },
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: localizations.translate('search_food_by_name'),
          prefixIcon: const Icon(Icons.search, color: Colors.green),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation, AppLocalizations localizations) {
    final String foodName = donation['foodName'] ?? localizations.translate('unknown');
    final String description = donation['description'] ?? localizations.translate('no_description');
    final String foodType = donation['foodType'] ?? localizations.translate('unknown');
    String status = donation['status'] ?? 'Active';

    // Determine status color
    Color statusColor;
    switch (status) {
      case 'Accepted':
        statusColor = Colors.green;
        break;
      case 'Expired':
        statusColor = Colors.grey.shade800;
        break;
      case 'Active':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.blue;
        break;
    }

    // Format dates using DateTimeHelper
    String uploadDate = localizations.translate('unknown');
    String expiryDate = localizations.translate('unknown');

    if (donation['timeOfUpload'] != null) {
      final DateTime timeOfUpload =
          DateTimeHelper.parseToIST(donation['timeOfUpload']);
      uploadDate = DateTimeHelper.formatDateTime(timeOfUpload);

      if (kDebugMode) {
        print('Formatted upload date: $uploadDate');
      }
    }

    if (donation['expiryDateTime'] != null) {
      final DateTime expiryDateTime =
          DateTimeHelper.parseToIST(donation['expiryDateTime']);
      expiryDate = DateTimeHelper.formatDateTime(expiryDateTime);

      if (kDebugMode) {
        print('Formatted expiry date: $expiryDate');
      }
    }

    // Get recipient info for accepted donations
    String recipientName = donation['recipientName'] ?? '';
    String acceptedDate = '';

    if (status == 'Accepted' && donation['acceptedAt'] != null) {
      final DateTime acceptedAt =
          DateTimeHelper.parseToIST(donation['acceptedAt']);
      acceptedDate = DateTimeHelper.formatDateTime(acceptedAt);

      if (kDebugMode) {
        print('Formatted accepted date: $acceptedDate');
      }
    }

    // Get image URL if available
    String? imageUrl;
    if (donation.containsKey('imageUrl') && donation['imageUrl'] != null) {
      imageUrl = ApiConfig.getImageUrl(donation['imageUrl']);
    }

    // Get expiry info for expired donations
    String expiredDate = '';
    if (status == 'Expired' && donation['expiredAt'] != null) {
      final DateTime expiredAt =
          DateTimeHelper.parseToIST(donation['expiredAt']);
      expiredDate = DateTimeHelper.formatDateTime(expiredAt);

      if (kDebugMode) {
        print('Formatted expired date: $expiredDate');
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              localizations.translate(status.toLowerCase()),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food image
                    if (imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          foodType.toLowerCase() == 'veg'
                              ? Icons.eco
                              : Icons.fastfood,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(width: 16),
                    // Food details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            foodName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${localizations.translate('quantity')}: ${donation['quantity']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                foodType.toLowerCase() == 'veg'
                                    ? Icons.eco
                                    : foodType.toLowerCase() == 'jain'
                                        ? Icons.spa
                                        : Icons.restaurant,
                                size: 16,
                                color: foodType.toLowerCase() == 'veg' ||
                                        foodType.toLowerCase() == 'jain'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                localizations.translate(foodType.toLowerCase()),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: foodType.toLowerCase() == 'veg' ||
                                          foodType.toLowerCase() == 'jain'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
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
                // Description
                Text(
                  '${localizations.translate('description')}:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
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
                        description.length > 80
                            ? '${description.substring(0, 80)}...'
                            : description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (description.length > 80)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            localizations.translate('tap_to_read_more'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Dates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${localizations.translate('created')}:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            uploadDate,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${localizations.translate('expires')}:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            expiryDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: status == 'Expired'
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Show recipient info for accepted donations
                if (status == 'Accepted' && recipientName.isNotEmpty) ...[
                  const Divider(height: 32),
                  Text(
                    '${localizations.translate('accepted_by')}:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipientName,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${localizations.translate('accepted_on')}:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    acceptedDate,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],

                // Show expiry info for expired donations
                if (status == 'Expired' && expiredDate.isNotEmpty) ...[
                  const Divider(height: 32),
                  Text(
                    '${localizations.translate('expired_on')}:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expiredDate,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade800,
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
