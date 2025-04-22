import 'package:flutter/material.dart';

class ImageHelper {
  /// Converts a server image path to a properly formatted path for Flutter assets
  /// or returns a network image if it's a URL
  static ImageProvider getImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      // Return a placeholder image
      return const AssetImage('assets/images/google_logo.png');
    }

    // Check if it's a network URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return NetworkImage(imagePath);
    }

    // Handle paths that start with /uploads/
    if (imagePath.startsWith('/uploads/')) {
      // Remove the leading slash and use the assets directory
      final formattedPath = 'assets${imagePath}';
      return AssetImage(formattedPath);
    }

    // Handle relative paths in the uploads directory
    if (imagePath.contains('uploads/')) {
      return AssetImage('assets/$imagePath');
    }

    // Default case, assume it's an asset path
    return AssetImage(imagePath);
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

    // Check if it's a network URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
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

    // Handle paths that start with /uploads/
    String assetPath = imagePath;
    if (imagePath.startsWith('/uploads/')) {
      assetPath = 'assets${imagePath}';
    } else if (imagePath.contains('uploads/') &&
        !imagePath.startsWith('assets/')) {
      assetPath = 'assets/$imagePath';
    }

    return Image.asset(
      assetPath,
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
