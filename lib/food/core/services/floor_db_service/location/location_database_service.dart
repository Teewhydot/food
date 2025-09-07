import 'package:food/food/core/utils/logger.dart';
import 'package:food/food/features/auth/domain/entities/location_data.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../app_database.dart';
import 'location_entity.dart';

class LocationDatabaseService {
  static final LocationDatabaseService _instance =
      LocationDatabaseService._internal();
  
  AppDatabase? _database;
  factory LocationDatabaseService() => _instance;
  LocationDatabaseService._internal();
  
  // Cache expiry duration - 1 hour
  static const Duration _cacheExpiry = Duration(hours: 1);

  Future<AppDatabase> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<AppDatabase> _initDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDir.path, 'location_cache.db');
    return await $FloorAppDatabase.databaseBuilder(dbPath).build();
  }

  /// Get cached location if it exists and is not expired
  Future<LocationData?> getCachedLocation() async {
    try {
      final db = await database;
      final cached = await db.locationDao.getCachedLocation();
      
      if (cached == null) return null;
      
      // Check if cache has expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(cached.timestamp);
      final now = DateTime.now();
      
      if (now.difference(cacheTime) > _cacheExpiry) {
        // Cache expired, clear it
        await clearLocationCache();
        return null;
      }
      
      return cached.toDomain();
    } catch (e) {
      // Handle any database errors gracefully
      return null;
    }
  }

  /// Cache location data
  Future<void> cacheLocation(LocationData locationData) async {
    try {
      final db = await database;
      final entity = LocationFloorEntity.fromDomain(locationData);
      await db.locationDao.cacheLocation(entity);
    } catch (e) {
      // Handle database errors gracefully - don't throw
      Logger.logError('Error caching location: $e');
    }
  }

  /// Clear location cache
  Future<void> clearLocationCache() async {
    try {
      final db = await database;
      await db.locationDao.clearLocationCache();
    } catch (e) {
      // Handle database errors gracefully
      Logger.logError('Error clearing location cache: $e');
    }
  }

  /// Check if location cache exists
  Future<bool> hasLocationCache() async {
    try {
      final db = await database;
      final count = await db.locationDao.hasLocationCache();
      return (count ?? 0) > 0;
    } catch (e) {
      return false;
    }
  }

  /// Check if cached location is still valid (not expired)
  Future<bool> isCacheValid() async {
    try {
      final db = await database;
      final cached = await db.locationDao.getCachedLocation();
      
      if (cached == null) return false;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(cached.timestamp);
      final now = DateTime.now();
      
      return now.difference(cacheTime) <= _cacheExpiry;
    } catch (e) {
      return false;
    }
  }
}