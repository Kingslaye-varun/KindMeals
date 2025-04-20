import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = ApiConfig.apiBaseUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper method to get auth headers

  // Helper method to get auth headers with token
  Future<Map<String, String>> get _authHeaders async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }
    final idToken = await user.getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };
  }

  // Auth Methods
  Future<void> registerUser(String role) async {
    // This method is now just a placeholder for backward compatibility
    // We'll directly register the user in their respective collection
    if (kDebugMode) {
      print(
          'Skipping generic user registration, will directly register in specific role collection');
    }
  }

  Future<void> deleteUser() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user'),
        headers: await _authHeaders,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete user: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user: $e');
      }
      rethrow;
    }
  }

  Future<bool> isUserDeleted() async {
    final user = _auth.currentUser;
    if (user == null) return true; // If no user, consider it deleted

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/check'),
        headers: await _authHeaders,
      );

      // If we get a 404, the user is deleted
      return response.statusCode == 404;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if user is deleted: $e');
      }
      return false; // If there's an error, assume user still exists
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      if (kDebugMode) {
        print('Fetching user profile for: ${user.uid}');
      }
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: await _authHeaders,
      );

      if (kDebugMode) {
        print('Profile response status: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('Profile response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch user profile: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user profile: $e');
      }
      rethrow;
    }
  }

  // Register directly to donor collection
  Future<void> registerDonor({
    required String donorname,
    required String orgName,
    required String identificationId,
    required String address,
    required String contact,
    required String type,
    String? about,
    double? latitude,
    double? longitude,
    File? profileImage,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      if (kDebugMode) {
        print('=== DEBUG: Starting Donor Registration ===');
      }
      if (kDebugMode) {
        print('Firebase UID: ${user.uid}');
      }
      if (kDebugMode) {
        print('Firebase Email: ${user.email}');
      }

      final idToken = await user.getIdToken();
      if (kDebugMode) {
        print('Token obtained, length: ${idToken?.length}');
      }

      // Create multipart request for sending form data with file
      final request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/donor/register'));

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $idToken';

      // Add text fields
      request.fields['firebaseUid'] = user.uid;
      request.fields['email'] = user.email ?? '';
      request.fields['donorname'] = donorname;
      request.fields['orgName'] = orgName;
      request.fields['identificationId'] = identificationId;
      request.fields['donoraddress'] = address;
      request.fields['donorcontact'] = contact;
      request.fields['type'] = type;
      if (about != null) request.fields['donorabout'] = about;
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();

      // Add profile image if provided
      if (profileImage != null) {
        if (kDebugMode) {
          print('Adding profile image to request: ${profileImage.path}');
        }
        final fileName = profileImage.path.split('/').last;
        final extension = fileName.split('.').last.toLowerCase();

        // Determine content type
        String contentType;
        if (extension == 'png') {
          contentType = 'image/png';
        } else {
          contentType = 'image/jpeg';
        }

        // Add file to request
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            profileImage.path,
            contentType: MediaType.parse(contentType),
          ),
        );
      } else {
        if (kDebugMode) {
          print('No profile image provided');
        }
      }

      // Send the request
      if (kDebugMode) {
        print(
            'Sending registration request with ${request.fields.length} fields and ${request.files.length} files');
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('Response status code: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('Response body: ${response.body}');
      }

      if (response.statusCode != 201) {
        throw Exception('Failed to register donor: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during donor registration: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDonorProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/donor/profile'),
      headers: await _authHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get donor profile: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<void> updateDonorProfile({
    String? name,
    String? orgName,
    String? address,
    String? contact,
    String? about,
    double? latitude,
    double? longitude,
    File? profileImage,
  }) async {
    if (profileImage == null) {
      // Use simple PUT request if no image is provided
      final response = await http.put(
        Uri.parse('$baseUrl/donor/profile'),
        headers: await _authHeaders,
        body: jsonEncode({
          if (name != null) 'donorname': name,
          if (orgName != null) 'orgName': orgName,
          if (address != null) 'donoraddress': address,
          if (contact != null) 'donorcontact': contact,
          if (about != null) 'donorabout': about,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update donor profile: ${response.body}');
      }
    } else {
      // Use direct API with image upload support
      await updateDirectDonorProfile(
        name: name,
        orgName: orgName,
        address: address,
        contact: contact,
        about: about,
        latitude: latitude,
        longitude: longitude,
        profileImage: profileImage,
      );
    }
  }

  // Register directly to recipient collection
  Future<void> registerRecipient({
    required String name,
    required String ngoName,
    required String ngoId,
    required String address,
    required String contact,
    required String type,
    String? about,
    double? latitude,
    double? longitude,
    File? profileImage,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      if (kDebugMode) {
        print('=== DEBUG: Starting Recipient Registration ===');
      }
      if (kDebugMode) {
        print('Firebase UID: ${user.uid}');
      }
      if (kDebugMode) {
        print('Firebase Email: ${user.email}');
      }

      final idToken = await user.getIdToken();
      if (kDebugMode) {
        print('Token obtained, length: ${idToken?.length}');
      }

      // Create multipart request for sending form data with file
      final request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/recipient/register'));

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $idToken';

      // Add text fields
      request.fields['firebaseUid'] = user.uid;
      request.fields['email'] = user.email ?? '';
      request.fields['reciname'] = name;
      request.fields['ngoName'] = ngoName;
      request.fields['ngoId'] = ngoId;
      request.fields['reciaddress'] = address;
      request.fields['recicontact'] = contact;
      request.fields['type'] = type;
      if (about != null) request.fields['reciabout'] = about;
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();

      // Add profile image if provided
      if (profileImage != null) {
        if (kDebugMode) {
          print('Adding profile image to request: ${profileImage.path}');
        }
        final fileName = profileImage.path.split('/').last;
        final extension = fileName.split('.').last.toLowerCase();

        // Determine content type
        String contentType;
        if (extension == 'png') {
          contentType = 'image/png';
        } else {
          contentType = 'image/jpeg';
        }

        // Add file to request
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            profileImage.path,
            contentType: MediaType.parse(contentType),
          ),
        );
      } else {
        if (kDebugMode) {
          print('No profile image provided');
        }
      }

      // Send the request
      if (kDebugMode) {
        print(
            'Sending registration request with ${request.fields.length} fields and ${request.files.length} files');
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('Response status code: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('Response body: ${response.body}');
      }

      if (response.statusCode != 201) {
        throw Exception('Failed to register recipient: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during recipient registration: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRecipientProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/recipient/profile'),
      headers: await _authHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get recipient profile: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<void> updateRecipientProfile({
    String? name,
    String? ngoName,
    String? address,
    String? contact,
    String? about,
    double? latitude,
    double? longitude,
    File? profileImage,
  }) async {
    if (profileImage == null) {
      // Use simple PUT request if no image is provided
      final response = await http.put(
        Uri.parse('$baseUrl/recipient/profile'),
        headers: await _authHeaders,
        body: jsonEncode({
          if (name != null) 'reciname': name,
          if (ngoName != null) 'ngoName': ngoName,
          if (address != null) 'reciaddress': address,
          if (contact != null) 'recicontact': contact,
          if (about != null) 'reciabout': about,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update recipient profile: ${response.body}');
      }
    } else {
      // Use direct API with image upload support
      await updateDirectRecipientProfile(
        name: name,
        ngoName: ngoName,
        address: address,
        contact: contact,
        about: about,
        latitude: latitude,
        longitude: longitude,
        profileImage: profileImage,
      );
    }
  }

  // Create a food donation
  Future<Map<String, dynamic>> createDonation({
    required String foodName,
    required int quantity,
    required String description,
    required DateTime expiryDateTime,
    required String foodType,
    required String address,
    required bool needsVolunteer,
    double? latitude,
    double? longitude,
    File? foodImage,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      final idToken = await user.getIdToken();

      // Define the URL endpoint
      final String url = '$baseUrl/donations/create';

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add auth header
      request.headers['Authorization'] = 'Bearer $idToken';

      // Add text fields
      request.fields['foodName'] = foodName;
      request.fields['quantity'] = quantity.toString();
      request.fields['description'] = description;
      request.fields['expiryDateTime'] = expiryDateTime.toIso8601String();
      request.fields['foodType'] = foodType;
      request.fields['address'] = address;
      request.fields['needsVolunteer'] = needsVolunteer.toString();
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();

      // Add food image if provided
      if (foodImage != null) {
        if (kDebugMode) {
          print('Adding food image to request: ${foodImage.path}');
        }
        final fileName = foodImage.path.split('/').last;
        final extension = fileName.split('.').last.toLowerCase();

        // Determine content type
        String contentType;
        if (extension == 'png') {
          contentType = 'image/png';
        } else {
          contentType = 'image/jpeg';
        }

        // Add file to request
        request.files.add(
          await http.MultipartFile.fromPath(
            'foodImage',
            foodImage.path,
            contentType: MediaType.parse(contentType),
          ),
        );
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print(
            'Donation creation response: ${response.statusCode} | ${response.body}');
      }

      if (response.statusCode != 201) {
        throw Exception('Failed to create donation: ${response.body}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating donation: $e');
      }
      rethrow;
    }
  }

  // Accept a donation
  Future<Map<String, dynamic>> acceptDonation({
    required String donationId,
    String? volunteerName,
    bool needsVolunteer = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      final idToken = await user.getIdToken();

      // Define the URL endpoint
      final String url = '$baseUrl/donations/accept/$donationId';

      // Create request body
      final Map<String, dynamic> requestBody = {
        'needsVolunteer': needsVolunteer,
      };

      if (volunteerName != null) {
        requestBody['volunteerName'] = volunteerName;
      }

      if (kDebugMode) {
        print(
            'DEBUG: Accepting donation with parameters: ${requestBody.toString()}');
      }

      // Send the request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(requestBody),
      );

      if (kDebugMode) {
        print(
            'Donation acceptance response: ${response.statusCode} | ${response.body}');
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to accept donation: ${response.body}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) {
        print('Error accepting donation: $e');
      }
      rethrow;
    }
  }

  // Add feedback to accepted donation
  Future<Map<String, dynamic>> addFeedback({
    required String acceptedDonationId,
    required String feedback,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/donations/feedback/$acceptedDonationId'),
        headers: await _authHeaders,
        body: jsonEncode({'feedback': feedback}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add feedback: ${response.body}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding feedback: $e');
      }
      rethrow;
    }
  }

  // Volunteer accept donation opportunity
  Future<Map<String, dynamic>> volunteerAcceptDonation({
    required String donationId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      final idToken = await user.getIdToken();

      // Define the URL endpoint
      final String url = '$baseUrl/volunteer/donations/accept/$donationId';

      // Send the request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (kDebugMode) {
        print(
            'Volunteer donation acceptance response: ${response.statusCode} | ${response.body}');
      }

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to accept donation as volunteer: ${response.body}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) {
        print('Error accepting donation as volunteer: $e');
      }
      rethrow;
    }
  }

  // Register volunteer
  Future<void> registerVolunteer({
    required String volunteerName,
    required String aadharID,
    required String address,
    required String contact,
    String? about,
    bool hasVehicle = false,
    String? vehicleType,
    String? vehicleNumber,
    double? latitude,
    double? longitude,
    File? profileImage,
    File? drivingLicenseImage,
    Map<String, dynamic>? vehicleDetails,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      final idToken = await user.getIdToken();

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/volunteer/register'),
      );

      // Add auth header
      request.headers['Authorization'] = 'Bearer $idToken';

      // Add text fields
      request.fields['firebaseUid'] = user.uid;
      request.fields['email'] = user.email ?? '';
      request.fields['volunteerName'] = volunteerName;
      request.fields['aadharID'] = aadharID;
      request.fields['volunteeraddress'] = address;
      request.fields['volunteercontact'] = contact;
      if (about != null) request.fields['volunteerabout'] = about;
      request.fields['hasVehicle'] = hasVehicle.toString();

      if (hasVehicle) {
        if (vehicleType != null) request.fields['vehicleType'] = vehicleType;
        if (vehicleNumber != null) {
          request.fields['vehicleNumber'] = vehicleNumber;
        }
      }

      // Handle vehicle details from the map if provided
      if (vehicleDetails != null) {
        if (vehicleDetails['vehicleType'] != null) {
          request.fields['vehicleType'] = vehicleDetails['vehicleType'];
        }
        if (vehicleDetails['vehicleNumber'] != null) {
          request.fields['vehicleNumber'] = vehicleDetails['vehicleNumber'];
        }
        if (vehicleDetails['drivingLicenseImage'] != null &&
            vehicleDetails['drivingLicenseImage'] is File) {
          drivingLicenseImage = vehicleDetails['drivingLicenseImage'];
        }
      }

      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();

      // Add profile image if provided
      if (profileImage != null) {
        final fileName = profileImage.path.split('/').last;
        final extension = fileName.split('.').last.toLowerCase();

        String contentType;
        if (extension == 'png') {
          contentType = 'image/png';
        } else {
          contentType = 'image/jpeg';
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            profileImage.path,
            contentType: MediaType.parse(contentType),
          ),
        );
      }

      // Add driving license image if provided
      if (drivingLicenseImage != null && hasVehicle) {
        final fileName = drivingLicenseImage.path.split('/').last;
        final extension = fileName.split('.').last.toLowerCase();

        String contentType;
        if (extension == 'png') {
          contentType = 'image/png';
        } else {
          contentType = 'image/jpeg';
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'drivingLicenseImage',
            drivingLicenseImage.path,
            contentType: MediaType.parse(contentType),
          ),
        );
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201) {
        throw Exception('Failed to register volunteer: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in registerVolunteer: $e');
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getVolunteerOpportunities() async {
    try {
      if (kDebugMode) {
        print('DEBUG: Fetching volunteer opportunities...');
      }
      final response = await http.get(
        Uri.parse('$baseUrl/volunteer/opportunities'),
        headers: await _authHeaders,
      );

      if (kDebugMode) {
        print(
            'DEBUG: Volunteer opportunities response status: ${response.statusCode}');
      }
      if (response.statusCode != 200) {
        if (kDebugMode) {
          print(
              'DEBUG ERROR: Failed to get volunteer opportunities. Status: ${response.statusCode}, Body: ${response.body}');
        }
        throw Exception(
            'Failed to get volunteer opportunities: ${response.body}');
      }

      final List<dynamic> data = jsonDecode(response.body);
      if (kDebugMode) {
        print('DEBUG: Fetched ${data.length} volunteer opportunities');
      }
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG ERROR: Exception in getVolunteerOpportunities: $e');
      }
      rethrow;
    }
  }

  // Get accepted donations that need volunteer delivery
  Future<List<Map<String, dynamic>>> getAcceptedDonationsForVolunteer() async {
    try {
      if (kDebugMode) {
        print('====================================');
        print(
            'DEBUG: Fetching accepted donations that need volunteer delivery...');
        print('====================================');
      }

      // Create authenticated headers with fresh token for this request
      final user = _auth.currentUser;
      if (user == null) {
        if (kDebugMode) {
          print('DEBUG: No authenticated user found');
        }
        return [];
      }

      await user.reload();
      final String? idToken = await user.getIdToken(true);
      if (idToken == null) {
        if (kDebugMode) {
          print('DEBUG: Failed to get ID token');
        }
        return [];
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      };

      if (kDebugMode) {
        print('DEBUG: Volunteer UID: ${user.uid}');
        print('DEBUG: Volunteer email: ${user.email}');
      }

      // First, try the debug endpoint with NO authentication (debugging only)
      if (kDebugMode) {
        print('====================================');
        print('DEBUG: First checking the server health...');
        print('====================================');

        try {
          final healthUrl = '${ApiConfig.serverBaseUrl}/api/health';
          if (kDebugMode) {
            print('DEBUG: Health check URL: $healthUrl');
          }

          final healthResponse = await http.get(
            Uri.parse(healthUrl),
          );

          if (kDebugMode) {
            print('DEBUG: Health response: ${healthResponse.statusCode}');
            print('DEBUG: Health body: ${healthResponse.body}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('DEBUG: Health check failed: $e');
          }
        }
      }

      // Try the debug endpoint without authentication
      if (kDebugMode) {
        print('====================================');
        print('DEBUG: Trying debug endpoint without auth...');
        print('====================================');
      }

      try {
        final debugUrl = '${ApiConfig.serverBaseUrl}/debug/volunteer/pending';
        if (kDebugMode) {
          print('DEBUG: Debug URL: $debugUrl');
        }

        final debugResponse = await http.get(
          Uri.parse(debugUrl),
        );

        if (kDebugMode) {
          print('DEBUG: Debug endpoint response: ${debugResponse.statusCode}');
          if (debugResponse.statusCode == 200) {
            final data = jsonDecode(debugResponse.body);
            print('DEBUG: Debug endpoint count: ${data['count']}');
            if (data['count'] > 0) {
              print('DEBUG: Sample debug data: ${data['data'][0]}');
            }
          } else {
            print('DEBUG: Debug response body: ${debugResponse.body}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('DEBUG: Debug endpoint failed: $e');
        }
      }

      // Now try the main endpoint with authentication
      if (kDebugMode) {
        print('====================================');
        print('DEBUG: Trying main endpoint with auth...');
        print('====================================');
      }

      try {
        // Try the 3 different possible URLs based on patterns
        final urls = [
          '$baseUrl/volunteer/donations/pending',
          '${ApiConfig.serverBaseUrl}/api/volunteer/donations/pending',
          '$baseUrl/pending-volunteer-deliveries'
        ];

        for (final url in urls) {
          if (kDebugMode) {
            print('====================================');
            print('DEBUG: Trying URL: $url');
            print('====================================');
          }

          try {
            final response = await http.get(
              Uri.parse(url),
              headers: headers,
            );

            if (kDebugMode) {
              print('DEBUG: Response status: ${response.statusCode}');
              if (response.statusCode != 200) {
                print('DEBUG: Response body: ${response.body}');
              }
            }

            if (response.statusCode == 200) {
              final List<dynamic> data = jsonDecode(response.body);
              if (kDebugMode) {
                print('DEBUG: Fetched ${data.length} pending deliveries');
                if (data.isNotEmpty) {
                  print('DEBUG: Sample data: ${data[0]}');
                }
              }
              return data.cast<Map<String, dynamic>>();
            }
          } catch (e) {
            if (kDebugMode) {
              print('DEBUG: Error with URL $url: $e');
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('DEBUG: Error with main endpoint approach: $e');
        }
      }

      // Fallback to empty list with correct structure
      if (kDebugMode) {
        print('====================================');
        print('DEBUG: All attempts failed, returning empty list');
        print('====================================');
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG ERROR: Exception in getAcceptedDonationsForVolunteer: $e');
      }
      // Return empty list as fallback to prevent app crashes
      return [];
    }
  }

  // Updated method to accept an accepted donation for delivery
  Future<Map<String, dynamic>> volunteerAcceptDelivery({
    required String acceptedDonationId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user found');

    try {
      final idToken = await user.getIdToken();

      // Define the URL endpoint
      final String url =
          '$baseUrl/volunteer/accept-delivery/$acceptedDonationId';

      // Send the request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (kDebugMode) {
        print(
            'Volunteer delivery acceptance response: ${response.statusCode} | ${response.body}');
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to accept delivery: ${response.body}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) {
        print('Error accepting delivery as volunteer: $e');
      }
      rethrow;
    }
  }

  // Get volunteer donation history - shows donations they've delivered
  Future<List<Map<String, dynamic>>> getVolunteerDonationHistory() async {
    try {
      if (kDebugMode) {
        print('DEBUG: Fetching volunteer donation history...');
      }

      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (kDebugMode) {
          print('DEBUG: No authenticated user found');
        }
        throw Exception('No authenticated user found');
      }

      // Get fresh token
      await currentUser.reload();
      final String? idToken = await currentUser.getIdToken(true);
      if (idToken == null) {
        throw Exception('Authentication error: Failed to get ID token');
      }

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      };

      // Make the API call to get volunteer's accepted donations
      final response = await http.get(
        Uri.parse('$baseUrl/volunteer/donations/history'),
        headers: headers,
      );

      if (kDebugMode) {
        print(
            'DEBUG: Volunteer history response status: ${response.statusCode}');
      }

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print(
              'DEBUG ERROR: Failed to get volunteer history. Status: ${response.statusCode}, Body: ${response.body}');
        }
        throw Exception('Failed to get volunteer history: ${response.body}');
      }

      final List<dynamic> data = jsonDecode(response.body);
      if (kDebugMode) {
        print(
            'DEBUG: Fetched ${data.length} volunteer delivery history records');
      }
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('DEBUG ERROR: Exception in getVolunteerDonationHistory: $e');
      }

      // Return empty list for now as the endpoint might not be implemented yet
      if (kDebugMode) {
        print('DEBUG: Returning empty list as fallback');
      }
      return [];
    }
  }

  // Recipient donation history
  Future<List<Map<String, dynamic>>> getRecipientDonations() async {
    try {
      if (kDebugMode) {
        print('Fetching recipient donations history...');
      }
      final response = await http.get(
        Uri.parse('$baseUrl/recipient/donations'),
        headers: await _authHeaders,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get recipient donations: ${response.body}');
      }

      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching recipient donations: $e');
      }
      rethrow;
    }
  }

  // Donor donation history
  Future<Map<String, dynamic>> getDonorDonations() async {
    try {
      if (kDebugMode) {
        print('Fetching donor donations history...');
      }
      final url = Uri.parse('$baseUrl/donor/donations');

      final response = await http.get(
        url,
        headers: await _authHeaders,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get donor donations: ${response.body}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching donor donations: $e');
      }
      rethrow;
    }
  }

  // Get user profile - common API for all user types
  Future<Map<String, dynamic>> getDirectUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      if (kDebugMode) {
        print('Fetching direct user profile for: ${user.uid}');
      }
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: await _authHeaders,
      );

      if (kDebugMode) {
        print('Profile response status: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('Profile response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch user profile: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching direct user profile: $e');
      }
      rethrow;
    }
  }

  // Update donor profile
  Future<Map<String, dynamic>> updateDirectDonorProfile({
    String? name,
    String? orgName,
    String? address,
    String? contact,
    String? about,
    double? latitude,
    double? longitude,
    File? profileImage,
  }) async {
    try {
      final idToken = await _auth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('Not authenticated');
      }

      final String url = '$baseUrl/donor/profile';
      final request = http.MultipartRequest('PUT', Uri.parse(url));

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $idToken';

      // Add text fields if provided
      if (name != null) request.fields['donorname'] = name;
      if (orgName != null) request.fields['orgName'] = orgName;
      if (address != null) request.fields['donoraddress'] = address;
      if (contact != null) request.fields['donorcontact'] = contact;
      if (about != null) request.fields['donorabout'] = about;
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();

      // Add profile image if provided
      if (profileImage != null) {
        final fileName = profileImage.path.split('/').last;
        final extension = fileName.split('.').last.toLowerCase();

        String contentType;
        if (extension == 'png') {
          contentType = 'image/png';
        } else {
          contentType = 'image/jpeg';
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            profileImage.path,
            contentType: MediaType.parse(contentType),
          ),
        );
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('Failed to update donor profile: ${response.body}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating donor profile: $e');
      }
      rethrow;
    }
  }

  // Update recipient profile
  Future<Map<String, dynamic>> updateDirectRecipientProfile({
    String? name,
    String? ngoName,
    String? ngoId,
    String? address,
    String? contact,
    String? about,
    double? latitude,
    double? longitude,
    File? profileImage,
  }) async {
    try {
      final idToken = await _auth.currentUser?.getIdToken();
      if (idToken == null) {
        throw Exception('Not authenticated');
      }

      final String url = '$baseUrl/recipient/profile';
      final request = http.MultipartRequest('PUT', Uri.parse(url));

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $idToken';

      // Add text fields if provided
      if (name != null) request.fields['reciname'] = name;
      if (ngoName != null) request.fields['ngoName'] = ngoName;
      if (ngoId != null) request.fields['ngoId'] = ngoId;
      if (address != null) request.fields['reciaddress'] = address;
      if (contact != null) request.fields['recicontact'] = contact;
      if (about != null) request.fields['reciabout'] = about;
      if (latitude != null) request.fields['latitude'] = latitude.toString();
      if (longitude != null) request.fields['longitude'] = longitude.toString();

      // Add profile image if provided
      if (profileImage != null) {
        final fileName = profileImage.path.split('/').last;
        final extension = fileName.split('.').last.toLowerCase();

        String contentType;
        if (extension == 'png') {
          contentType = 'image/png';
        } else {
          contentType = 'image/jpeg';
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            profileImage.path,
            contentType: MediaType.parse(contentType),
          ),
        );
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('Failed to update recipient profile: ${response.body}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating recipient profile: $e');
      }
      rethrow;
    }
  }

  // Helper method to process images before upload (resize and compress)
  // This is a simplified version without additional dependencies

  // Generic user profile update for volunteer or other types
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? about,
    File? profileImage,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      // Get user type first
      final profile = await getDirectUserProfile();
      final userType = profile['userType']?.toString().toLowerCase() ?? '';

      if (userType.contains('donor')) {
        await updateDonorProfile(
          name: name,
          contact: phone,
          address: address,
          about: about,
          profileImage: profileImage,
        );
      } else if (userType.contains('recipient')) {
        await updateRecipientProfile(
          name: name,
          contact: phone,
          address: address,
          about: about,
          profileImage: profileImage,
        );
      } else {
        // For volunteers or other user types
        // Implement volunteer profile update when volunteer API is available
        throw Exception('Profile update not supported for this user type yet');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      rethrow;
    }
  }

  // Helper method to check API connectivity
  Future<bool> checkApiConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      if (kDebugMode) {
        print(
            'API health check response: ${response.statusCode} - ${response.body}');
      }
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('API connection failed: $e');
      }
      return false;
    }
  }

  // Get all live donations
  Future<List<Map<String, dynamic>>> getLiveDonations() async {
    try {
      if (kDebugMode) {
        print('Fetching live donations...');
      }
      final response = await http.get(
        Uri.parse('$baseUrl/donations/live'),
        headers: await _authHeaders,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get live donations: ${response.body}');
      }

      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching live donations: $e');
      }
      rethrow;
    }
  }

  // Get user's donations
  Future<List<Map<String, dynamic>>> getUserDonations() async {
    try {
      if (kDebugMode) {
        print('Fetching user donations...');
      }
      final response = await http.get(
        Uri.parse('$baseUrl/donations/user'),
        headers: await _authHeaders,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to get user donations: ${response.body}');
      }

      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user donations: $e');
      }
      rethrow;
    }
  }
}
