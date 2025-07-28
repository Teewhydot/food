import 'package:dartz/dartz.dart';
import '../../../../domain/failures/failures.dart';
import '../entities/food.dart';
import '../entities/restaurant.dart';
import '../repositories/favorites_repository.dart';

class FavoritesUseCase {
  final FavoritesRepository repository;

  FavoritesUseCase(this.repository);

  Future<Either<Failure, List<FoodEntity>>> getFavoriteFoods(String userId) {
    if (userId.isEmpty) {
      return Future.value(Left(UnknownFailure(
        failureMessage: 'User ID cannot be empty'
      )));
    }
    return repository.getFavoriteFoods(userId);
  }

  Future<Either<Failure, List<Restaurant>>> getFavoriteRestaurants(String userId) {
    if (userId.isEmpty) {
      return Future.value(Left(UnknownFailure(
        failureMessage: 'User ID cannot be empty'
      )));
    }
    return repository.getFavoriteRestaurants(userId);
  }

  Future<Either<Failure, void>> toggleFoodFavorite(String userId, String foodId) async {
    if (userId.isEmpty || foodId.isEmpty) {
      return Left(UnknownFailure(
        failureMessage: 'User ID and Food ID cannot be empty'
      ));
    }

    final isFavoriteResult = await repository.isFoodFavorite(userId, foodId);
    
    return isFavoriteResult.fold(
      (failure) => Left(failure),
      (isFavorite) async {
        if (isFavorite) {
          return await repository.removeFoodFromFavorites(userId, foodId);
        } else {
          return await repository.addFoodToFavorites(userId, foodId);
        }
      },
    );
  }

  Future<Either<Failure, void>> toggleRestaurantFavorite(String userId, String restaurantId) async {
    if (userId.isEmpty || restaurantId.isEmpty) {
      return Left(UnknownFailure(
        failureMessage: 'User ID and Restaurant ID cannot be empty'
      ));
    }

    final isFavoriteResult = await repository.isRestaurantFavorite(userId, restaurantId);
    
    return isFavoriteResult.fold(
      (failure) => Left(failure),
      (isFavorite) async {
        if (isFavorite) {
          return await repository.removeRestaurantFromFavorites(userId, restaurantId);
        } else {
          return await repository.addRestaurantToFavorites(userId, restaurantId);
        }
      },
    );
  }

  Future<Either<Failure, void>> addFoodToFavorites(String userId, String foodId) {
    if (userId.isEmpty || foodId.isEmpty) {
      return Future.value(Left(UnknownFailure(
        failureMessage: 'User ID and Food ID cannot be empty'
      )));
    }
    return repository.addFoodToFavorites(userId, foodId);
  }

  Future<Either<Failure, void>> removeFoodFromFavorites(String userId, String foodId) {
    if (userId.isEmpty || foodId.isEmpty) {
      return Future.value(Left(UnknownFailure(
        failureMessage: 'User ID and Food ID cannot be empty'
      )));
    }
    return repository.removeFoodFromFavorites(userId, foodId);
  }

  Future<Either<Failure, void>> addRestaurantToFavorites(String userId, String restaurantId) {
    if (userId.isEmpty || restaurantId.isEmpty) {
      return Future.value(Left(UnknownFailure(
        failureMessage: 'User ID and Restaurant ID cannot be empty'
      )));
    }
    return repository.addRestaurantToFavorites(userId, restaurantId);
  }

  Future<Either<Failure, void>> removeRestaurantFromFavorites(String userId, String restaurantId) {
    if (userId.isEmpty || restaurantId.isEmpty) {
      return Future.value(Left(UnknownFailure(
        failureMessage: 'User ID and Restaurant ID cannot be empty'
      )));
    }
    return repository.removeRestaurantFromFavorites(userId, restaurantId);
  }

  Future<Either<Failure, bool>> isFoodFavorite(String userId, String foodId) {
    if (userId.isEmpty || foodId.isEmpty) {
      return Future.value(Left(UnknownFailure(
        failureMessage: 'User ID and Food ID cannot be empty'
      )));
    }
    return repository.isFoodFavorite(userId, foodId);
  }

  Future<Either<Failure, bool>> isRestaurantFavorite(String userId, String restaurantId) {
    if (userId.isEmpty || restaurantId.isEmpty) {
      return Future.value(Left(UnknownFailure(
        failureMessage: 'User ID and Restaurant ID cannot be empty'
      )));
    }
    return repository.isRestaurantFavorite(userId, restaurantId);
  }

  Stream<Either<Failure, List<String>>> watchFavoriteFoodIds(String userId) {
    return repository.watchFavoriteFoodIds(userId);
  }

  Stream<Either<Failure, List<String>>> watchFavoriteRestaurantIds(String userId) {
    return repository.watchFavoriteRestaurantIds(userId);
  }

  Future<Either<Failure, void>> clearAllFavorites(String userId) {
    if (userId.isEmpty) {
      return Future.value(Left(UnknownFailure(
        failureMessage: 'User ID cannot be empty'
      )));
    }
    return repository.clearAllFavorites(userId);
  }

  Future<Either<Failure, Map<String, dynamic>>> getFavoritesStats(String userId) async {
    if (userId.isEmpty) {
      return Left(UnknownFailure(
        failureMessage: 'User ID cannot be empty'
      ));
    }

    final favoriteFoodsResult = await repository.getFavoriteFoods(userId);
    final favoriteRestaurantsResult = await repository.getFavoriteRestaurants(userId);

    return favoriteFoodsResult.fold(
      (failure) => Left(failure),
      (favoriteFoods) {
        return favoriteRestaurantsResult.fold(
          (failure) => Left(failure),
          (favoriteRestaurants) {
            final stats = {
              'totalFavoriteFoods': favoriteFoods.length,
              'totalFavoriteRestaurants': favoriteRestaurants.length,
              'favoriteFoodCategories': _getFoodCategoryCounts(favoriteFoods),
              'favoriteRestaurantCategories': _getRestaurantCategoryCounts(favoriteRestaurants),
            };
            return Right(stats);
          },
        );
      },
    );
  }

  Map<String, int> _getFoodCategoryCounts(List<FoodEntity> foods) {
    final categoryCounts = <String, int>{};
    for (final food in foods) {
      categoryCounts[food.category] = (categoryCounts[food.category] ?? 0) + 1;
    }
    return categoryCounts;
  }

  Map<String, int> _getRestaurantCategoryCounts(List<Restaurant> restaurants) {
    final categoryCounts = <String, int>{};
    for (final restaurant in restaurants) {
      for (final category in restaurant.category) {
        categoryCounts[category.category] = (categoryCounts[category.category] ?? 0) + 1;
      }
    }
    return categoryCounts;
  }
}