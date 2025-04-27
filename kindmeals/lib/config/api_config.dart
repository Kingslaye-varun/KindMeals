import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // API base URL - use environment variable
  static String get serverBaseUrl =>
      dotenv.env['API_URL'] ??
      'http://192.168.0.101:5000';
  static String get apiBaseUrl => '$serverBaseUrl/api';

  // Debug information
  static void printAPIConfig() {
    if (kDebugMode) {
      print('====== API Configuration ======');
    }
    if (kDebugMode) {
      print('Server Base URL: $serverBaseUrl');
    }
    if (kDebugMode) {
      print('API Base URL: $apiBaseUrl');
    }
    if (kDebugMode) {
      print('==============================');
    }
  }

  // Method to get full image URL
  static String getImageUrl(String? imagePath) {
    // If the path is empty or null, return empty string
    if (imagePath == null || imagePath.isEmpty) return '';

    // If the path already contains the full URL, return it as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      if (kDebugMode) {
        print('Using direct URL: $imagePath');
      }
      return imagePath;
    }

    // For image paths starting with /uploads, construct URL properly
    if (imagePath.startsWith('/uploads/')) {
      if (kDebugMode) {
        print('Using upload path: $imagePath');
      }
      return serverBaseUrl + imagePath;
    }

    // For any other case, assume it's a relative path and append to server base URL
    return serverBaseUrl + (imagePath.startsWith('/') ? '' : '/') + imagePath;
  }
}
