import 'package:floor/floor.dart';
import '../../models/geocoding_cache_model.dart';

/// Data Access Object for geocoding cache operations
@dao
abstract class GeocodingCacheDao {
  /// Get cached geocoding result by coordinates (within tolerance)
  @Query('SELECT * FROM GeocodingCacheModel WHERE '
         'ABS(latitude - :latitude) <= :tolerance AND '
         'ABS(longitude - :longitude) <= :tolerance AND '
         'expires_at > :currentTime '
         'ORDER BY cached_at DESC LIMIT 1')
  Future<GeocodingCacheModel?> getCachedResult(
    double latitude,
    double longitude,
    double tolerance,
    int currentTime, // Unix timestamp in milliseconds
  );

  /// Insert geocoding result into cache
  @insert
  Future<int> insertCacheResult(GeocodingCacheModel cacheModel);

  /// Update existing cache result
  @update
  Future<int> updateCacheResult(GeocodingCacheModel cacheModel);

  /// Delete expired cache entries
  @Query('DELETE FROM GeocodingCacheModel WHERE expires_at <= :currentTime')
  Future<int> deleteExpiredEntries(int currentTime);

  /// Get all cache entries (for debugging/testing)
  @Query('SELECT * FROM GeocodingCacheModel ORDER BY cached_at DESC')
  Future<List<GeocodingCacheModel>> getAllCacheEntries();

  /// Delete all cache entries
  @Query('DELETE FROM GeocodingCacheModel')
  Future<int> clearAllCache();

  /// Get cache statistics
  @Query('SELECT COUNT(*) FROM GeocodingCacheModel')
  Future<int?> getCacheCount();

  /// Get count of valid (non-expired) cache entries
  @Query('SELECT COUNT(*) FROM GeocodingCacheModel WHERE expires_at > :currentTime')
  Future<int?> getValidCacheCount(int currentTime);

  /// Delete oldest cache entries to maintain cache size limit
  @Query('DELETE FROM GeocodingCacheModel WHERE id IN ('
         'SELECT id FROM GeocodingCacheModel '
         'ORDER BY cached_at ASC LIMIT :count)')
  Future<int> deleteOldestEntries(int count);
}