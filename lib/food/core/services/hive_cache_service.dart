import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/logger.dart';

class HiveCacheService {
  static HiveCacheService? _instance;
  static Box? _cacheBox;

  HiveCacheService._internal();

  static HiveCacheService get instance {
    _instance ??= HiveCacheService._internal();
    return _instance!;
  }

  static Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      _cacheBox = await Hive.openBox('app_cache');
      Logger.logSuccess('HiveCacheService initialized successfully');
    } catch (e) {
      Logger.logError('Failed to initialize HiveCacheService: $e');
      rethrow;
    }
  }

  static void dispose() {
    _cacheBox?.close();
    _instance = null;
  }

  Future<void> _ensureInitialized() async {
    if (_cacheBox == null) {
      Logger.logWarning('HiveCacheService not initialized, attempting to initialize...');
      await initialize();
    }
  }

  Future<void> store<T>(String key, T value, {Duration? expiry}) async {
    try {
      await _ensureInitialized();

      final data = {
        'value': value,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiry': expiry?.inMilliseconds,
      };

      await _cacheBox!.put(key, jsonEncode(data));
      Logger.logBasic('Stored data for key: $key');
    } catch (e) {
      Logger.logError('Failed to store data for key $key: $e');
      rethrow;
    }
  }

  Future<T?> get<T>(String key) async {
    try {
      await _ensureInitialized();

      final rawData = _cacheBox!.get(key);
      if (rawData == null) {
        return null;
      }

      final data = jsonDecode(rawData);
      final timestamp = data['timestamp'] as int;
      final expiryMs = data['expiry'] as int?;

      if (expiryMs != null) {
        final expiryTime = timestamp + expiryMs;
        final now = DateTime.now().millisecondsSinceEpoch;

        if (now > expiryTime) {
          Logger.logBasic('Cache expired for key: $key');
          await remove(key);
          return null;
        }
      }

      return data['value'] as T;
    } catch (e) {
      Logger.logError('Failed to get data for key $key: $e');
      return null;
    }
  }

  /// Synchronous get method for performance-critical operations
  /// Returns null if box is not initialized or key doesn't exist
  T? getSync<T>(String key) {
    try {
      if (_cacheBox == null) {
        return null;
      }

      final rawData = _cacheBox!.get(key);
      if (rawData == null) {
        return null;
      }

      final data = jsonDecode(rawData);
      final timestamp = data['timestamp'] as int;
      final expiryMs = data['expiry'] as int?;

      if (expiryMs != null) {
        final expiryTime = timestamp + expiryMs;
        final now = DateTime.now().millisecondsSinceEpoch;

        if (now > expiryTime) {
          // Don't remove synchronously to avoid potential issues
          return null;
        }
      }

      return data['value'] as T;
    } catch (e) {
      Logger.logError('Failed to get data synchronously for key $key: $e');
      return null;
    }
  }

  Future<bool> hasKey(String key) async {
    try {
      await _ensureInitialized();
      return _cacheBox!.containsKey(key);
    } catch (e) {
      Logger.logError('Failed to check key $key: $e');
      return false;
    }
  }

  Future<bool> isExpired(String key) async {
    try {
      await _ensureInitialized();

      final rawData = _cacheBox!.get(key);
      if (rawData == null) {
        return true;
      }

      final data = jsonDecode(rawData);
      final timestamp = data['timestamp'] as int;
      final expiryMs = data['expiry'] as int?;

      if (expiryMs == null) {
        return false;
      }

      final expiryTime = timestamp + expiryMs;
      final now = DateTime.now().millisecondsSinceEpoch;

      return now > expiryTime;
    } catch (e) {
      Logger.logError('Failed to check expiry for key $key: $e');
      return true;
    }
  }

  Future<void> remove(String key) async {
    try {
      await _ensureInitialized();
      await _cacheBox!.delete(key);
      Logger.logBasic('Removed data for key: $key');
    } catch (e) {
      Logger.logError('Failed to remove data for key $key: $e');
    }
  }

  Future<void> clear() async {
    try {
      await _ensureInitialized();
      await _cacheBox!.clear();
      Logger.logBasic('Cleared all cache data');
    } catch (e) {
      Logger.logError('Failed to clear cache: $e');
    }
  }

  Future<List<String>> getAllKeys() async {
    try {
      await _ensureInitialized();
      return _cacheBox!.keys.cast<String>().toList();
    } catch (e) {
      Logger.logError('Failed to get all keys: $e');
      return [];
    }
  }

  Future<int> get size async {
    try {
      await _ensureInitialized();
      return _cacheBox?.length ?? 0;
    } catch (e) {
      Logger.logError('Failed to get cache size: $e');
      return 0;
    }
  }
}