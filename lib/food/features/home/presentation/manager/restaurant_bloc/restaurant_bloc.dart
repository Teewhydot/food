import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/use_cases/restaurant_usecase.dart';
import 'restaurant_event.dart';
import 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final RestaurantUseCase restaurantUseCase;

  RestaurantBloc({required this.restaurantUseCase})
    : super(RestaurantInitial()) {
    on<GetRestaurantsEvent>(_onGetRestaurants);
    on<GetNearbyRestaurantsEvent>(_onGetNearbyRestaurants);
    on<GetPopularRestaurantsEvent>(_onGetPopularRestaurants);
    on<GetRestaurantByIdEvent>(_onGetRestaurantById);
    on<GetRestaurantsByCategoryEvent>(_onGetRestaurantsByCategory);
    on<GetRestaurantMenuEvent>(_onGetRestaurantMenu);
  }

  Future<void> _onGetRestaurants(
    GetRestaurantsEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantLoading());
    final result = await restaurantUseCase.getRestaurants();
    result.fold(
      (failure) => emit(RestaurantError(failure.failureMessage)),
      (restaurants) => emit(RestaurantsLoaded(restaurants)),
    );
  }

  Future<void> _onGetNearbyRestaurants(
    GetNearbyRestaurantsEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantLoading());
    final result = await restaurantUseCase.getNearbyRestaurants(
      event.latitude,
      event.longitude,
    );
    result.fold(
      (failure) => emit(RestaurantError(failure.failureMessage)),
      (restaurants) => emit(RestaurantsLoaded(restaurants)),
    );
  }

  Future<void> _onGetPopularRestaurants(
    GetPopularRestaurantsEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantLoading());
    final result = await restaurantUseCase.getPopularRestaurants();
    result.fold(
      (failure) => emit(RestaurantError(failure.failureMessage)),
      (restaurants) => emit(RestaurantsLoaded(restaurants)),
    );
  }

  Future<void> _onGetRestaurantById(
    GetRestaurantByIdEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantLoading());
    final result = await restaurantUseCase.getRestaurantById(event.id);
    result.fold(
      (failure) => emit(RestaurantError(failure.failureMessage)),
      (restaurant) => emit(RestaurantLoaded(restaurant)),
    );
  }

  Future<void> _onGetRestaurantsByCategory(
    GetRestaurantsByCategoryEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantLoading());
    final result = await restaurantUseCase.getRestaurantsByCategory(
      event.category,
    );
    result.fold(
      (failure) => emit(RestaurantError(failure.failureMessage)),
      (restaurants) => emit(RestaurantsLoaded(restaurants)),
    );
  }

  Future<void> _onGetRestaurantMenu(
    GetRestaurantMenuEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantLoading());
    final result = await restaurantUseCase.getRestaurantMenu(
      event.restaurantId,
    );
    result.fold(
      (failure) => emit(RestaurantError(failure.failureMessage)),
      (categories) => emit(RestaurantMenuLoaded(categories)),
    );
  }
}
