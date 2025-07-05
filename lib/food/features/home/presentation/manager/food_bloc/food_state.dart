import 'package:food/food/core/bloc/app_state.dart';

import '../../../domain/entities/food.dart';

abstract class FoodState {
  const FoodState();
}

class FoodInitial extends FoodState {}

class FoodLoading extends FoodState {}

class FoodsLoaded extends FoodState {
  final List<FoodEntity> foods;

  const FoodsLoaded(this.foods);
}

class FoodLoaded extends FoodState {
  final FoodEntity food;

  const FoodLoaded(this.food);
}

class FoodError extends FoodState implements AppErrorState {
  @override
  final String errorMessage;

  const FoodError(this.errorMessage);
}
