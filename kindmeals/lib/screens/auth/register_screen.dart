import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/firebase_service.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../utils/app_localizations.dart';
import 'package:flutter/foundation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  final _aboutController = TextEditingController();
  final _orgNameController = TextEditingController();
  final _firebaseService = FirebaseService();
  final _apiService = ApiService();

  String? _selectedType;
  File? _profileImage;
  bool _isLoading = false;
  bool _obscurePassword = true;
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;

  final List<String> _types = ['Donor', 'Recipient', 'Volunteer'];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });

        // Attempt to get the address from coordinates
        final address = await LocationService.getAddressFromCoordinates(
            position.latitude, position.longitude);
        if (address != null && address.isNotEmpty) {
          setState(() {
            _addressController.text = address;
          });

          if (kDebugMode) {
            print('Address updated: $address');
          }
        } else {
          if (kDebugMode) {
            print('Could not get address from coordinates');
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Could not get your location. Please ensure location services are enabled.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a user type'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // If we have an address but no coordinates, try to get coordinates from the address
      if (_latitude == null && _addressController.text.isNotEmpty) {
        try {
          final coords = await LocationService.getCoordinatesFromAddress(
              _addressController.text);
          if (coords != null) {
            _latitude = coords['latitude'];
            _longitude = coords['longitude'];
            if (kDebugMode) {
              print('Coordinates from address: $_latitude, $_longitude');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Could not get coordinates from address: $e');
          }
        }
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // First, create Firebase authentication
        if (kDebugMode) {
          print('Starting Firebase registration...');
        }
        final userCredential =
            await _firebaseService.signUpWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (kDebugMode) {
          print('Firebase registration successful: ${userCredential.user?.uid}');
        }

        // Verify the user is properly authenticated
        if (userCredential.user == null) {
          throw Exception(
              'Failed to create user: No user returned from Firebase');
        }

        // Force a token refresh to ensure the user is properly authenticated
        await userCredential.user?.getIdToken(true);

        try {
          // Register directly to the appropriate collection based on selected type
          if (kDebugMode) {
            print('Starting direct registration for type: $_selectedType');
          }

          // Try up to 3 times with exponentially increasing delays
          int retryCount = 0;
          bool success = false;
          Exception? lastError;

          while (retryCount < 3 && !success) {
            try {
              if (retryCount > 0) {
                if (kDebugMode) {
                  print(
                    'Retrying direct registration (attempt ${retryCount + 1})...');
                }
                // Exponential backoff
                await Future.delayed(
                    Duration(milliseconds: 500 * (1 << retryCount)));
              }

              if (_selectedType == 'Donor') {
                await _apiService.registerDonor(
                  donorname: _nameController.text,
                  orgName: _orgNameController.text,
                  identificationId: _idController.text,
                  address: _addressController.text,
                  contact: _contactController.text,
                  type: _selectedType!,
                  about: _aboutController.text,
                  profileImage: _profileImage,
                  latitude: _latitude,
                  longitude: _longitude,
                );
              } else if (_selectedType == 'Recipient') {
                await _apiService.registerRecipient(
                  name: _nameController.text,
                  ngoName: _orgNameController.text,
                  ngoId: _idController.text,
                  address: _addressController.text,
                  contact: _contactController.text,
                  type: _selectedType!,
                  about: _aboutController.text,
                  profileImage: _profileImage,
                  latitude: _latitude,
                  longitude: _longitude,
                );
              } else if (_selectedType == 'Volunteer') {
                await _apiService.registerVolunteer(
                  volunteerName: _nameController.text,
                  aadharID: _idController.text,
                  address: _addressController.text,
                  contact: _contactController.text,
                  about: _aboutController.text,
                  profileImage: _profileImage,
                  latitude: _latitude,
                  longitude: _longitude,
                );
              }

              success = true;
              if (kDebugMode) {
                print('Direct registration successful');
              }
              break;
            } catch (e) {
              lastError = e as Exception;
              if (kDebugMode) {
                print('Error on attempt ${retryCount + 1}: $e');
              }
              retryCount++;
            }
          }

          if (!success && lastError != null) {
            throw lastError;
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16),
              ),
            );

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
              (route) => false,
            );
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error during registration: $e');
          }
          // If profile registration fails, delete the Firebase user
          try {
            await userCredential.user?.delete();
            if (kDebugMode) {
              print('Firebase user deleted after registration failure');
            }
          } catch (deleteError) {
            if (kDebugMode) {
              print('Could not delete Firebase user: $deleteError');
            }
          }
          rethrow;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error during registration: $e');
        }
        if (mounted) {
          String errorMessage = 'Registration failed';
          if (e.toString().contains('E11000')) {
            errorMessage =
                'This email is already registered. Please use a different email or login.';
          } else if (e.toString().contains('email-already-in-use')) {
            errorMessage =
                'This email is already in use. Please use a different email or login.';
          } else if (e.toString().contains('No user returned from Firebase')) {
            errorMessage = 'Failed to create user account. Please try again.';
          } else if (e.toString().contains('No authenticated user found')) {
            errorMessage = 'Authentication failed. Please try again.';
          } else if (e.toString().contains('Failed to register donor: ')) {
            if (kDebugMode) {
              print('Donor registration error: ${e.toString()}');
            }
            errorMessage = e
                .toString()
                .replaceAll('Exception: Failed to register donor: ', '');
          } else if (e.toString().contains('Failed to register recipient: ')) {
            if (kDebugMode) {
              print('Recipient registration error: ${e.toString()}');
            }
            errorMessage = e
                .toString()
                .replaceAll('Exception: Failed to register recipient: ', '');
          } else if (e.toString().contains('Cannot connect to server')) {
            if (kDebugMode) {
              print('Server connection error: ${e.toString()}');
            }
            errorMessage =
                'Cannot connect to server. Please check your internet connection and try again.';
          } else {
            if (kDebugMode) {
              print('Unhandled error: ${e.toString()}');
            }
            errorMessage = e.toString().replaceAll('Exception: ', '');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
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
  }

  Future<void> _handleGoogleSignUp() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _firebaseService.signInWithGoogle();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google sign-up successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
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
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('register')), 
        centerTitle: true
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Image Selection
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: _pickImage,
                    child: Text(
                      _profileImage == null
                          ? localizations.translate('profile_pic')
                          : localizations.translate('change_profile_pic'),
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('name'),
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.translate('enter_name');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('aadhar_id'),
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.translate('enter_id');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: localizations.translate('address'),
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: IconButton(
                      icon: _isGettingLocation
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.green,
                              ),
                            )
                          : Icon(Icons.my_location, color: Colors.green),
                      onPressed: _isGettingLocation ? null : _getLocation,
                      tooltip: 'Get Current Location',
                    ),
                  ),
                  onTap: _isGettingLocation ? null : _getLocation,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.translate('enter_address');
                    }
                    return null;
                  },
                ),
                if (_latitude != null && _longitude != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                    child: Text(
                      'Location: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('email'),
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.translate('enter_email');
                    }
                    if (!value.contains('@')) {
                      return localizations.translate('valid_email');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('contact_number'),
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.translate('enter_contact');
                    }
                    if (value.length < 10) {
                      return localizations.translate('valid_contact');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('password'),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.translate('enter_password');
                    }
                    if (value.length < 6) {
                      return localizations.translate('password_length');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: localizations.translate('type'),
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: _types.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.translate('select_type');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _aboutController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('about'),
                    prefixIcon: const Icon(Icons.info),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.translate('enter_about');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _orgNameController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('org_name'),
                    prefixIcon: const Icon(Icons.business),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.translate('enter_org_name');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          localizations.translate('register'),
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignUp,
                  icon: Image.asset(
                    'assets/images/google_logo.png',
                    height: 24,
                  ),
                  label: Text(localizations.translate('google_signup')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
    _nameController.dispose();
    _idController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _aboutController.dispose();
    _orgNameController.dispose();
    super.dispose();
  }
}
