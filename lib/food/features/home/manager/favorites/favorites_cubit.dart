import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import '../../../../domain/failures/failures.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/use_cases/favorites_usecase.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesUseCase _favoritesUseCase;
  final FirebaseAuth _auth;
  
  StreamSubscription<Either<Failure, List<String>>>? _favoriteFoodsSubscription;
  StreamSubscription<Either<Failure, List<String>>>? _favoriteRestaurantsSubscription;

  FavoritesCubit(this._favoritesUseCase, {FirebaseAuth? auth}) 
      : _auth = auth ?? FirebaseAuth.instance,
        super(FavoritesState.initial());

  void initializeFavorites() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    loadFavorites(userId);
    _watchFavorites(userId);
  }

  void loadFavorites(String userId) async {
    emit(state.copyWith(isLoading: true));

    // Load favorite foods
    final favoriteFoodsResult = await _favoritesUseCase.getFavoriteFoods(userId);
    favoriteFoodsResult.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.failureMessage,
      )),
      (foods) => emit(state.copyWith(favoriteFoods: foods)),
    );

    // Load favorite restaurants
    final favoriteRestaurantsResult = await _favoritesUseCase.getFavoriteRestaurants(userId);
    favoriteRestaurantsResult.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.failureMessage,
      )),
      (restaurants) => emit(state.copyWith(
        favoriteRestaurants: restaurants,
        isLoading: false,
      )),
    );
  }

  void _watchFavorites(String userId) {
    // Watch favorite food IDs
    final favoriteFoodsStream = _favoritesUseCase.watchFavoriteFoodIds(userId);
    _favoriteFoodsSubscription = favoriteFoodsStream.listen((result) {
      result.fold(
        (failure) => emit(state.copyWith(errorMessage: failure.failureMessage)),
        (foodIds) => emit(state.copyWith(favoriteFoodIds: foodIds)),
      );
    });

    // Watch favorite restaurant IDs
    final favoriteRestaurantsStream = _favoritesUseCase.watchFavoriteRestaurantIds(userId);
    _favoriteRestaurantsSubscription = favoriteRestaurantsStream.listen((result) {
      result.fold(
        (failure) => emit(state.copyWith(errorMessage: failure.failureMessage)),
        (restaurantIds) => emit(state.copyWith(favoriteRestaurantIds: restaurantIds)),
      );
    });
  }

  Future<void> toggleFoodFavorite(String foodId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final result = await _favoritesUseCase.toggleFoodFavorite(userId, foodId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.failureMessage)),
      (_) {
        // The real-time listener will update the state
        emit(state.copyWith(successMessage: 'Favorites updated successfully'));
      },
    );
  }

  Future<void> toggleRestaurantFavorite(String restaurantId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final result = await _favoritesUseCase.toggleRestaurantFavorite(userId, restaurantId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.failureMessage)),
      (_) {
        // The real-time listener will update the state
        emit(state.copyWith(successMessage: 'Favorites updated successfully'));
      },
    );
  }

  Future<void> addFoodToFavorites(String foodId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final result = await _favoritesUseCase.addFoodToFavorites(userId, foodId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.failureMessage)),
      (_) => emit(state.copyWith(successMessage: 'Added to favorites')),
    );
  }

  Future<void> removeFoodFromFavorites(String foodId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final result = await _favoritesUseCase.removeFoodFromFavorites(userId, foodId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.failureMessage)),
      (_) => emit(state.copyWith(successMessage: 'Removed from favorites')),
    );
  }

  Future<void> addRestaurantToFavorites(String restaurantId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final result = await _favoritesUseCase.addRestaurantToFavorites(userId, restaurantId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.failureMessage)),
      (_) => emit(state.copyWith(successMessage: 'Added to favorites')),
    );
  }

  Future<void> removeRestaurantFromFavorites(String restaurantId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final result = await _favoritesUseCase.removeRestaurantFromFavorites(userId, restaurantId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.failureMessage)),
      (_) => emit(state.copyWith(successMessage: 'Removed from favorites')),
    );
  }

  Future<void> clearAllFavorites() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    emit(state.copyWith(isLoading: true));

    final result = await _favoritesUseCase.clearAllFavorites(userId);
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        errorMessage: failure.failureMessage,
      )),
      (_) => emit(state.copyWith(
        isLoading: false,
        favoriteFoods: [],
        favoriteRestaurants: [],
        favoriteFoodIds: [],
        favoriteRestaurantIds: [],
        successMessage: 'All favorites cleared',
      )),
    );
  }

  Future<void> getFavoritesStats() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final result = await _favoritesUseCase.getFavoritesStats(userId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.failureMessage)),
      (stats) => emit(state.copyWith(favoritesStats: stats)),
    );
  }

  bool isFoodFavorite(String foodId) {
    return state.favoriteFoodIds.contains(foodId);
  }

  bool isRestaurantFavorite(String restaurantId) {
    return state.favoriteRestaurantIds.contains(restaurantId);
  }

  void clearMessages() {
    emit(state.copyWith(
      errorMessage: null,
      successMessage: null,
    ));
  }

  @override
  Future<void> close() {
    _favoriteFoodsSubscription?.cancel();
    _favoriteRestaurantsSubscription?.cancel();
    return super.close();
  }
}