import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';

import '../entities/food.dart';

abstract class FoodRepository {
  Future<Either<Failure, List<FoodEntity>>> getAllFoods();
  Future<Either<Failure, List<FoodEntity>>> getPopularFoods();
  Future<Either<Failure, List<FoodEntity>>> getFoodsByCategory(String category);
  Future<Either<Failure, FoodEntity>> getFoodById(String id);
  Future<Either<Failure, List<FoodEntity>>> searchFoods(String query);
  Future<Either<Failure, List<FoodEntity>>> getFoodsByRestaurant(
    String restaurantId,
  );
  Future<Either<Failure, List<FoodEntity>>> getRecommendedFoods();
}
