import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';

import '../entities/food.dart';
import '../repositories/food_repository.dart';

class FoodUseCase {
  final FoodRepository repository;

  FoodUseCase(this.repository);

  Future<Either<Failure, List<FoodEntity>>> getAllFoods() async {
    return await repository.getAllFoods();
  }

  Future<Either<Failure, List<FoodEntity>>> getPopularFoods() async {
    return await repository.getPopularFoods();
  }

  Future<Either<Failure, List<FoodEntity>>> getFoodsByCategory(
    String category,
  ) async {
    return await repository.getFoodsByCategory(category);
  }

  Future<Either<Failure, FoodEntity>> getFoodById(String id) async {
    return await repository.getFoodById(id);
  }

  Future<Either<Failure, List<FoodEntity>>> searchFoods(String query) async {
    return await repository.searchFoods(query);
  }

  Future<Either<Failure, List<FoodEntity>>> getFoodsByRestaurant(
    String restaurantId,
  ) async {
    return await repository.getFoodsByRestaurant(restaurantId);
  }

  Future<Either<Failure, List<FoodEntity>>> getRecommendedFoods() async {
    return await repository.getRecommendedFoods();
  }
}
