import 'package:dartz/dartz.dart';
import '../../../../core/utils/handle_exceptions.dart';
import '../../../../domain/failures/failures.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../remote/data_sources/favorites_remote_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;

  FavoritesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<FoodEntity>>> getFavoriteFoods(String userId) {
    return handleExceptions(() async {
      return await remoteDataSource.getFavoriteFoods(userId);
    });
  }

  @override
  Future<Either<Failure, List<Restaurant>>> getFavoriteRestaurants(String userId) {
    return handleExceptions(() async {
      return await remoteDataSource.getFavoriteRestaurants(userId);
    });
  }

  @override
  Future<Either<Failure, void>> addFoodToFavorites(String userId, String foodId) {
    return handleExceptions(() async {
      await remoteDataSource.addFoodToFavorites(userId, foodId);
    });
  }

  @override
  Future<Either<Failure, void>> removeFoodFromFavorites(String userId, String foodId) {
    return handleExceptions(() async {
      await remoteDataSource.removeFoodFromFavorites(userId, foodId);
    });
  }

  @override
  Future<Either<Failure, void>> addRestaurantToFavorites(String userId, String restaurantId) {
    return handleExceptions(() async {
      await remoteDataSource.addRestaurantToFavorites(userId, restaurantId);
    });
  }

  @override
  Future<Either<Failure, void>> removeRestaurantFromFavorites(String userId, String restaurantId) {
    return handleExceptions(() async {
      await remoteDataSource.removeRestaurantFromFavorites(userId, restaurantId);
    });
  }

  @override
  Future<Either<Failure, bool>> isFoodFavorite(String userId, String foodId) {
    return handleExceptions(() async {
      return await remoteDataSource.isFoodFavorite(userId, foodId);
    });
  }

  @override
  Future<Either<Failure, bool>> isRestaurantFavorite(String userId, String restaurantId) {
    return handleExceptions(() async {
      return await remoteDataSource.isRestaurantFavorite(userId, restaurantId);
    });
  }

  @override
  Stream<Either<Failure, List<String>>> watchFavoriteFoodIds(String userId) {
    try {
      return remoteDataSource.watchFavoriteFoodIds(userId).map<Either<Failure, List<String>>>((ids) {
        return Right(ids);
      }).handleError((error) {
        return Stream.value(Left<Failure, List<String>>(ServerFailure(failureMessage: error.toString())));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure(failureMessage: e.toString())));
    }
  }

  @override
  Stream<Either<Failure, List<String>>> watchFavoriteRestaurantIds(String userId) {
    try {
      return remoteDataSource.watchFavoriteRestaurantIds(userId).map<Either<Failure, List<String>>>((ids) {
        return Right(ids);
      }).handleError((error) {
        return Stream.value(Left<Failure, List<String>>(ServerFailure(failureMessage: error.toString())));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure(failureMessage: e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllFavorites(String userId) {
    return handleExceptions(() async {
      await remoteDataSource.clearAllFavorites(userId);
    });
  }
}