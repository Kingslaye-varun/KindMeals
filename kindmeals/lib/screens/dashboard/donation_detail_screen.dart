// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../utils/date_time_helper.dart';
import '../../utils/app_localizations.dart';

class DonationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> donation;
  final VoidCallback? onDonationAccepted;

  const DonationDetailScreen({
    super.key,
    required this.donation,
    this.onDonationAccepted,
  });

  @override
  State<DonationDetailScreen> createState() => _DonationDetailScreenState();
}

class _DonationDetailScreenState extends State<DonationDetailScreen> {
  final _apiService = ApiService();
  bool _isLoading = false;
  String? _error;
  bool _needsVolunteer = false;

  // Colors
  final Color _primaryColor = Colors.green.shade600;
  final Color _secondaryColor = Colors.green.shade100;
  final Color _accentColor = Colors.orange.shade700;

  // Helper to get image URL from donation data
  String? _getImageUrl() {
    if (widget.donation.containsKey('imageUrl') &&
        widget.donation['imageUrl'] != null &&
        widget.donation['imageUrl'].toString().isNotEmpty) {
      return widget.donation['imageUrl'];
    }
    if (widget.donation.containsKey('foodImage') &&
        widget.donation['foodImage'] != null &&
        widget.donation['foodImage'].toString().isNotEmpty) {
      return widget.donation['foodImage'];
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Initialize _needsVolunteer based on the donation's original setting
    _needsVolunteer = widget.donation['needsVolunteer'] == true;

    if (kDebugMode) {
      print('Initializing with donor volunteer preference: $_needsVolunteer');
    }
  }

  // Launch phone call intent for calling the donor
  
  // Launch Google Maps with directions to donor's location

  Future<void> _acceptDonation() async {
    final AppLocalizations localizations = AppLocalizations.of(context);
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await _apiService.acceptDonation(
        donationId: widget.donation['_id'],
        needsVolunteer: _needsVolunteer,
      );

      if (mounted) {
        // Call the onDonationAccepted callback if provided
        if (widget.onDonationAccepted != null) {
          widget.onDonationAccepted!();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_needsVolunteer
                ? localizations.translate('donation_accepted_with_volunteer')
                : localizations.translate('donation_accepted_self_pickup')),
            backgroundColor: _primaryColor,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error accepting donation: $e');
      }
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

      setState(() {
        _error = displayMessage;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $_error'),
            backgroundColor: Colors.red.shade700,
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final String? imageUrl = _getImageUrl();
    final String foodName = widget.donation['foodName'] ?? localizations.translate('unknown_food');
    final String description =
        widget.donation['description'] ?? localizations.translate('no_description_available');
    final String foodType = widget.donation['foodType'] ?? localizations.translate('unknown');
    final String quantity = '${widget.donation['quantity'] ?? 0} ${localizations.translate('servings')}';
    final String address =
        widget.donation['location']?['address'] ?? localizations.translate('unknown_location');
    final String donorName = widget.donation['donorName'] ?? localizations.translate('anonymous_donor');
    final bool needsVolunteerOriginal =
        widget.donation['needsVolunteer'] == true;

    // Format expiry date
    final String expiryDateTime =
        _formatDateTime(widget.donation['expiryDateTime'] ?? '');
    final DateTime expiryDate = DateTime.parse(
        widget.donation['expiryDateTime'] ?? DateTime.now().toIso8601String());
    final Duration timeRemaining = expiryDate.difference(DateTime.now());
    final bool isExpiringSoon = timeRemaining.inHours < 6;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          localizations.translate('donation_details'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food image with overlay
                  Stack(
                    children: [
                      if (imageUrl != null)
                        SizedBox(
                          height: 220,
                          width: double.infinity,
                          child: Image.network(
                            ApiConfig.getImageUrl(imageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage(foodType, localizations);
                            },
                          ),
                        )
                      else
                        _buildPlaceholderImage(foodType, localizations),

                      // Food type badge
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getFoodTypeColor(foodType),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            foodType.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      // Expiring soon badge
                      if (isExpiringSoon)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.timer,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  localizations.translate('expiring_soon').toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Content area
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Food name and basic details
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                foodName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color:
                                              _primaryColor.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.restaurant,
                                          size: 14,
                                          color: _primaryColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          quantity,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: _primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isExpiringSoon
                                          ? Colors.red.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isExpiringSoon
                                            ? Colors.red.withOpacity(0.3)
                                            : Colors.orange.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: isExpiringSoon
                                              ? Colors.red
                                              : Colors.orange,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${localizations.translate('expires')}: ${expiryDateTime.split(" ")[0]}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: isExpiringSoon
                                                ? Colors.red
                                                : Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Donor Information
                        _buildSectionContainer(
                          title: localizations.translate('donor_information'),
                          icon: Icons.person,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoItem(
                                label: localizations.translate('donor'),
                                value: donorName,
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoItem(
                                label: localizations.translate('location'),
                                value: address,
                                icon: Icons.location_on_outlined,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Food Description
                        _buildSectionContainer(
                          title: localizations.translate('food_description'),
                          icon: Icons.description_outlined,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade800,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 18,
                                    color: isExpiringSoon
                                        ? Colors.red
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${localizations.translate('exact_expiry')}: $expiryDateTime',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isExpiringSoon
                                            ? Colors.red
                                            : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Volunteer assistance section
                        _buildSectionContainer(
                          title: localizations.translate('delivery_options'),
                          icon: Icons.delivery_dining,
                          backgroundColor: _needsVolunteer
                              ? _accentColor.withOpacity(0.08)
                              : null,
                          borderColor: _needsVolunteer
                              ? _accentColor.withOpacity(0.3)
                              : null,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          localizations.translate('need_volunteer_assistance'),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: _needsVolunteer
                                                ? _accentColor
                                                : Colors.grey.shade800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _needsVolunteer
                                              ? localizations.translate('yes_request_volunteer')
                                              : localizations.translate('no_pickup_myself'),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _needsVolunteer,
                                    onChanged: (value) {
                                      setState(() {
                                        _needsVolunteer = value;
                                      });
                                    },
                                    activeColor: _accentColor,
                                    activeTrackColor:
                                        _accentColor.withOpacity(0.3),
                                  ),
                                ],
                              ),
                              if (needsVolunteerOriginal !=
                                  _needsVolunteer) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          localizations.translate('changed_from_original'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        localizations.translate('using_donor_preference'),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Accept Button
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _acceptDonation,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: _primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                localizations.translate('accept_donation').toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Error message if any
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
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

  Widget _buildPlaceholderImage(String foodType, AppLocalizations localizations) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _secondaryColor,
            _primaryColor.withOpacity(0.3),
          ],
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
            size: 70,
            color: _primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.translate('no_image_available'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: _primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor ?? Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getFoodTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'veg':
        return Colors.green.shade700;
      case 'nonveg':
        return Colors.red.shade700;
      case 'jain':
        return Colors.purple.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _formatDateTime(String dateTimeStr) {
    if (dateTimeStr.isEmpty) return 'Unknown';
    // Use the DateTimeHelper to ensure consistent IST timezone handling
    return DateTimeHelper.formatAPIDateTime24Hour(dateTimeStr);
  }
}
