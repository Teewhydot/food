import 'dart:async';
import 'package:meta/meta.dart';

import '../base/base_state.dart';
import '../../../core/utils/logger.dart';

/// Mixin that provides caching functionality to BLoCs/Cubits
/// Automatically saves and restores state from persistent storage
mixin CacheableBlocMixin<State extends BaseState> {
  /// Duration after which cached data is considered stale
  Duration get cacheTimeout => const Duration(hours: 1);
  
  /// Unique key for caching this BLoC's state
  String get cacheKey;

  /// Whether to enable caching for this BLoC
  bool get enableCaching => true;

  /// Convert state to JSON for caching
  Map<String, dynamic>? stateToJson(State state);

  /// Create state from cached JSON
  State? stateFromJson(Map<String, dynamic> json);

  // Simple in-memory cache for now (can be enhanced later with persistent storage)
  static final Map<String, Map<String, dynamic>> _cache = {};

  /// Save current state to cache
  @protected
  Future<void> saveStateToCache(State state) async {
    if (!enableCaching) return;

    try {
      final jsonData = stateToJson(state);
      
      if (jsonData != null) {
        final cacheData = {
          'state': jsonData,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        
        _cache[cacheKey] = cacheData;
        Logger.logBasic('State cached for $cacheKey');
      }
    } catch (e) {
      Logger.logError('Failed to cache state for $cacheKey: $e');
    }
  }

  /// Load state from cache
  @protected
  Future<State?> loadStateFromCache() async {
    if (!enableCaching) return null;

    try {
      final cacheData = _cache[cacheKey];
      
      if (cacheData == null) return null;

      final timestamp = cacheData['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      // Check if cache is still valid
      if (DateTime.now().difference(cacheTime) > cacheTimeout) {
        Logger.logBasic('Cache expired for $cacheKey');
        await clearCache();
        return null;
      }

      final stateData = cacheData['state'] as Map<String, dynamic>;
      final state = stateFromJson(stateData);
      
      if (state != null) {
        Logger.logBasic('State loaded from cache for $cacheKey');
      }
      
      return state;
    } catch (e) {
      Logger.logError('Failed to load cached state for $cacheKey: $e');
      await clearCache(); // Clear corrupted cache
      return null;
    }
  }

  /// Clear cached state
  @protected
  Future<void> clearCache() async {
    try {
      _cache.remove(cacheKey);
      Logger.logBasic('Cache cleared for $cacheKey');
    } catch (e) {
      Logger.logError('Failed to clear cache for $cacheKey: $e');
    }
  }

  /// Check if cached data exists and is valid
  @protected
  Future<bool> hasCachedData() async {
    if (!enableCaching) return false;

    try {
      final cacheData = _cache[cacheKey];
      
      if (cacheData == null) return false;

      final timestamp = cacheData['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      return DateTime.now().difference(cacheTime) <= cacheTimeout;
    } catch (e) {
      Logger.logError('Failed to check cached data for $cacheKey: $e');
      return false;
    }
  }

  /// Get cache age
  @protected
  Future<Duration?> getCacheAge() async {
    if (!enableCaching) return null;

    try {
      final cacheData = _cache[cacheKey];
      
      if (cacheData == null) return null;

      final timestamp = cacheData['timestamp'] as int;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      return DateTime.now().difference(cacheTime);
    } catch (e) {
      Logger.logError('Failed to get cache age for $cacheKey: $e');
      return null;
    }
  }
}