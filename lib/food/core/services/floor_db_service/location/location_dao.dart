import 'package:floor/floor.dart';
import 'location_entity.dart';

@dao
abstract class LocationDao {
  @Query('SELECT * FROM cached_locations WHERE id = 1 LIMIT 1')
  Future<LocationFloorEntity?> getCachedLocation();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> cacheLocation(LocationFloorEntity location);

  @Query('DELETE FROM cached_locations')
  Future<void> clearLocationCache();

  @Query('SELECT COUNT(*) FROM cached_locations WHERE id = 1')
  Future<int?> hasLocationCache();
}