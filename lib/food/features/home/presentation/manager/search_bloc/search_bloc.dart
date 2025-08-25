import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';

import '../../../domain/entities/food.dart';
import '../../../domain/entities/restaurant.dart';
import '../../../domain/entities/search_result.dart';
import '../../../domain/use_cases/food_usecase.dart';
import '../../../domain/use_cases/restaurant_usecase.dart';
import 'search_event.dart';
// import 'search_state.dart'; // Commented out - using BaseState now

/// Migrated SearchBloc to use BaseState
class SearchBloc extends BaseBloC<SearchEvent, BaseState<dynamic>> {
  final FoodUseCase foodUseCase;
  final RestaurantUseCase restaurantUseCase;

  SearchBloc({required this.foodUseCase, required this.restaurantUseCase})
    : super(const InitialState<dynamic>()) {
    on<SearchFoodsEvent>(_onSearchFoods);
    on<SearchRestaurantsEvent>(_onSearchRestaurants);
    on<SearchAllEvent>(_onSearchAll);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onSearchFoods(
    SearchFoodsEvent event,
    Emitter<BaseState<dynamic>> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(const EmptyState<List<FoodEntity>>(message: 'Enter a search term'));
      return;
    }

    emit(LoadingState<List<FoodEntity>>(message: 'Searching for "${event.query}"...'));
    final result = await foodUseCase.searchFoods(event.query);
    result.fold(
      (failure) => emit(
        ErrorState<List<FoodEntity>>(
          errorMessage: failure.failureMessage,
          errorCode: 'search_foods_failed',
          isRetryable: true,
        ),
      ),
      (foods) => foods.isEmpty
          ? emit(EmptyState<List<FoodEntity>>(message: 'No foods found for "${event.query}"'))
          : emit(
              LoadedState<List<FoodEntity>>(
                data: foods,
                lastUpdated: DateTime.now(),
              ),
            ),
    );
  }

  Future<void> _onSearchRestaurants(
    SearchRestaurantsEvent event,
    Emitter<BaseState<dynamic>> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(const EmptyState<List<Restaurant>>(message: 'Enter a search term'));
      return;
    }

    emit(LoadingState<List<Restaurant>>(message: 'Searching for "${event.query}"...'));
    final result = await restaurantUseCase.searchRestaurants(event.query);
    result.fold(
      (failure) => emit(
        ErrorState<List<Restaurant>>(
          errorMessage: failure.failureMessage,
          errorCode: 'search_restaurants_failed',
          isRetryable: true,
        ),
      ),
      (restaurants) => restaurants.isEmpty
          ? emit(EmptyState<List<Restaurant>>(message: 'No restaurants found for "${event.query}"'))
          : emit(
              LoadedState<List<Restaurant>>(
                data: restaurants,
                lastUpdated: DateTime.now(),
              ),
            ),
    );
  }

  Future<void> _onSearchAll(
    SearchAllEvent event,
    Emitter<BaseState<dynamic>> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(const EmptyState<SearchResultEntity>(message: 'Enter a search term'));
      return;
    }

    emit(LoadingState<SearchResultEntity>(message: 'Searching for "${event.query}"...'));

    final foodsResult = await foodUseCase.searchFoods(event.query);
    final restaurantsResult = await restaurantUseCase.searchRestaurants(
      event.query,
    );

    foodsResult.fold(
      (failure) => emit(
        ErrorState<SearchResultEntity>(
          errorMessage: failure.failureMessage,
          errorCode: 'search_all_failed',
          isRetryable: true,
        ),
      ),
      (foods) {
        restaurantsResult.fold(
          (failure) => emit(
            ErrorState<SearchResultEntity>(
              errorMessage: failure.failureMessage,
              errorCode: 'search_all_failed',
              isRetryable: true,
            ),
          ),
          (restaurants) {
            final searchResult = SearchResultEntity(
              foods: foods,
              restaurants: restaurants,
            );
            
            if (searchResult.isEmpty) {
              emit(EmptyState<SearchResultEntity>(message: 'No results found for "${event.query}"'));
            } else {
              emit(
                LoadedState<SearchResultEntity>(
                  data: searchResult,
                  lastUpdated: DateTime.now(),
                ),
              );
            }
          },
        );
      },
    );
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<BaseState<dynamic>> emit) {
    emit(const InitialState<dynamic>());
  }
}
