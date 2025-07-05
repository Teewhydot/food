import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';
import '../entities/restaurant.dart';
import '../entities/restaurant_food_category.dart';

abstract class RestaurantRepository {
  Future<Either<Failure, List<Restaurant>>> getRestaurants();
  Future<Either<Failure, List<Restaurant>>> getNearbyRestaurants(
    double latitude,
    double longitude,
  );
  Future<Either<Failure, List<Restaurant>>> getPopularRestaurants();
  Future<Either<Failure, Restaurant>> getRestaurantById(String id);
  Future<Either<Failure, List<Restaurant>>> searchRestaurants(String query);
  Future<Either<Failure, List<RestaurantFoodCategory>>> getRestaurantMenu(
    String restaurantId,
  );
  Future<Either<Failure, List<Restaurant>>> getRestaurantsByCategory(
    String category,
  );
}