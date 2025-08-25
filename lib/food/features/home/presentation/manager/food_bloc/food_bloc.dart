import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';

import '../../../domain/entities/food.dart';
import '../../../domain/use_cases/food_usecase.dart';

/// Migrated FoodBloc to FoodCubit using BaseState<List<FoodEntity>> and BaseState<FoodEntity>
class FoodCubit extends BaseCubit<BaseState<dynamic>> {
  final FoodUseCase foodUseCase;

  FoodCubit({required this.foodUseCase}) : super(const InitialState<dynamic>());

  Future<void> getAllFoods() async {
    emit(const LoadingState<List<FoodEntity>>(message: 'Loading foods...'));
    final result = await foodUseCase.getAllFoods();
    result.fold(
      (failure) => emit(
        ErrorState<List<FoodEntity>>(
          errorMessage: failure.failureMessage,
          errorCode: 'foods_fetch_failed',
          isRetryable: true,
        ),
      ),
      (foods) => foods.isEmpty
          ? emit(const EmptyState<List<FoodEntity>>(message: 'No foods available'))
          : emit(
              LoadedState<List<FoodEntity>>(
                data: foods,
                lastUpdated: DateTime.now(),
              ),
            ),
    );
  }

  Future<void> getPopularFoods() async {
    emit(const LoadingState<List<FoodEntity>>(message: 'Loading popular foods...'));
    final result = await foodUseCase.getPopularFoods();
    result.fold(
      (failure) => emit(
        ErrorState<List<FoodEntity>>(
          errorMessage: failure.failureMessage,
          errorCode: 'popular_foods_fetch_failed',
          isRetryable: true,
        ),
      ),
      (foods) => foods.isEmpty
          ? emit(const EmptyState<List<FoodEntity>>(message: 'No popular foods available'))
          : emit(
              LoadedState<List<FoodEntity>>(
                data: foods,
                lastUpdated: DateTime.now(),
              ),
            ),
    );
  }

  Future<void> getFoodsByCategory(String category) async {
    emit(LoadingState<List<FoodEntity>>(message: 'Loading $category foods...'));
    final result = await foodUseCase.getFoodsByCategory(category);
    result.fold(
      (failure) => emit(
        ErrorState<List<FoodEntity>>(
          errorMessage: failure.failureMessage,
          errorCode: 'category_foods_fetch_failed',
          isRetryable: true,
        ),
      ),
      (foods) => foods.isEmpty
          ? emit(EmptyState<List<FoodEntity>>(message: 'No $category foods available'))
          : emit(
              LoadedState<List<FoodEntity>>(
                data: foods,
                lastUpdated: DateTime.now(),
              ),
            ),
    );
  }

  Future<void> getFoodById(String id) async {
    emit(const LoadingState<FoodEntity>(message: 'Loading food details...'));
    final result = await foodUseCase.getFoodById(id);
    result.fold(
      (failure) => emit(
        ErrorState<FoodEntity>(
          errorMessage: failure.failureMessage,
          errorCode: 'food_fetch_failed',
          isRetryable: true,
        ),
      ),
      (food) => emit(
        LoadedState<FoodEntity>(
          data: food,
          lastUpdated: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> getFoodsByRestaurant(String restaurantId) async {
    emit(const LoadingState<List<FoodEntity>>(message: 'Loading restaurant menu...'));
    final result = await foodUseCase.getFoodsByRestaurant(restaurantId);
    result.fold(
      (failure) => emit(
        ErrorState<List<FoodEntity>>(
          errorMessage: failure.failureMessage,
          errorCode: 'restaurant_foods_fetch_failed',
          isRetryable: true,
        ),
      ),
      (foods) => foods.isEmpty
          ? emit(const EmptyState<List<FoodEntity>>(message: 'No menu items available'))
          : emit(
              LoadedState<List<FoodEntity>>(
                data: foods,
                lastUpdated: DateTime.now(),
              ),
            ),
    );
  }

  Future<void> getRecommendedFoods() async {
    emit(const LoadingState<List<FoodEntity>>(message: 'Loading recommendations...'));
    final result = await foodUseCase.getRecommendedFoods();
    result.fold(
      (failure) => emit(
        ErrorState<List<FoodEntity>>(
          errorMessage: failure.failureMessage,
          errorCode: 'recommended_foods_fetch_failed',
          isRetryable: true,
        ),
      ),
      (foods) => foods.isEmpty
          ? emit(const EmptyState<List<FoodEntity>>(message: 'No recommendations available'))
          : emit(
              LoadedState<List<FoodEntity>>(
                data: foods,
                lastUpdated: DateTime.now(),
              ),
            ),
    );
  }
}