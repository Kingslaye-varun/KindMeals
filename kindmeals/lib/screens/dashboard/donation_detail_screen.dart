import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

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
    // This will set the toggle switch to match the donor's preference initially
    _needsVolunteer = widget.donation['needsVolunteer'] == true;

    if (kDebugMode) {
      print('Initializing with donor volunteer preference: $_needsVolunteer');
    }
  }

  Future<void> _acceptDonation() async {
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
                ? 'Donation accepted successfully. A volunteer will assist with delivery.'
                : 'Donation accepted successfully. You will need to collect this yourself.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
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

      setState(() {
        _error = displayMessage;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $_error'),
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

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = _getImageUrl();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Details'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl != null)
                    Image.network(
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
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.fastfood,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
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
                                widget.donation['foodName'],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getFoodTypeColor(
                                    widget.donation['foodType']),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.donation['foodType'].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.restaurant,
                          'Quantity',
                          '${widget.donation['quantity']} meals',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.access_time,
                          'Expires',
                          _formatDateTime(widget.donation['expiryDateTime']),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.location_on,
                          'Pickup Location',
                          widget.donation['location']['address'],
                        ),
                        if (widget.donation['needsVolunteer']) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            Icons.volunteer_activism,
                            'Volunteer Needed',
                            'Yes - for delivery assistance',
                            iconColor: Colors.orange,
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.donation['description'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),

                        // Volunteer assistance switch
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _needsVolunteer
                                ? Colors.orange.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _needsVolunteer
                                  ? Colors.orange.shade200
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.volunteer_activism,
                                    color: _needsVolunteer
                                        ? Colors.orange
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Need Volunteer Assistance?',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _needsVolunteer
                                                ? Colors.orange.shade800
                                                : Colors.grey.shade800,
                                          ),
                                        ),
                                        Text(
                                          _needsVolunteer
                                              ? 'Yes, I need a volunteer to help deliver this donation'
                                              : 'No, I will pick up this donation myself',
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
                                    activeColor: Colors.orange,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Note: This was initially set based on the donor\'s preference',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _acceptDonation,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Accept Donation',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, color: iconColor ?? Colors.green),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Color _getFoodTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'veg':
        return Colors.green;
      case 'nonveg':
        return Colors.red;
      case 'jain':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String dateTimeStr) {
    final dateTime = DateTime.parse(dateTimeStr);
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/${dateTime.year} $hour:$minute';
  }
}
