import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // API base URL - use environment variable
  static String get serverBaseUrl =>
      dotenv.env['API_URL'] ?? 'http://192.168.1.27:5000';
  static String get apiBaseUrl => '$serverBaseUrl/api';

  // Debug information
  static void printAPIConfig() {
    print('====== API Configuration ======');
    print('Server Base URL: $serverBaseUrl');
    print('API Base URL: $apiBaseUrl');
    print('==============================');
  }

  // Method to get full image URL
  static String getImageUrl(String? imagePath) {
    // If the path is empty or null, return empty string
    if (imagePath == null || imagePath.isEmpty) return '';

    // If the path already contains the full URL, return it as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // For image paths starting with /uploads, add the server base URL
    if (imagePath.startsWith('/uploads/')) {
      // Use direct URL to handle server configuration with static files
      final url = serverBaseUrl + imagePath;
      print('Constructed image URL: $url');
      return url;
    }

    // For any other case, assume it's a relative path and append to server base URL
    return serverBaseUrl + (imagePath.startsWith('/') ? '' : '/') + imagePath;
  }
}
