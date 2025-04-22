import 'package:flutter/material.dart';
import '../../screens/auth/login_screen.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutHandler {
  final BuildContext context;
  final FirebaseService _firebaseService = FirebaseService();

  LogoutHandler(this.context);

  Future<void> logout() async {
    try {
      // Show loading indicator
      _showLoadingDialog();

      // Clear authentication state
      await _firebaseService.signOut();

      // Clear any local storage/preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Dismiss loading dialog if still showing
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Navigate to login screen and clear navigation stack
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // Dismiss loading dialog if error occurs
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();

        final localizations = AppLocalizations.of(context);
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${localizations.translate('error_logout')}$e')),
        );
      }
    }
  }

  void _showLoadingDialog() {
    final localizations = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(localizations.translate('logging_out')),
            ],
          ),
        );
      },
    );
  }
}
