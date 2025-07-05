import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/use_cases/food_usecase.dart';
import '../../../domain/use_cases/restaurant_usecase.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final FoodUseCase foodUseCase;
  final RestaurantUseCase restaurantUseCase;

  SearchBloc({required this.foodUseCase, required this.restaurantUseCase})
    : super(SearchInitial()) {
    on<SearchFoodsEvent>(_onSearchFoods);
    on<SearchRestaurantsEvent>(_onSearchRestaurants);
    on<SearchAllEvent>(_onSearchAll);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onSearchFoods(
    SearchFoodsEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(SearchEmpty());
      return;
    }

    emit(SearchLoading());
    final result = await foodUseCase.searchFoods(event.query);
    result.fold(
      (failure) => emit(SearchError(failure.failureMessage)),
      (foods) =>
          foods.isEmpty ? emit(SearchEmpty()) : emit(SearchFoodsLoaded(foods)),
    );
  }

  Future<void> _onSearchRestaurants(
    SearchRestaurantsEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(SearchEmpty());
      return;
    }

    emit(SearchLoading());
    final result = await restaurantUseCase.searchRestaurants(event.query);
    result.fold(
      (failure) => emit(SearchError(failure.failureMessage)),
      (restaurants) =>
          restaurants.isEmpty
              ? emit(SearchEmpty())
              : emit(SearchRestaurantsLoaded(restaurants)),
    );
  }

  Future<void> _onSearchAll(
    SearchAllEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(SearchEmpty());
      return;
    }

    emit(SearchLoading());

    final foodsResult = await foodUseCase.searchFoods(event.query);
    final restaurantsResult = await restaurantUseCase.searchRestaurants(
      event.query,
    );

    foodsResult.fold((failure) => emit(SearchError(failure.failureMessage)), (
      foods,
    ) {
      restaurantsResult.fold(
        (failure) => emit(SearchError(failure.failureMessage)),
        (restaurants) {
          if (foods.isEmpty && restaurants.isEmpty) {
            emit(SearchEmpty());
          } else {
            emit(SearchAllLoaded(foods: foods, restaurants: restaurants));
          }
        },
      );
    });
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
}
