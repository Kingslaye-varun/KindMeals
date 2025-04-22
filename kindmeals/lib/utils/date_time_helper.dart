import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

/// Utility class to handle datetime operations consistently with IST timezone
class DateTimeHelper {
  /// The offset for Indian Standard Time (UTC+5:30)
  static const Duration istOffset = Duration(hours: 5, minutes: 30);

  /// Format a datetime object to a user-friendly string in IST
  static String formatDateTime(DateTime dateTime) {
    if (kDebugMode) {
      print('Formatting DateTime: $dateTime (isUTC: ${dateTime.isUtc})');
    }

    // Ensure the time is in local timezone
    final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;

    if (kDebugMode) {
      print('After toLocal: $localDateTime');
    }

    return DateFormat('dd/MM/yyyy HH:mm').format(localDateTime);
  }

  /// Format date only in IST
  static String formatDate(DateTime dateTime) {
    final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    return DateFormat('dd/MM/yyyy').format(localDateTime);
  }

  /// Format time only in IST
  static String formatTime(DateTime dateTime) {
    final localDateTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    return DateFormat('HH:mm').format(localDateTime);
  }

  /// Explicitly convert to IST time regardless of input timezone
  static DateTime toIST(DateTime dateTime) {
    if (kDebugMode) {
      print('Converting to IST: $dateTime (isUTC: ${dateTime.isUtc})');
    }

    if (dateTime.isUtc) {
      // If UTC, convert to local time which should be IST
      final localTime = dateTime.toLocal();
      if (kDebugMode) {
        print('Converted UTC to IST: $localTime');
      }
      return localTime;
    } else {
      // If already local, just return as is as Flutter should use device timezone
      if (kDebugMode) {
        print('Already in local time, returning as is: $dateTime');
      }
      return dateTime;
    }
  }

  /// Convert a string datetime from API to IST DateTime
  static DateTime parseToIST(String dateTimeString) {
    if (kDebugMode) {
      print('Parsing string to IST DateTime: $dateTimeString');
    }

    // Parse the ISO string to DateTime (will be in UTC)
    final DateTime utcDateTime = DateTime.parse(dateTimeString);

    // Convert to IST (local device time)
    final localTime = utcDateTime.toLocal();

    if (kDebugMode) {
      print('Parsed to IST: $localTime');
    }

    return localTime;
  }

  /// Format a date string from API for display in IST
  static String formatAPIDateTime(String dateTimeStr) {
    try {
      if (kDebugMode) {
        print('Formatting API date string to IST: $dateTimeStr');
      }

      final dateTime = parseToIST(dateTimeStr);
      final formatted = formatDateTime(dateTime);

      if (kDebugMode) {
        print('Formatted IST result: $formatted');
      }

      return formatted;
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting API date to IST: $e');
      }
      return dateTimeStr; // Return original if formatting fails
    }
  }

  /// Format a date string from API for display with 24-hour format in IST
  static String formatAPIDateTime24Hour(String dateTimeStr) {
    try {
      if (kDebugMode) {
        print('Formatting API date string to 24hr IST: $dateTimeStr');
      }

      final dateTime = parseToIST(dateTimeStr);
      final formatted = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);

      if (kDebugMode) {
        print('Formatted 24hr IST result: $formatted');
      }

      return formatted;
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting API date to 24hr IST: $e');
      }
      return dateTimeStr; // Return original if formatting fails
    }
  }

  /// Format a date string from API with custom format in IST
  static String formatAPIDateTimeCustom(String dateTimeStr, String format) {
    try {
      final dateTime = parseToIST(dateTimeStr);
      return DateFormat(format).format(dateTime);
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting API date with custom format in IST: $e');
      }
      return dateTimeStr; // Return original if formatting fails
    }
  }

  /// Convert a local DateTime to a properly formatted ISO string for API submission
  /// This ensures the time is stored correctly on the server
  static String toISOString(DateTime localDateTime) {
    if (kDebugMode) {
      print(
          'Converting local time to ISO string for API: $localDateTime (isUTC: ${localDateTime.isUtc})');
    }

    // If already in UTC, just convert to ISO
    // If in local time, convert to UTC first, then to ISO
    final DateTime utcDateTime =
        localDateTime.isUtc ? localDateTime : localDateTime.toUtc();
    final isoString = utcDateTime.toIso8601String();

    if (kDebugMode) {
      print('Converted to ISO string for API: $isoString');
    }

    return isoString;
  }
}
