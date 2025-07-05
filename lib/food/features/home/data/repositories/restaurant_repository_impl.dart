import 'package:dartz/dartz.dart';
import 'package:food/food/core/utils/handle_exceptions.dart';
import 'package:food/food/domain/failures/failures.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/restaurant_food_category.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../remote/data_sources/restaurant_remote_data_source.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remoteDataSource;

  RestaurantRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Restaurant>>> getRestaurants() {
    return handleExceptions(() async {
      return await remoteDataSource.getRestaurants();
    });
  }

  @override
  Future<Either<Failure, List<Restaurant>>> getNearbyRestaurants(
    double latitude,
    double longitude,
  ) {
    return handleExceptions(() async {
      return await remoteDataSource.getNearbyRestaurants(latitude, longitude);
    });
  }

  @override
  Future<Either<Failure, List<Restaurant>>> getPopularRestaurants() {
    return handleExceptions(() async {
      return await remoteDataSource.getPopularRestaurants();
    });
  }

  @override
  Future<Either<Failure, Restaurant>> getRestaurantById(String id) {
    return handleExceptions(() async {
      return await remoteDataSource.getRestaurantById(id);
    });
  }

  @override
  Future<Either<Failure, List<Restaurant>>> searchRestaurants(String query) {
    return handleExceptions(() async {
      return await remoteDataSource.searchRestaurants(query);
    });
  }

  @override
  Future<Either<Failure, List<RestaurantFoodCategory>>> getRestaurantMenu(
    String restaurantId,
  ) {
    return handleExceptions(() async {
      return await remoteDataSource.getRestaurantMenu(restaurantId);
    });
  }

  @override
  Future<Either<Failure, List<Restaurant>>> getRestaurantsByCategory(
    String category,
  ) {
    return handleExceptions(() async {
      return await remoteDataSource.getRestaurantsByCategory(category);
    });
  }
}