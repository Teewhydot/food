import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';
import '../entities/restaurant.dart';
import '../entities/restaurant_food_category.dart';
import '../repositories/restaurant_repository.dart';

class RestaurantUseCase {
  final RestaurantRepository repository;

  RestaurantUseCase(this.repository);

  Future<Either<Failure, List<Restaurant>>> getRestaurants() async {
    return await repository.getRestaurants();
  }

  Future<Either<Failure, List<Restaurant>>> getNearbyRestaurants(
    double latitude,
    double longitude,
  ) async {
    return await repository.getNearbyRestaurants(latitude, longitude);
  }

  Future<Either<Failure, List<Restaurant>>> getPopularRestaurants() async {
    return await repository.getPopularRestaurants();
  }

  Future<Either<Failure, Restaurant>> getRestaurantById(String id) async {
    return await repository.getRestaurantById(id);
  }

  Future<Either<Failure, List<Restaurant>>> searchRestaurants(
    String query,
  ) async {
    return await repository.searchRestaurants(query);
  }

  Future<Either<Failure, List<RestaurantFoodCategory>>> getRestaurantMenu(
    String restaurantId,
  ) async {
    return await repository.getRestaurantMenu(restaurantId);
  }

  Future<Either<Failure, List<Restaurant>>> getRestaurantsByCategory(
    String category,
  ) async {
    return await repository.getRestaurantsByCategory(category);
  }
}