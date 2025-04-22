import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:kindmeals/services/api_service.dart';
import 'package:kindmeals/config/api_config.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? profileData;

  const EditProfileScreen({
    super.key,
    this.userData,
    this.profileData,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  bool _isLoading = false;
  String _errorMessage = '';
  final ApiService _apiService = ApiService();
  String? _currentProfileImageUrl;

  // Form controllers
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _orgNameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final profileData = widget.profileData;
    final userData = widget.userData;

    // Initialize with data from user profile if available
    _nameController = TextEditingController(
      text: profileData?['name'] ?? userData?['name'] ?? '',
    );

    _emailController = TextEditingController(
      text: profileData?['email'] ?? userData?['email'] ?? '',
    );

    _phoneController = TextEditingController(
      text: profileData?['contact'] ?? profileData?['phone'] ?? '',
    );

    _addressController = TextEditingController(
      text: profileData?['address'] ?? '',
    );

    _orgNameController = TextEditingController(
      text: profileData?['orgName'] ?? profileData?['ngoName'] ?? '',
    );

    _descriptionController = TextEditingController(
      text: profileData?['donorabout'] ??
          profileData?['reciabout'] ??
          profileData?['about'] ??
          '',
    );

    // Store current profile image URL if it exists
    _currentProfileImageUrl = userData?['profileImage'];
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userType = widget.userData?['type']?.toString().toLowerCase() ?? '';

      // Determine which update method to use based on user type
      if (userType.contains('donor')) {
        await _apiService.updateDonorProfile(
          name: _nameController.text,
          orgName: _orgNameController.text,
          address: _addressController.text,
          contact: _phoneController.text,
          about: _descriptionController.text,
          profileImage: _profileImage,
        );
      } else if (userType.contains('recipient')) {
        await _apiService.updateRecipientProfile(
          name: _nameController.text,
          ngoName: _orgNameController.text,
          address: _addressController.text,
          contact: _phoneController.text,
          about: _descriptionController.text,
          profileImage: _profileImage,
        );
      } else {
        // Generic update for volunteer or other types
        await _apiService.updateUserProfile(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          about: _descriptionController.text,
          profileImage: _profileImage,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return success result
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _orgNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (_currentProfileImageUrl != null &&
                                _currentProfileImageUrl!.isNotEmpty)
                            ? NetworkImage(ApiConfig.getImageUrl(
                                _currentProfileImageUrl!)) as ImageProvider
                            : null,
                    backgroundColor: Colors.grey[200],
                    child: (_profileImage == null &&
                            (_currentProfileImageUrl == null ||
                                _currentProfileImageUrl!.isEmpty))
                        ? const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField(
                  controller: _nameController,
                  label: 'Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false, // Email shouldn't be editable
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Contact',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your contact number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.location_on,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _orgNameController,
                  label: 'Organization Name',
                  icon: Icons.business,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your organization name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  icon: Icons.info,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
    );
  }
}
