import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kindmeals/services/api_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  // Get user notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      return await _apiService.getNotifications();
    } catch (e) {
      if (kDebugMode) {
        print('NotificationService - Error fetching notifications: $e');
      }
      return [];
    }
  }

  // Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _apiService.markNotificationAsRead(notificationId);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('NotificationService - Error marking notification as read: $e');
      }
      return false;
    }
  }

  // Parse notification date
  String getFormattedTime(String? dateTime) {
    if (dateTime == null) return 'Just now';

    try {
      final DateTime now = DateTime.now();
      final DateTime notificationTime = DateTime.parse(dateTime).toLocal();
      final Duration difference = now.difference(notificationTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing notification date: $e');
      }
      return 'Recently';
    }
  }

  // Get icon based on notification type
  IconData getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'donation_accepted':
        return Icons.check_circle;
      case 'volunteer_assigned':
        return Icons.delivery_dining;
      case 'donation_delivered':
        return Icons.local_shipping;
      case 'donation_expired':
        return Icons.timer_off;
      case 'new_donation':
        return Icons.fastfood;
      default:
        return Icons.notifications;
    }
  }

  // Get color based on notification type
  Color getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'donation_accepted':
        return Colors.green;
      case 'volunteer_assigned':
        return Colors.blue;
      case 'donation_delivered':
        return Colors.purple;
      case 'donation_expired':
        return Colors.red;
      case 'new_donation':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
