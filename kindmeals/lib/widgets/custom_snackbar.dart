import 'package:flutter/material.dart';

enum SnackbarType {
  success,
  error,
  info,
  warning,
}

class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    required SnackbarType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;
    IconData iconData;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = Colors.green.shade800;
        iconData = Icons.check_circle;
        break;
      case SnackbarType.error:
        backgroundColor = Colors.red.shade800;
        iconData = Icons.error;
        break;
      case SnackbarType.info:
      default:
        backgroundColor = Colors.blue.shade800;
        iconData = Icons.info;
        break;
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            iconData,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(8),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
