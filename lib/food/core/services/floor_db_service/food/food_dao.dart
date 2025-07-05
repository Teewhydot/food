import 'package:floor/floor.dart';
import 'food_entity.dart';

@dao
abstract class FoodDao {
  @Query('SELECT * FROM foods')
  Future<List<FoodFloorEntity>> getAllFoods();

  @Query('SELECT * FROM foods WHERE id = :id')
  Future<FoodFloorEntity?> getFoodById(String id);

  @Query('SELECT * FROM foods WHERE category = :category')
  Future<List<FoodFloorEntity>> getFoodsByCategory(String category);

  @Query('SELECT * FROM foods WHERE restaurantId = :restaurantId')
  Future<List<FoodFloorEntity>> getFoodsByRestaurant(String restaurantId);

  @Query('SELECT * FROM foods WHERE rating >= :minRating ORDER BY rating DESC')
  Future<List<FoodFloorEntity>> getPopularFoods(double minRating);

  @Query('SELECT * FROM foods WHERE name LIKE :query OR description LIKE :query OR category LIKE :query OR restaurantName LIKE :query')
  Future<List<FoodFloorEntity>> searchFoods(String query);

  @Query('SELECT * FROM foods WHERE isVegetarian = 1')
  Future<List<FoodFloorEntity>> getVegetarianFoods();

  @Query('SELECT * FROM foods WHERE isVegan = 1')
  Future<List<FoodFloorEntity>> getVeganFoods();

  @Query('SELECT * FROM foods WHERE isGlutenFree = 1')
  Future<List<FoodFloorEntity>> getGlutenFreeFoods();

  @insert
  Future<void> insertFood(FoodFloorEntity food);

  @insert
  Future<void> insertFoods(List<FoodFloorEntity> foods);

  @update
  Future<void> updateFood(FoodFloorEntity food);

  @delete
  Future<void> deleteFood(FoodFloorEntity food);

  @Query('DELETE FROM foods')
  Future<void> deleteAllFoods();

  @Query('DELETE FROM foods WHERE lastUpdated < :timestamp')
  Future<void> deleteOldFoods(int timestamp);
}