import '../../../../features/home/domain/entities/restaurant.dart';
import '../app_database.dart';
import 'restaurant_entity.dart';

class RestaurantDatabaseService {
  final AppDatabase _database;

  RestaurantDatabaseService(this._database);

  Future<List<Restaurant>> getAllRestaurants() async {
    final entities = await _database.restaurantDao.getAllRestaurants();
    return entities.map(_toDomainEntity).toList();
  }

  Future<Restaurant?> getRestaurantById(String id) async {
    final entity = await _database.restaurantDao.getRestaurantById(id);
    return entity != null ? _toDomainEntity(entity) : null;
  }

  Future<List<Restaurant>> searchRestaurants(String query) async {
    final entities = await _database.restaurantDao.searchRestaurants(
      '%$query%',
    );
    return entities.map(_toDomainEntity).toList();
  }

  Future<void> saveRestaurant(Restaurant restaurant) async {
    final entity = _toFloorEntity(restaurant);
    await _database.restaurantDao.insertRestaurant(entity);
  }

  Future<void> saveRestaurants(List<Restaurant> restaurants) async {
    final entities = restaurants.map(_toFloorEntity).toList();
    await _database.restaurantDao.insertRestaurants(entities);
  }

  Future<void> deleteOldRestaurants(Duration age) async {
    final timestamp = DateTime.now().subtract(age).millisecondsSinceEpoch;
    await _database.restaurantDao.deleteOldRestaurants(timestamp);
  }

  Restaurant _toDomainEntity(RestaurantFloorEntity entity) {
    return Restaurant(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      location: entity.location,
      distance: entity.distance,
      rating: entity.rating,
      deliveryTime: entity.deliveryTime,
      deliveryFee: entity.deliveryFee,
      imageUrl: entity.imageUrl,
      category: entity.category,
      isOpen: entity.isOpen,
      latitude: entity.latitude,
      longitude: entity.longitude,
      lastUpdated: 1,
    );
  }

  RestaurantFloorEntity _toFloorEntity(Restaurant restaurant) {
    return RestaurantFloorEntity(
      id: restaurant.id,
      name: restaurant.name,
      description: restaurant.description,
      location: restaurant.location,
      distance: restaurant.distance,
      rating: restaurant.rating,
      deliveryTime: restaurant.deliveryTime,
      deliveryFee: restaurant.deliveryFee,
      imageUrl: restaurant.imageUrl,
      category: restaurant.category,
      isOpen: restaurant.isOpen,
      latitude: restaurant.latitude,
      longitude: restaurant.longitude,
      lastUpdated: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
