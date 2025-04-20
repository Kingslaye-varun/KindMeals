import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/api_config.dart';

class PostDonationScreen extends StatefulWidget {
  const PostDonationScreen({super.key});

  @override
  State<PostDonationScreen> createState() => _PostDonationScreenState();
}

class _PostDonationScreenState extends State<PostDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _apiService = ApiService();

  String? _selectedFoodType;
  File? _foodImage;
  bool _isLoading = false;
  bool _needsVolunteer = false;
  DateTime? _expiryDateTime;
  bool _isUserDonor = false;
  bool _isCheckingUserType = true;
  String _errorMessage = '';

  final List<String> _foodTypes = ['veg', 'nonveg', 'jain'];

  @override
  void initState() {
    super.initState();
    // Print API configuration for debugging
    ApiConfig.printAPIConfig();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    try {
      setState(() {
        _isCheckingUserType = true;
        _errorMessage = '';
      });

      print('DEBUG: Checking user type and fetching profile...');
      final currentUser = FirebaseAuth.instance.currentUser;
      print('DEBUG: Current Firebase user: ${currentUser?.uid}');

      final userProfile = await _apiService.getDirectUserProfile();
      print('DEBUG: User profile received: ${userProfile.toString()}');

      // Store the user profile for later use

      final userType = userProfile['userType'] ?? '';

      // Check if profile data is available
      if (userProfile.containsKey('profile') &&
          userProfile['profile'] != null &&
          userProfile['profile'].containsKey('_id')) {
        print('DEBUG: MongoDB ID: ${userProfile['profile']['_id']}');
      } else {
        print('WARNING: MongoDB ID not found in profile data');
      }

      // Check if the user is a donor
      if (userType.toLowerCase() != 'donor') {
        setState(() {
          _isUserDonor = false;
          _errorMessage =
              'You need to register as a donor to post donations. Please update your profile or contact support.';
          _isCheckingUserType = false;
        });
        return;
      }

      // If we get here, the user is a donor in the directdonors collection
      setState(() {
        _isUserDonor = true;
        _isCheckingUserType = false;
      });

      print('DEBUG: User type check completed. Is Donor: $_isUserDonor');
    } catch (e) {
      print('DEBUG: User type check error: $e');
      setState(() {
        _isUserDonor = false;
        _errorMessage =
            'Could not verify your account type. Please try again later.';
        _isCheckingUserType = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Reduced quality to prevent large file sizes
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        setState(() {
          _foodImage = File(image.path);
        });
        print('Image selected: ${image.path}');
        print('Image size: ${await _foodImage!.length()} bytes');
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _expiryDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _submitDonation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validate required fields that might not be caught by form validation
      if (_expiryDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a valid expiry date and time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedFoodType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a food type'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Make sure we reload the user before posting
        await FirebaseAuth.instance.currentUser?.reload();

        // Force token refresh to ensure we have the latest token
        await FirebaseAuth.instance.currentUser?.getIdToken(true);

        // Add note to explain volunteer option to users
        if (_needsVolunteer) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Note: When your donation is accepted by a recipient, they will be able to request a volunteer for delivery.'),
              duration: Duration(seconds: 5),
            ),
          );
        }

        await _apiService.createDonation(
          foodName: _foodNameController.text,
          quantity: int.parse(_quantityController.text),
          description: _descriptionController.text,
          expiryDateTime:
              _expiryDateTime!, // Now safe to use ! since we checked above
          foodType: _selectedFoodType!,
          address: _addressController.text,
          needsVolunteer: _needsVolunteer,
          foodImage: _foodImage,
        );

        setState(() {
          _isLoading = false;
          _foodImage = null;
        });

        _formKey.currentState!.reset();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = 'Failed to post donation. Please try again.';

        // Handle specific authentication errors
        if (e.toString().contains('User not found in database') ||
            e.toString().contains('Authentication error') ||
            e.toString().contains('authentication token')) {
          errorMessage =
              'Authentication error: Please sign out and sign in again to refresh your credentials.';

          // Show a dialog with more detailed instructions
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Authentication Error'),
              content: const Text(
                  'Your donor profile could not be verified. This could happen if:\n\n'
                  '1. You recently registered and your profile is not fully synced\n'
                  '2. Your authentication token has expired\n\n'
                  'Please sign out and sign back in to refresh your credentials.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () async {
                    // Sign out and navigate to login
                    await FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('Sign Out Now'),
                ),
              ],
            ),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );

        print('Error posting donation: $e');
      }
    }
  }

  Future<void> _signOut() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseAuth.instance.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully. Please sign in again.'),
            backgroundColor: Colors.blue,
          ),
        );

        // Navigate to login screen
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
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

  Future<void> _refreshAuthState() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Force token refresh
        await currentUser.reload();
        await currentUser.getIdToken(true);

        // Re-check user type
        await _checkUserType();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication refreshed!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('No user is signed in');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing authentication: $e'),
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
    if (_isCheckingUserType) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Post Donation'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Donation'),
        centerTitle: true,
      ),
      body: _errorMessage.isNotEmpty && !_isUserDonor
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 70,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _refreshAuthState,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Authentication'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out & Sign In Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Go to Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Go Back'),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Note: If you just registered, please log out and log back in to refresh your profile status.",
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _checkUserType,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Status'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _foodImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _foodImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_a_photo,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _foodNameController,
                        decoration: InputDecoration(
                          labelText: 'Food Name',
                          prefixIcon: const Icon(Icons.fastfood),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter food name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          prefixIcon: const Icon(Icons.numbers),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedFoodType,
                        decoration: InputDecoration(
                          labelText: 'Food Type',
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: _foodTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFoodType = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select food type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Pickup Address',
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter pickup address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Expiry Date & Time'),
                        subtitle: Text(
                          _expiryDateTime != null
                              ? '${_expiryDateTime!.day.toString().padLeft(2, '0')}/${_expiryDateTime!.month.toString().padLeft(2, '0')}/${_expiryDateTime!.year} ${_expiryDateTime!.hour.toString().padLeft(2, '0')}:${_expiryDateTime!.minute.toString().padLeft(2, '0')}'
                              : 'Not set',
                        ),
                        leading: const Icon(Icons.access_time),
                        onTap: _selectDateTime,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Need Volunteer for Delivery'),
                        value: _needsVolunteer,
                        onChanged: (bool value) {
                          setState(() {
                            _needsVolunteer = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitDonation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Post Donation',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
