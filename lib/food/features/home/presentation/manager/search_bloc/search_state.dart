import '../../../domain/entities/food.dart';
import '../../../domain/entities/restaurant.dart';

abstract class SearchState {
  const SearchState();
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchFoodsLoaded extends SearchState {
  final List<FoodEntity> foods;

  const SearchFoodsLoaded(this.foods);
}

class SearchRestaurantsLoaded extends SearchState {
  final List<Restaurant> restaurants;

  const SearchRestaurantsLoaded(this.restaurants);
}

class SearchAllLoaded extends SearchState {
  final List<FoodEntity> foods;
  final List<Restaurant> restaurants;

  const SearchAllLoaded({required this.foods, required this.restaurants});
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);
}

class SearchEmpty extends SearchState {}
