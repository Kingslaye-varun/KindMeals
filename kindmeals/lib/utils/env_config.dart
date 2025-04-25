import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A utility class for accessing environment variables throughout the app.
class EnvConfig {
  // Private constructor to prevent instantiation
  EnvConfig._();

  /// Get Razorpay Key ID
  static String getRazorpayKeyId() {
    return dotenv.env['RAZORPAY_KEY_ID'] ?? '';
  }

  /// Get Razorpay Key Secret
  static String getRazorpayKeySecret() {
    return dotenv.env['RAZORPAY_KEY_SECRET'] ?? '';
  }

  /// Get Firebase API Key
  static String getFirebaseApiKey() {
    return dotenv.env['FIREBASE_API_KEY'] ?? '';
  }

  /// Get Firebase Auth Domain
  static String getFirebaseAuthDomain() {
    return dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  }

  /// Get Firebase Project ID
  static String getFirebaseProjectId() {
    return dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  }

  /// Get Firebase Storage Bucket
  static String getFirebaseStorageBucket() {
    return dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  }

  /// Get Firebase Messaging Sender ID
  static String getFirebaseMessagingSenderId() {
    return dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  }

  /// Get Firebase App ID
  static String getFirebaseAppId() {
    return dotenv.env['FIREBASE_APP_ID'] ?? '';
  }

  /// Get API URL
  static String getApiUrl() {
    return dotenv.env['API_URL'] ?? '';
  }

  /// Check if all required environment variables are set
  static bool validateEnvironment() {
    final requiredVariables = [
      'RAZORPAY_KEY_ID',
      'FIREBASE_API_KEY',
      'FIREBASE_PROJECT_ID',
    ];

    for (final variable in requiredVariables) {
      if (dotenv.env[variable]?.isEmpty ?? true) {
        if (kDebugMode) {
          print('WARNING: Required environment variable $variable is not set!');
        }
        return false;
      }
    }

    return true;
  }
}
