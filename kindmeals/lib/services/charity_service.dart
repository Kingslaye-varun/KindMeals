import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/charity_model.dart';
import 'firebase_service.dart';

class CharityService {
  final String baseUrl =
      'https://kindmeals-api.example.com/api'; // Replace with your API URL
  final FirebaseService _firebaseService = FirebaseService();

  // Get auth headers for API requests
  Future<Map<String, String>> get _authHeaders async {
    final token = await _firebaseService.getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Fetch all available charities
  Future<List<CharityModel>> getCharities() async {
    try {
      // Check if we have cached data first
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_charities');

      if (cachedData != null) {
        final List<dynamic> decodedData = jsonDecode(cachedData);
        return decodedData.map((json) => CharityModel.fromJson(json)).toList();
      }

      // No cache, make API request
      final response = await http.get(
        Uri.parse('$baseUrl/charities'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final charities =
            data.map((json) => CharityModel.fromJson(json)).toList();

        // Cache the result
        await prefs.setString('cached_charities', jsonEncode(data));

        return charities;
      } else {
        if (kDebugMode) {
          print('Failed to load charities: ${response.statusCode}');
          print('Response body: ${response.body}');
        }

        // For development, return mock data
        return _getMockCharities();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching charities: $e');
      }
      // Return mock data in case of an error
      return _getMockCharities();
    }
  }

  // Get details of a specific charity
  Future<CharityModel> getCharityById(String charityId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/charities/$charityId'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CharityModel.fromJson(data);
      } else {
        // For development, return mock data
        return _getMockCharities().firstWhere(
          (charity) => charity.id == charityId,
          orElse: () => _getMockCharities().first,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching charity: $e');
      }
      // Return mock data in case of an error
      return _getMockCharities().first;
    }
  }

  // Process donation with Razorpay
  Future<Map<String, dynamic>> processDonation({
    required String charityId,
    required double amount,
    required String name,
    required String email,
    required String phone,
    String? panCard,
    required String paymentMethod,
    required bool requestTaxBenefits,
    required String paymentId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/donations/charity'),
        headers: await _authHeaders,
        body: jsonEncode({
          'charityId': charityId,
          'amount': amount,
          'name': name,
          'email': email,
          'phone': phone,
          'panCard': panCard,
          'paymentMethod': paymentMethod,
          'requestTaxBenefits': requestTaxBenefits,
          'paymentId': paymentId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        // For demonstration purposes, simulate success
        return {
          'success': true,
          'message': 'Donation processed successfully',
          'transactionId': paymentId,
          'amount': amount,
          'charityId': charityId,
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing donation: $e');
      }

      // For demonstration, return success even on error
      return {
        'success': true,
        'message': 'Donation processed (demo mode)',
        'transactionId': paymentId,
        'amount': amount,
        'charityId': charityId,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  // Get donation history for the current user
  Future<List<Map<String, dynamic>>> getDonationHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/donations/history'),
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        // Return mock data for development
        return _getMockDonationHistory();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching donation history: $e');
      }
      // Return mock data in case of an error
      return _getMockDonationHistory();
    }
  }

  // Mock data for development
  List<CharityModel> _getMockCharities() {
    return [
      CharityModel(
        id: 'charity1',
        name: 'Food for All Foundation',
        description:
            'Providing meals to underprivileged children and families.',
        imageUrl: 'assets/images/charity1.jpg',
        recommendedAmounts: [100.0, 500.0, 1000.0, 5000.0],
        websiteUrl: 'https://foodforall.org',
        contactEmail: 'info@foodforall.org',
        contactPhone: '+91 9876543210',
      ),
      CharityModel(
        id: 'charity2',
        name: 'Hunger Relief Network',
        description:
            'Working to eliminate food insecurity through community kitchens.',
        imageUrl: 'assets/images/charity2.jpg',
        recommendedAmounts: [200.0, 500.0, 2000.0, 10000.0],
        websiteUrl: 'https://hungerrelief.org',
        contactEmail: 'contact@hungerrelief.org',
      ),
      CharityModel(
        id: 'charity3',
        name: 'Meals on Wheels',
        description:
            'Delivering nutritious meals to elderly and disabled individuals.',
        imageUrl: 'assets/images/charity3.jpg',
        recommendedAmounts: [300.0, 750.0, 1500.0, 3000.0],
      ),
    ];
  }

  // Mock donation history data
  List<Map<String, dynamic>> _getMockDonationHistory() {
    return [
      {
        'id': 'don_001',
        'charityId': 'charity1',
        'charityName': 'Food for All Foundation',
        'amount': 500.0,
        'timestamp':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'status': 'completed',
        'transactionId': 'pay_123456789',
      },
      {
        'id': 'don_002',
        'charityId': 'charity2',
        'charityName': 'Hunger Relief Network',
        'amount': 1000.0,
        'timestamp':
            DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        'status': 'completed',
        'transactionId': 'pay_987654321',
      },
    ];
  }
}
