// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:kindmeals/services/api_service.dart';
// import 'package:kindmeals/config/api_config.dart';
// import 'package:kindmeals/services/firebase_service.dart';
// import 'edit_profile_screen.dart';
// import 'donor_history_screen.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   File? _profileImage;
//   bool _isLoading = true;
//   bool _hasError = false;
//   String _errorMessage = '';
//   Map<String, dynamic>? _userData;
//   Map<String, dynamic>? _profileData;
//   final ApiService _apiService = ApiService();
//   final FirebaseService _firebaseService = FirebaseService();

//   @override
//   void initState() {
//     super.initState();
//     _loadUserProfile();
//   }

//   Future<void> _loadUserProfile() async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//     });

//     try {
//       // Try the new direct API first
//       try {
//         final directProfileData = await _apiService.getDirectUserProfile();
//         print('=== DEBUG: Direct Profile Data ===');
//         print('Full direct profile data: $directProfileData');
//         print('User Type: ${directProfileData['userType']}');
//         print('Profile section: ${directProfileData['profile']}');

//         setState(() {
//           _userData = {
//             'email': directProfileData['profile']['email'],
//             'profileImage': directProfileData['profile']['profileImage'],
//             'type': directProfileData['userType'],
//           };
//           _profileData = directProfileData['profile'];
//           _isLoading = false;
//         });
//         return;
//       } catch (directError) {
//         print(
//             'Error loading profile with direct API, falling back: $directError');
//         // Fall back to the old API
//       }

//       // Legacy API as fallback
//       final profileData = await _apiService.getUserProfile();
//       setState(() {
//         _userData = profileData['user'];
//         _profileData = profileData['profile'];
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _hasError = true;
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//       print('Error loading profile: $e');
//     }
//   }

//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         _profileImage = File(image.path);
//       });

//       try {
//         // Determine if user is donor or recipient
//         final userType = _userData?['type']?.toString().toLowerCase();

//         if (userType == 'donor') {
//           await _apiService.updateDirectDonorProfile(
//               profileImage: _profileImage);
//         } else if (userType == 'recipient') {
//           await _apiService.updateDirectRecipientProfile(
//               profileImage: _profileImage);
//         } else {
//           throw Exception('Unknown user type');
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Profile image updated successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );

