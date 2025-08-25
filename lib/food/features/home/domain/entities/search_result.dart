import 'food.dart';
import 'restaurant.dart';

/// Entity to hold combined search results
class SearchResultEntity {
  final List<FoodEntity> foods;
  final List<Restaurant> restaurants;

  const SearchResultEntity({
    required this.foods,
    required this.restaurants,
  });

  bool get isEmpty => foods.isEmpty && restaurants.isEmpty;
  bool get hasResults => !isEmpty;
  int get totalResults => foods.length + restaurants.length;
}