import 'package:floor/floor.dart';
import 'restaurant_entity.dart';

@dao
abstract class RestaurantDao {
  @Query('SELECT * FROM restaurants')
  Future<List<RestaurantFloorEntity>> getAllRestaurants();

  @Query('SELECT * FROM restaurants WHERE id = :id')
  Future<RestaurantFloorEntity?> getRestaurantById(String id);

  @Query('SELECT * FROM restaurants WHERE category = :category')
  Future<List<RestaurantFloorEntity>> getRestaurantsByCategory(String category);

  @Query('SELECT * FROM restaurants WHERE rating >= :minRating ORDER BY rating DESC')
  Future<List<RestaurantFloorEntity>> getPopularRestaurants(double minRating);

  @Query('SELECT * FROM restaurants WHERE name LIKE :query OR description LIKE :query OR category LIKE :query')
  Future<List<RestaurantFloorEntity>> searchRestaurants(String query);

  @insert
  Future<void> insertRestaurant(RestaurantFloorEntity restaurant);

  @insert
  Future<void> insertRestaurants(List<RestaurantFloorEntity> restaurants);

  @update
  Future<void> updateRestaurant(RestaurantFloorEntity restaurant);

  @delete
  Future<void> deleteRestaurant(RestaurantFloorEntity restaurant);

  @Query('DELETE FROM restaurants')
  Future<void> deleteAllRestaurants();

  @Query('DELETE FROM restaurants WHERE lastUpdated < :timestamp')
  Future<void> deleteOldRestaurants(int timestamp);
}