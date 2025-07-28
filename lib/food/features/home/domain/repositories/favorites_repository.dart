import 'package:dartz/dartz.dart';
import '../../../../domain/failures/failures.dart';
import '../entities/food.dart';
import '../entities/restaurant.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<FoodEntity>>> getFavoriteFoods(String userId);
  Future<Either<Failure, List<Restaurant>>> getFavoriteRestaurants(String userId);
  Future<Either<Failure, void>> addFoodToFavorites(String userId, String foodId);
  Future<Either<Failure, void>> removeFoodFromFavorites(String userId, String foodId);
  Future<Either<Failure, void>> addRestaurantToFavorites(String userId, String restaurantId);
  Future<Either<Failure, void>> removeRestaurantFromFavorites(String userId, String restaurantId);
  Future<Either<Failure, bool>> isFoodFavorite(String userId, String foodId);
  Future<Either<Failure, bool>> isRestaurantFavorite(String userId, String restaurantId);
  Stream<Either<Failure, List<String>>> watchFavoriteFoodIds(String userId);
  Stream<Either<Failure, List<String>>> watchFavoriteRestaurantIds(String userId);
  Future<Either<Failure, void>> clearAllFavorites(String userId);
}