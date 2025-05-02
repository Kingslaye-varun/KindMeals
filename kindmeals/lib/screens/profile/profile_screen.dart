// ignore_for_file: use_build_context_synchronously, deprecated_member_use, duplicate_ignore

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:kindmeals/services/api_service.dart';
import 'package:kindmeals/config/api_config.dart';
import 'package:kindmeals/services/firebase_service.dart';
import 'package:kindmeals/utils/app_localizations.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _profileData;
  final ApiService _apiService = ApiService();
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Try the new direct API first
      try {
        final directProfileData = await _apiService.getDirectUserProfile();
        if (kDebugMode) {
          print('=== DEBUG: Direct Profile Data ===');
        }
        if (kDebugMode) {
          print('Full direct profile data: $directProfileData');
        }
        if (kDebugMode) {
          print('User Type: ${directProfileData['userType']}');
        }
        if (kDebugMode) {
          print('Profile section: ${directProfileData['profile']}');
        }

        setState(() {
          _userData = {
            'email': directProfileData['profile']['email'],
            'profileImage': directProfileData['profile']['profileImage'],
            'type': directProfileData['userType'],
          };
          _profileData = directProfileData['profile'];
          _isLoading = false;
        });
        return;
      } catch (directError) {
        if (kDebugMode) {
          print(
              'Error loading profile with direct API, falling back: $directError');
        }
        // Fall back to the old API
      }

      // Legacy API as fallback
      final profileData = await _apiService.getUserProfile();
      setState(() {
        _userData = profileData['user'];
        _profileData = profileData['profile'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
      if (kDebugMode) {
        print('Error loading profile: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final localizations = AppLocalizations.of(context);
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });

      try {
        // Determine if user is donor or recipient
        final userType = _userData?['type']?.toString().toLowerCase();

        if (userType == 'donor') {
          await _apiService.updateDirectDonorProfile(
              profileImage: _profileImage);
        } else if (userType == 'recipient') {
          await _apiService.updateDirectRecipientProfile(
              profileImage: _profileImage);
        } else {
          throw Exception('Unknown user type');
        }

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.translate('profile_image_updated')),
            backgroundColor: Colors.green,
          ),
        );

        _loadUserProfile(); // Reload profile to get updated image URL
      } catch (e) {
        if (kDebugMode) {
          print('Error uploading profile image: $e');
        }
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.translate('failed_upload_image')} ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final localizations = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.translate('logout_failed')} ${e.toString()}'),
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
  
  void _showLanguageSelection() {
    final localizations = AppLocalizations.of(context);
    final appLocalizationsService = AppLocalizations.localizationsService;
    
    // List of supported languages with their native and English names
    final List<Map<String, String>> languages = [
      {'name': 'English', 'code': 'en', 'english': 'English'},
      {'name': 'हिंदी', 'code': 'hi', 'english': 'Hindi'},
      {'name': 'मराठी', 'code': 'mr', 'english': 'Marathi'},
      {'name': 'ગુજરાતી', 'code': 'gu', 'english': 'Gujarati'},
      {'name': 'தமிழ்', 'code': 'ta', 'english': 'Tamil'},
      {'name': 'తెలుగు', 'code': 'te', 'english': 'Telugu'},
      {'name': 'ಕನ್ನಡ', 'code': 'kn', 'english': 'Kannada'},
      {'name': 'മലയാളം', 'code': 'ml', 'english': 'Malayalam'},
      {'name': 'বাংলা', 'code': 'bn', 'english': 'Bengali'},
      {'name': 'ਪੰਜਾਬੀ', 'code': 'pa', 'english': 'Punjabi'},
      {'name': 'ଓଡ଼ିଆ', 'code': 'or', 'english': 'Odia'},
      {'name': 'অসমীয়া', 'code': 'as', 'english': 'Assamese'},
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.translate('change_language')),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final language = languages[index];
              final currentLangCode = languageCodes[appLocalizationsService.currentLanguage];
              final isSelected = currentLangCode == language['code'];
              
              return ListTile(
                title: Text(language['name']!),
                subtitle: Text(language['english']!),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.green.shade100 : Colors.grey.shade200,
                  ),
                  child: Text(
                    language['code']!.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.green.shade700 : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                trailing: isSelected 
                  ? Icon(Icons.check_circle, color: Colors.green.shade600)
                  : null,
                selected: isSelected,
                selectedTileColor: Colors.green.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: () async {
                  if (!isSelected) {
                    final appLanguage = getLanguageFromCode(language['code']!);
                    await appLocalizationsService.changeLanguage(appLanguage);
                    // Close the dialog
                    Navigator.pop(context);
                    // Force rebuild of the UI to apply the new language
                    setState(() {});
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.translate('cancel')),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getSectionIcon(title),
                  color: Colors.green.shade600,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSectionIcon(String title) {
    final localizations = AppLocalizations.of(context);
    
    if (title == localizations.translate('personal_information')) {
      return Icons.person;
    } else if (title == localizations.translate('contact_information')) {
      return Icons.contact_phone;
    } else if (title == localizations.translate('organization_information')) {
      return Icons.business;
    } else if (title == localizations.translate('about')) {
      return Icons.info_outline;
    } else {
      return Icons.article;
    }
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green.shade600, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        title: Text(
          localizations.translate('profile'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    userData: _userData,
                    profileData: _profileData,
                  ),
                ),
              ).then((result) {
                // Reload profile data if successfully updated
                if (result == true) {
                  _loadUserProfile();
                }
              });
            },
            tooltip: localizations.translate('edit'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUserProfile,
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(localizations.translate('logout')),
                  content: Text(localizations.translate('logout_confirm')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(localizations.translate('cancel')),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleLogout();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text(localizations.translate('logout')),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.translate('error_loading_profile'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(localizations.translate('try_again')),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile header with curved bottom and gradient
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.green.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          // ignore: duplicate_ignore
                                          // ignore: deprecated_member_use
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundImage: _profileImage != null
                                          ? FileImage(_profileImage!)
                                          : (_userData?['profileImage'] !=
                                                      null &&
                                                  _userData!['profileImage']
                                                      .toString()
                                                      .isNotEmpty)
                                              ? NetworkImage(
                                                      ApiConfig.getImageUrl(
                                                          _userData![
                                                              'profileImage']))
                                                  as ImageProvider
                                              : null,
                                      backgroundColor: Colors.white,
                                      child: (_profileImage == null &&
                                              (_userData?['profileImage'] ==
                                                      null ||
                                                  _userData!['profileImage']
                                                      .toString()
                                                      .isEmpty))
                                          ? Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.green.shade200,
                                            )
                                          : null,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.green.shade600,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _profileData?['donorname'] ??
                                  _profileData?['reciname'] ??
                                  'User',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _profileData?['orgName'] ??
                                  _profileData?['ngoName'] ??
                                  '',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                _userData?['type']?.toString().toUpperCase() ??
                                    'USER',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      
                      // Language change button
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.language),
                          label: Text(localizations.translate('change_language')),
                          onPressed: _showLanguageSelection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade100,
                            foregroundColor: Colors.green.shade800,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.green.shade300),
                            ),
                          ),
                        ),
                      ),

                      // Profile sections
                      _buildProfileSection(localizations.translate('personal_information'), [
                        _buildProfileItem(
                          Icons.person,
                          localizations.translate('full_name'),
                          _profileData?['donorname'] ??
                              _profileData?['reciname'] ??
                              'N/A',
                        ),
                        _buildProfileItem(
                          Icons.email,
                          localizations.translate('email_address'),
                          _userData?['email'] ?? 'N/A',
                        ),
                      ]),

                      _buildProfileSection(localizations.translate('contact_information'), [
                        _buildProfileItem(
                          Icons.phone,
                          localizations.translate('contact_number'),
                          _profileData?['donorcontact'] ??
                              _profileData?['recicontact'] ??
                              'N/A',
                        ),
                        _buildProfileItem(
                          Icons.location_on,
                          localizations.translate('address'),
                          _profileData?['donoraddress'] ??
                              _profileData?['reciaddress'] ??
                              'N/A',
                        ),
                      ]),

                      _buildProfileSection(localizations.translate('organization_information'), [
                        _buildProfileItem(
                          Icons.business,
                          localizations.translate('organization_name'),
                          _profileData?['orgName'] ??
                              _profileData?['ngoName'] ??
                              'N/A',
                        ),
                        _buildProfileItem(
                          Icons.badge,
                          localizations.translate('organization_id'),
                          _profileData?['identificationId'] ??
                              _profileData?['ngoId'] ??
                              'N/A',
                        ),
                      ]),

                      _buildProfileSection(localizations.translate('about'), [
                        _buildProfileItem(
                          Icons.info,
                          localizations.translate('description'),
                          _profileData?['donorabout'] ??
                              _profileData?['reciabout'] ??
                              localizations.translate('no_description'),
                        ),
                      ]),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}
