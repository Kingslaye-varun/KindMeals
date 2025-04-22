import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Get current location as latitude, longitude
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check location permission
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) {
          print('Location services are disabled.');
        }
        return null;
      }

      // Check permission
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print('Location permissions are denied');
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print('Location permissions are permanently denied');
        }
        return null;
      }

      // Everything is ok, get location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (kDebugMode) {
        print('Current location: ${position.latitude}, ${position.longitude}');
      }

      return position;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location: $e');
      }
      return null;
    }
  }

  /// Get address from coordinates
  static Future<String?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
        return address;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting address: $e');
      }
      return null;
    }
  }

  /// Get coordinates from address
  static Future<Map<String, double>?> getCoordinatesFromAddress(
      String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        return {
          'latitude': locations[0].latitude,
          'longitude': locations[0].longitude,
        };
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting coordinates from address: $e');
      }
      return null;
    }
  }

  /// Calculate distance between two coordinates in kilometers
  static double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
            startLatitude, startLongitude, endLatitude, endLongitude) /
        1000; // Convert meters to kilometers
  }
}
