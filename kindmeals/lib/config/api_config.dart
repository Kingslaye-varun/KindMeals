class ApiConfig {
  // API base URL - use localhost for emulator or your actual server IP
  // Note: For Android emulator, use 10.0.2.2 instead of localhost
  // For iOS simulator, use localhost
  // For physical devices, use your actual server IP address
  static const String serverBaseUrl = 'http://192.168.168.180:5000';
  static const String apiBaseUrl = '$serverBaseUrl/api';

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

    // If the path starts with /uploads, add the server base URL
    if (imagePath.startsWith('/uploads/')) {
      return serverBaseUrl + imagePath;
    }

    // For any other case, assume it's a relative path and append to server base URL
    return serverBaseUrl + (imagePath.startsWith('/') ? '' : '/') + imagePath;
  }
}
