import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/firebase_service.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../utils/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class RegisterVolunteerScreen extends StatefulWidget {
  const RegisterVolunteerScreen({super.key});

  @override
  State<RegisterVolunteerScreen> createState() =>
      _RegisterVolunteerScreenState();
}

class _RegisterVolunteerScreenState extends State<RegisterVolunteerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aadharController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  final _aboutController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _firebaseService = FirebaseService();
  final _apiService = ApiService();

  File? _profileImage;
  File? _drivingLicenseImage;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _hasVehicle = false;
  String _vehicleType = 'Bike';
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;
  final List<String> _vehicleTypes = ['Bike', 'Scooter', 'Car', 'Other'];

  Future<void> _pickImage(bool isProfileImage) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isProfileImage) {
          _profileImage = File(image.path);
        } else {
          _drivingLicenseImage = File(image.path);
        }
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

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // If we have an address but no coordinates, try to get coordinates from the address
      if (_latitude == null && _addressController.text.isNotEmpty) {
        try {
          final coords = await LocationService.getCoordinatesFromAddress(
              _addressController.text);
          if (coords != null) {
            setState(() {
              _latitude = coords['latitude'];
              _longitude = coords['longitude'];
            });
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
        // Register with Firebase Authentication
        final userCredential =
            await _firebaseService.registerWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );

        // Update user profile with name and role
        await userCredential.user?.updateDisplayName(_nameController.text);

        // Register in our backend with role as 'volunteer'
        await _firebaseService.registerUserRole(
          _emailController.text,
          'volunteer',
        );

        // Register volunteer details including vehicle information
        await _apiService.registerVolunteer(
          volunteerName: _nameController.text,
          aadharID: _aadharController.text,
          address: _addressController.text,
          contact: _contactController.text,
          about: _aboutController.text,
          profileImage: _profileImage,
          hasVehicle: _hasVehicle,
          vehicleType: _hasVehicle ? _vehicleType : null,
          vehicleNumber: _hasVehicle ? _vehicleNumberController.text : null,
          drivingLicenseImage: _hasVehicle ? _drivingLicenseImage : null,
          latitude: _latitude,
          longitude: _longitude,
        );

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

          // Navigate to volunteer dashboard
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/volunteer/dashboard',
            (route) => false,
          );
        }
      } catch (e) {
        print('Error during volunteer registration: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Registration failed: ${e.toString().replaceAll('Exception: ', '')}'),
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
          title: Text(localizations.translate('volunteer_registration')), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!) as ImageProvider
                            : const AssetImage(
                                'assets/images/default_profile.png'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.green,
                          child: IconButton(
                            icon: const Icon(Icons.add_a_photo,
                                size: 18, color: Colors.white),
                            onPressed: () => _pickImage(true),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('full_name'),
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
                TextFormField(
                  controller: _aadharController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('aadhar_number'),
                    prefixIcon: const Icon(Icons.credit_card),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.translate('enter_id');
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
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: localizations.translate('address_click_detect'),
                    prefixIcon: const Icon(Icons.home),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onTap: _isGettingLocation ? null : _getLocation,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.translate('get_address');
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
                  controller: _aboutController,
                  decoration: InputDecoration(
                    labelText: localizations.translate('about_yourself'),
                    prefixIcon: const Icon(Icons.info_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(localizations.translate('have_vehicle')),
                  value: _hasVehicle,
                  activeColor: Colors.green,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (bool value) {
                    setState(() {
                      _hasVehicle = value;
                    });
                  },
                ),
                if (_hasVehicle) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: localizations.translate('vehicle_type'),
                      prefixIcon: const Icon(Icons.motorcycle),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: _vehicleType,
                    items: _vehicleTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _vehicleType = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (_hasVehicle && (value == null || value.isEmpty)) {
                        return localizations.translate('select_vehicle_type');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _vehicleNumberController,
                    decoration: InputDecoration(
                      labelText: localizations.translate('vehicle_number'),
                      prefixIcon: const Icon(Icons.confirmation_number),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (_hasVehicle && (value == null || value.isEmpty)) {
                        return localizations.translate('enter_vehicle_number');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.translate('driving_license'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _pickImage(false),
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _drivingLicenseImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    _drivingLicenseImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.upload_file,
                                          size: 40, color: Colors.grey),
                                      const SizedBox(height: 8),
                                      Text(localizations.translate('upload_license')),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
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
                const SizedBox(height: 16),
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
    _emailController.dispose();
    _passwordController.dispose();
    _aadharController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _aboutController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }
}
