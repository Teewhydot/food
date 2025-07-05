import 'package:dartz/dartz.dart';
import 'package:food/food/core/utils/handle_exceptions.dart';
import 'package:food/food/domain/failures/failures.dart';

import '../../domain/entities/food.dart';
import '../../domain/repositories/food_repository.dart';
import '../remote/data_sources/food_remote_data_source.dart';

class FoodRepositoryImpl implements FoodRepository {
  final FoodRemoteDataSource remoteDataSource;

  FoodRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<FoodEntity>>> getAllFoods() {
    return handleExceptions(() async {
      return await remoteDataSource.getAllFoods();
    });
  }

  @override
  Future<Either<Failure, List<FoodEntity>>> getPopularFoods() {
    return handleExceptions(() async {
      return await remoteDataSource.getPopularFoods();
    });
  }

  @override
  Future<Either<Failure, List<FoodEntity>>> getFoodsByCategory(
    String category,
  ) {
    return handleExceptions(() async {
      return await remoteDataSource.getFoodsByCategory(category);
    });
  }

  @override
  Future<Either<Failure, FoodEntity>> getFoodById(String id) {
    return handleExceptions(() async {
      return await remoteDataSource.getFoodById(id);
    });
  }

  @override
  Future<Either<Failure, List<FoodEntity>>> searchFoods(String query) {
    return handleExceptions(() async {
      return await remoteDataSource.searchFoods(query);
    });
  }

  @override
  Future<Either<Failure, List<FoodEntity>>> getFoodsByRestaurant(
    String restaurantId,
  ) {
    return handleExceptions(() async {
      return await remoteDataSource.getFoodsByRestaurant(restaurantId);
    });
  }

  @override
  Future<Either<Failure, List<FoodEntity>>> getRecommendedFoods() {
    return handleExceptions(() async {
      return await remoteDataSource.getRecommendedFoods();
    });
  }
}
