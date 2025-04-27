import 'package:flutter/material.dart';
import '../config/api_config.dart';

class ImageHelper {
  /// Converts a server image path to a properly formatted path for Flutter assets
  /// or returns a network image if it's a URL
  static ImageProvider getImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      // Return a placeholder image
      return const AssetImage('assets/images/google_logo.png');
    }

    // Process the image path using our API config
    final processedPath = ApiConfig.getImageUrl(imagePath);

    // If the processed path is empty, return placeholder
    if (processedPath.isEmpty) {
      return const AssetImage('assets/images/google_logo.png');
    }

    // Check if it's a network URL
    if (processedPath.startsWith('http://') ||
        processedPath.startsWith('https://')) {
      return NetworkImage(processedPath);
    }

    // Default case, assume it's an asset path
    return AssetImage(processedPath);
  }

  /// Widget to display an image with error handling
  static Widget getImage({
    required String? imagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Color? backgroundColor,
  }) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: backgroundColor ?? Colors.grey[200],
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }

    // Process the image path using our API config
    final processedPath = ApiConfig.getImageUrl(imagePath);

    // If the processed path is empty, return placeholder
    if (processedPath.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: backgroundColor ?? Colors.grey[200],
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }

    // Check if it's a network URL
    if (processedPath.startsWith('http://') ||
        processedPath.startsWith('https://')) {
      return Image.network(
        processedPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: backgroundColor ?? Colors.grey[200],
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: backgroundColor ?? Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            ),
          );
        },
      );
    }

    // Handle asset paths
    return Image.asset(
      processedPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: backgroundColor ?? Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.image_not_supported, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  'Image not found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
