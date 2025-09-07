import '../../../domain/entities/geocoding_data.dart';
import '../../models/geocoding_cache_model.dart';
import 'geocoding_cache_dao.dart';

/// Abstract interface for local geocoding data source
abstract class GeocodingLocalDataSource {
  /// Get cached geocoding result for coordinates
  Future<GeocodingData?> getCachedResult({
    required double latitude,
    required double longitude,
    double tolerance = 0.001,
  });

  /// Cache geocoding result
  Future<void> cacheResult(
    GeocodingData geocodingData, {
    Duration cacheDuration = const Duration(hours: 24),
  });

  /// Clear expired cache entries
  Future<void> clearExpiredCache();

  /// Clear all cache
  Future<void> clearAllCache();

  /// Get cache statistics
  Future<Map<String, int>> getCacheStats();
}

/// Implementation of local geocoding data source using Floor database
class GeocodingLocalDataSourceImpl implements GeocodingLocalDataSource {
  final GeocodingCacheDao _cacheDao;
  final int _maxCacheSize;

  const GeocodingLocalDataSourceImpl(
    this._cacheDao, {
    int maxCacheSize = 1000,
  }) : _maxCacheSize = maxCacheSize;

  @override
  Future<GeocodingData?> getCachedResult({
    required double latitude,
    required double longitude,
    double tolerance = 0.001,
  }) async {
    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      
      final cachedModel = await _cacheDao.getCachedResult(
        latitude,
        longitude,
        tolerance,
        currentTime,
      );

      if (cachedModel != null && cachedModel.isValid) {
        return cachedModel.toDomainEntity();
      }

      return null;
    } catch (e) {
      // Log error but don't throw - cache failures shouldn't break app
      return null;
    }
  }

  @override
  Future<void> cacheResult(
    GeocodingData geocodingData, {
    Duration cacheDuration = const Duration(hours: 24),
  }) async {
    try {
      // Check if we need to clean up old entries first
      await _maintainCacheSize();

      final cacheModel = GeocodingCacheModel.fromDomainEntity(
        geocodingData,
        cacheDuration: cacheDuration,
      );

      await _cacheDao.insertCacheResult(cacheModel);
    } catch (e) {
      // Log error but don't throw - cache failures shouldn't break app
    }
  }

  @override
  Future<void> clearExpiredCache() async {
    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      await _cacheDao.deleteExpiredEntries(currentTime);
    } catch (e) {
      // Log error but don't throw
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      await _cacheDao.clearAllCache();
    } catch (e) {
      // Log error but don't throw
    }
  }

  @override
  Future<Map<String, int>> getCacheStats() async {
    try {
      final totalCount = await _cacheDao.getCacheCount() ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final validCount = await _cacheDao.getValidCacheCount(currentTime) ?? 0;

      return {
        'total': totalCount,
        'valid': validCount,
        'expired': totalCount - validCount,
      };
    } catch (e) {
      return {
        'total': 0,
        'valid': 0,
        'expired': 0,
      };
    }
  }

  /// Maintain cache size by removing oldest entries if needed
  Future<void> _maintainCacheSize() async {
    try {
      final totalCount = await _cacheDao.getCacheCount() ?? 0;
      
      if (totalCount >= _maxCacheSize) {
        // Remove 20% of the oldest entries to make room
        final entriesToRemove = (_maxCacheSize * 0.2).round();
        await _cacheDao.deleteOldestEntries(entriesToRemove);
      }
    } catch (e) {
      // If cache maintenance fails, try to clear expired entries as fallback
      await clearExpiredCache();
    }
  }
}