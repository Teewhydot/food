import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Utility class for managing detail screen image caching
class DetailImageCache {
  static final Map<String, bool> _preloadedImages = {};
  
  /// Preload an image to ensure it's cached for detail screens
  static Future<void> preloadDetailImage({
    required BuildContext context,
    required String imageUrl,
    required String cacheKey,
  }) async {
    if (_preloadedImages[cacheKey] == true) return;
    
    try {
      await precacheImage(
        CachedNetworkImageProvider(imageUrl),
        context,
      );
      _preloadedImages[cacheKey] = true;
    } catch (e) {
      // Silently handle preload failures
      debugPrint('Failed to preload detail image: $imageUrl - $e');
    }
  }
  
  /// Check if an image is already preloaded
  static bool isPreloaded(String cacheKey) {
    return _preloadedImages[cacheKey] == true;
  }
  
  /// Clear preload tracking for a specific image
  static void clearPreloadStatus(String cacheKey) {
    _preloadedImages.remove(cacheKey);
  }
  
  /// Clear all preload tracking
  static void clearAllPreloadStatus() {
    _preloadedImages.clear();
  }
  
  /// Get optimized cache key for detail images
  static String getDetailCacheKey({
    required String type, // 'food' or 'restaurant'  
    required String id,
  }) {
    return '${type}_detail_image_$id';
  }
}