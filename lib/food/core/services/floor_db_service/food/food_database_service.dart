import '../../../../features/home/domain/entities/food.dart';
import '../app_database.dart';
import 'food_entity.dart';

class FoodDatabaseService {
  final AppDatabase _database;

  FoodDatabaseService(this._database);

  Future<List<FoodEntity>> getAllFoods() async {
    final entities = await _database.foodDao.getAllFoods();
    return entities.map(_toDomainEntity).toList();
  }

  Future<FoodEntity?> getFoodById(String id) async {
    final entity = await _database.foodDao.getFoodById(id);
    return entity != null ? _toDomainEntity(entity) : null;
  }

  Future<List<FoodEntity>> getFoodsByRestaurant(String restaurantId) async {
    final entities = await _database.foodDao.getFoodsByRestaurant(restaurantId);
    return entities.map(_toDomainEntity).toList();
  }

  Future<List<FoodEntity>> searchFoods(String query) async {
    final entities = await _database.foodDao.searchFoods('%$query%');
    return entities.map(_toDomainEntity).toList();
  }

  Future<void> saveFood(FoodEntity food) async {
    final entity = _toFloorEntity(food);
    await _database.foodDao.insertFood(entity);
  }

  Future<void> saveFoods(List<FoodEntity> foods) async {
    final entities = foods.map(_toFloorEntity).toList();
    await _database.foodDao.insertFoods(entities);
  }

  Future<void> deleteOldFoods(Duration age) async {
    final timestamp = DateTime.now().subtract(age).millisecondsSinceEpoch;
    await _database.foodDao.deleteOldFoods(timestamp);
  }

  FoodEntity _toDomainEntity(FoodFloorEntity entity) {
    return FoodEntity(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      quantity: entity.quantity,
      rating: entity.rating,
      imageUrl: entity.imageUrl,
      category: entity.category,
      restaurantId: entity.restaurantId,
      restaurantName: entity.restaurantName,
      ingredients: entity.ingredients,
      isAvailable: entity.isAvailable,
      preparationTime: entity.preparationTime,
      calories: entity.calories,
      isVegetarian: entity.isVegetarian,
      isVegan: entity.isVegan,
      isGlutenFree: entity.isGlutenFree,
      lastUpdated: 1,
    );
  }

  FoodFloorEntity _toFloorEntity(FoodEntity food) {
    return FoodFloorEntity(
      id: food.id,
      name: food.name,
      description: food.description,
      price: food.price,
      quantity: food.quantity,

      rating: food.rating,
      imageUrl: food.imageUrl,
      category: food.category,
      restaurantId: food.restaurantId,
      restaurantName: food.restaurantName,
      ingredients: food.ingredients,
      isAvailable: food.isAvailable,
      preparationTime: food.preparationTime,
      calories: food.calories,
      isVegetarian: food.isVegetarian,
      isVegan: food.isVegan,
      isGlutenFree: food.isGlutenFree,
      lastUpdated: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
