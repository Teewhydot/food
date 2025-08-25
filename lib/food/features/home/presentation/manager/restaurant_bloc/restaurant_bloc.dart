import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';

import '../../../domain/entities/restaurant.dart';
import '../../../domain/entities/restaurant_food_category.dart';
import '../../../domain/use_cases/restaurant_usecase.dart';

/// Migrated RestaurantBloc to RestaurantCubit using BaseState
class RestaurantCubit extends BaseCubit<BaseState<dynamic>> {
  final RestaurantUseCase restaurantUseCase;

  RestaurantCubit({required this.restaurantUseCase})
    : super(const InitialState<dynamic>());

  Future<void> getRestaurants() async {
    emit(const LoadingState<List<Restaurant>>(message: 'Loading restaurants...'));
    final result = await restaurantUseCase.getRestaurants();
    result.fold(
      (failure) => emit(
        ErrorState<List<Restaurant>>(
          errorMessage: failure.failureMessage,
          errorCode: 'restaurants_fetch_failed',
          isRetryable: true,
        ),
      ),
      (restaurants) => restaurants.isEmpty
          ? emit(const EmptyState<List<Restaurant>>(message: 'No restaurants available'))
          : emit(
              LoadedState<List<Restaurant>>(
                data: restaurants,
                lastUpdated: DateTime.now(),
              ),
            ),
    );
  }

  Future<void> getNearbyRestaurants(double latitude, double longitude) async {
    emit(const LoadingState<List<Restaurant>>(message: 'Finding nearby restaurants...'));
    final result = await restaurantUseCase.getNearbyRestaurants(
      latitude,
      longitude,
    );
    result.fold(
      (failure) => emit(
        ErrorState<List<Restaurant>>(
          errorMessage: failure.failureMessage,
          errorCode: 'nearby_restaurants_fetch_failed',
          isRetryable: true,
        ),
      ),
      (restaurants) => restaurants.isEmpty
          ? emit(const EmptyState<List<Restaurant>>(message: 'No nearby restaurants found'))
          : emit(
              LoadedState<List<Restaurant>>(
                data: restaurants,
                lastUpdated: DateTime.now(),
              ),
            ),
    );
  }

  Future<void> getPopularRestaurants() async {
    emit(const LoadingState<List<Restaurant>>(message: 'Loading popular restaurants...'));
    final result = await restaurantUseCase.getPopularRestaurants();
    result.fold(
      (failure) => emit(
        ErrorState<List<Restaurant>>(
          errorMessage: failure.failureMessage,
          errorCode: 'popular_restaurants_fetch_failed',
          isRetryable: true,
        ),
      ),
      (restaurants) => restaurants.isEmpty
          ? emit(const EmptyState<List<Restaurant>>(message: 'No popular restaurants available'))
          : emit(
              LoadedState<List<Restaurant>>(
                data: restaurants,
                lastUpdated: DateTime.now(),
              ),
            ),
    );
  }

  Future<void> getRestaurantById(String id) async {
    emit(const LoadingState<Restaurant>(message: 'Loading restaurant details...'));
    final result = await restaurantUseCase.getRestaurantById(id);
    result.fold(
      (failure) => emit(
        ErrorState<Restaurant>(
          errorMessage: failure.failureMessage,
          errorCode: 'restaurant_fetch_failed',
          isRetryable: true,
        ),
      ),
      (restaurant) => emit(
        LoadedState<Restaurant>(
          data: restaurant,
          lastUpdated: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> getRestaurantsByCategory(String category) async {
    emit(LoadingState<List<Restaurant>>(message: 'Loading $category restaurants...'));
    final result = await restaurantUseCase.getRestaurantsByCategory(
      category,
    );
    result.fold(
      (failure) => emit(
        ErrorState<List<Restaurant>>(
          errorMessage: failure.failureMessage,
          errorCode: 'category_restaurants_fetch_failed',
          isRetryable: true,
        ),
      ),
      (restaurants) => restaurants.isEmpty
          ? emit(EmptyState<List<Restaurant>>(message: 'No $category restaurants available'))
          : emit(
              LoadedState<List<Restaurant>>(
                data: restaurants,
                lastUpdated: DateTime.now(),
              ),
            ),
    );
  }

  Future<void> getRestaurantMenu(String restaurantId) async {
    emit(const LoadingState<List<RestaurantFoodCategory>>(message: 'Loading menu...'));
    final result = await restaurantUseCase.getRestaurantMenu(
      restaurantId,
    );
    result.fold(
      (failure) => emit(
        ErrorState<List<RestaurantFoodCategory>>(
          errorMessage: failure.failureMessage,
          errorCode: 'menu_fetch_failed',
          isRetryable: true,
        ),
      ),
      (categories) => categories.isEmpty
          ? emit(const EmptyState<List<RestaurantFoodCategory>>(message: 'Menu not available'))
          : emit(
              LoadedState<List<RestaurantFoodCategory>>(
                data: categories,
                lastUpdated: DateTime.now(),
              ),
            ),
    );
  }
}