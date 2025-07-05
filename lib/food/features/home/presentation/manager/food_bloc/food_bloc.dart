import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/use_cases/food_usecase.dart';
import 'food_event.dart';
import 'food_state.dart';

class FoodBloc extends Bloc<FoodEvent, FoodState> {
  final FoodUseCase foodUseCase;

  FoodBloc({required this.foodUseCase}) : super(FoodInitial()) {
    on<GetAllFoodsEvent>(_onGetAllFoods);
    on<GetPopularFoodsEvent>(_onGetPopularFoods);
    on<GetFoodsByCategoryEvent>(_onGetFoodsByCategory);
    on<GetFoodByIdEvent>(_onGetFoodById);
    on<GetFoodsByRestaurantEvent>(_onGetFoodsByRestaurant);
    on<GetRecommendedFoodsEvent>(_onGetRecommendedFoods);
  }

  Future<void> _onGetAllFoods(
    GetAllFoodsEvent event,
    Emitter<FoodState> emit,
  ) async {
    emit(FoodLoading());
    final result = await foodUseCase.getAllFoods();
    result.fold(
      (failure) => emit(FoodError(failure.failureMessage)),
      (foods) => emit(FoodsLoaded(foods)),
    );
  }

  Future<void> _onGetPopularFoods(
    GetPopularFoodsEvent event,
    Emitter<FoodState> emit,
  ) async {
    emit(FoodLoading());
    final result = await foodUseCase.getPopularFoods();
    result.fold(
      (failure) => emit(FoodError(failure.failureMessage)),
      (foods) => emit(FoodsLoaded(foods)),
    );
  }

  Future<void> _onGetFoodsByCategory(
    GetFoodsByCategoryEvent event,
    Emitter<FoodState> emit,
  ) async {
    emit(FoodLoading());
    final result = await foodUseCase.getFoodsByCategory(event.category);
    result.fold(
      (failure) => emit(FoodError(failure.failureMessage)),
      (foods) => emit(FoodsLoaded(foods)),
    );
  }

  Future<void> _onGetFoodById(
    GetFoodByIdEvent event,
    Emitter<FoodState> emit,
  ) async {
    emit(FoodLoading());
    final result = await foodUseCase.getFoodById(event.id);
    result.fold(
      (failure) => emit(FoodError(failure.failureMessage)),
      (food) => emit(FoodLoaded(food)),
    );
  }

  Future<void> _onGetFoodsByRestaurant(
    GetFoodsByRestaurantEvent event,
    Emitter<FoodState> emit,
  ) async {
    emit(FoodLoading());
    final result = await foodUseCase.getFoodsByRestaurant(event.restaurantId);
    result.fold(
      (failure) => emit(FoodError(failure.failureMessage)),
      (foods) => emit(FoodsLoaded(foods)),
    );
  }

  Future<void> _onGetRecommendedFoods(
    GetRecommendedFoodsEvent event,
    Emitter<FoodState> emit,
  ) async {
    emit(FoodLoading());
    final result = await foodUseCase.getRecommendedFoods();
    result.fold(
      (failure) => emit(FoodError(failure.failureMessage)),
      (foods) => emit(FoodsLoaded(foods)),
    );
  }
}