//         _loadUserProfile(); // Reload profile to get updated image URL
//       } catch (e) {
//         print('Error uploading profile image: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to upload profile image: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _handleLogout() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await _firebaseService.signOut();
//       if (mounted) {
//         Navigator.pushNamedAndRemoveUntil(
//           context,
//           '/',
//           (route) => false,
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Logout failed: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Widget _buildProfileSection(String title, List<Widget> children) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
//           child: Text(
//             title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.green,
//             ),
//           ),
//         ),
//         Card(
//           margin: const EdgeInsets.symmetric(horizontal: 16),
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: children,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildProfileItem(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.grey),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Profile'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => EditProfileScreen(
//                     userData: _userData,
//                     profileData: _profileData,
//                   ),
//                 ),
//               ).then((result) {
//                 // Reload profile data if successfully updated
//                 if (result == true) {
//                   _loadUserProfile();
//                 }
//               });
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadUserProfile,
//           ),
//           IconButton(
//             icon: const Icon(Icons.exit_to_app),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: const Text('Log Out'),
//                   content: const Text('Are you sure you want to log out?'),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text('Cancel'),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         _handleLogout();
//                       },
//                       child: const Text('Log Out'),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _hasError
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(
//                         Icons.error_outline,
//                         color: Colors.red,
//                         size: 60,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Error loading profile',
//                         style: Theme.of(context).textTheme.titleLarge,
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         _errorMessage,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: _loadUserProfile,
//                         child: const Text('Try Again'),
//                       ),
//                     ],
//                   ),
//                 )
//               : SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Profile header with image
//                       Center(
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             children: [
//                               GestureDetector(
//                                 onTap: _pickImage,
//                                 child: Stack(
//                                   children: [
//                                     CircleAvatar(
//                                       radius: 60,
//                                       backgroundImage: _profileImage != null
//                                           ? FileImage(_profileImage!)
//                                           : (_userData?['profileImage'] !=
//                                                       null &&
//                                                   _userData!['profileImage']
//                                                       .toString()
//                                                       .isNotEmpty)
//                                               ? NetworkImage(
//                                                       ApiConfig.getImageUrl(
//                                                           _userData![
//                                                               'profileImage']))
//                                                   as ImageProvider
//                                               : null,
//                                       backgroundColor: Colors.grey[200],
//                                       child: (_profileImage == null &&
//                                               (_userData?['profileImage'] ==
//                                                       null ||
//                                                   _userData!['profileImage']
//                                                       .toString()
//                                                       .isEmpty))
//                                           ? const Icon(
//                                               Icons.person,
//                                               size: 60,
//                                               color: Colors.grey,
//                                             )
//                                           : null,
//                                     ),
//                                     Positioned(
//                                       bottom: 0,
//                                       right: 0,
//                                       child: Container(
//                                         padding: const EdgeInsets.all(4),
//                                         decoration: const BoxDecoration(
//                                           color: Colors.green,
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: const Icon(
//                                           Icons.camera_alt,
//                                           color: Colors.white,
//                                           size: 18,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(height: 16),
//                               Text(
//                                 _profileData?['donorname'] ??
//                                     _profileData?['reciname'] ??
//                                     'User',
//                                 style: const TextStyle(
//                                     fontSize: 24, fontWeight: FontWeight.bold),
//                               ),
//                               const SizedBox(height: 5),
//                               Text(
//                                 _profileData?['orgName'] ??
//                                     _profileData?['ngoName'] ??
//                                     '',
//                                 style: const TextStyle(
//                                     fontSize: 16, color: Colors.grey),
//                               ),
//                               const SizedBox(height: 5),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 12, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: Colors.green,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Text(
//                                   _userData?['type']
//                                           ?.toString()
//                                           .toUpperCase() ??
//                                       'USER',
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                       // Profile sections
//                       _buildProfileSection('Personal Information', [
//                         _buildProfileItem(
//                           Icons.person,
//                           'Name',
//                           _profileData?['donorname'] ??
//                               _profileData?['reciname'] ??
//                               'N/A',
//                         ),
//                         _buildProfileItem(
//                           Icons.email,
//                           'Email',
//                           _userData?['email'] ?? 'N/A',
//                         ),
//                       ]),

//                       _buildProfileSection('Contact Information', [
//                         _buildProfileItem(
//                           Icons.phone,
//                           'Contact',
//                           _profileData?['donorcontact'] ??
//                               _profileData?['recicontact'] ??
//                               'N/A',
//                         ),
//                         _buildProfileItem(
//                           Icons.location_on,
//                           'Address',
//                           _profileData?['donoraddress'] ??
//                               _profileData?['reciaddress'] ??
//                               'N/A',
//                         ),
//                       ]),

//                       _buildProfileSection('Organization Information', [
//                         _buildProfileItem(
//                           Icons.business,
//                           'Organization Name',
//                           _profileData?['orgName'] ??
//                               _profileData?['ngoName'] ??
//                               'N/A',
//                         ),
//                         _buildProfileItem(
//                           Icons.badge,
//                           'ID',
//                           _profileData?['identificationId'] ??
//                               _profileData?['ngoId'] ??
//                               'N/A',
//                         ),
//                       ]),

//                       _buildProfileSection('About', [
//                         _buildProfileItem(
//                           Icons.info,
//                           'Description',
//                           _profileData?['donorabout'] ??
//                               _profileData?['reciabout'] ??
//                               'No description available',
//                         ),
//                       ]),

//                       // Donation History Button (Only for Donors)
//                       if (_userData?['type']?.toString().toLowerCase() ==
//                           'donor')
//                         Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: ElevatedButton.icon(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       const DonorHistoryScreen(),
//                                 ),
//                               );
//                             },
//                             icon: const Icon(Icons.history),
//                             label: const Text('View Donation History'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.green,
//                               foregroundColor: Colors.white,
//                               minimumSize: const Size(double.infinity, 50),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               elevation: 2,
//                             ),
//                           ),
//                         ),

//                       const SizedBox(height: 24),
//                     ],
//                   ),
//                 ),
//     );
//   }
// }


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:kindmeals/services/api_service.dart';
import 'package:kindmeals/config/api_config.dart';
import 'package:kindmeals/services/firebase_service.dart';
import 'edit_profile_screen.dart';
import 'donor_history_screen.dart';

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
          const SnackBar(
            content: Text('Profile image updated successfully'),
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
            content: Text('Failed to upload profile image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
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
    switch (title) {
      case 'Personal Information':
        return Icons.person;
      case 'Contact Information':
        return Icons.contact_phone;
      case 'Organization Information':
        return Icons.business;
      case 'About':
        return Icons.info_outline;
      default:
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        title: const Text(
          'Profile',
          style: TextStyle(
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
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleLogout();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Log Out'),
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
                        'Error loading profile',
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
                        child: const Text('Try Again'),
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
                                          : (_userData?['profileImage'] != null &&
                                                  _userData!['profileImage']
                                                      .toString()
                                                      .isNotEmpty)
                                              ? NetworkImage(ApiConfig.getImageUrl(
                                                  _userData!['profileImage']))
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
                                            color: Colors.black.withOpacity(0.2),
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

                      // Profile sections
                      _buildProfileSection('Personal Information', [
                        _buildProfileItem(
                          Icons.person,
                          'Full Name',
                          _profileData?['donorname'] ??
                              _profileData?['reciname'] ??
                              'N/A',
                        ),
                        _buildProfileItem(
                          Icons.email,
                          'Email Address',
                          _userData?['email'] ?? 'N/A',
                        ),
                      ]),

                      _buildProfileSection('Contact Information', [
                        _buildProfileItem(
                          Icons.phone,
                          'Contact Number',
                          _profileData?['donorcontact'] ??
                              _profileData?['recicontact'] ??
                              'N/A',
                        ),
                        _buildProfileItem(
                          Icons.location_on,
                          'Address',
                          _profileData?['donoraddress'] ??
                              _profileData?['reciaddress'] ??
                              'N/A',
                        ),
                      ]),

                      _buildProfileSection('Organization Information', [
                        _buildProfileItem(
                          Icons.business,
                          'Organization Name',
                          _profileData?['orgName'] ??
                              _profileData?['ngoName'] ??
                              'N/A',
                        ),
                        _buildProfileItem(
                          Icons.badge,
                          'Organization ID',
                          _profileData?['identificationId'] ??
                              _profileData?['ngoId'] ??
                              'N/A',
                        ),
                      ]),

                      _buildProfileSection('About', [
                        _buildProfileItem(
                          Icons.info,
                          'Description',
                          _profileData?['donorabout'] ??
                              _profileData?['reciabout'] ??
                              'No description available',
                        ),
                      ]),

                      // Donation History Button (Only for Donors)
                      if (_userData?['type']?.toString().toLowerCase() ==
                          'donor')
                        Container(
                          margin: const EdgeInsets.all(16.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DonorHistoryScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.history),
                            label: const Text('View Donation History'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                              shadowColor: Colors.green.withOpacity(0.5),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}