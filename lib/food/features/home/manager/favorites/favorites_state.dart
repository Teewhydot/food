import 'package:equatable/equatable.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/restaurant.dart';

class FavoritesState extends Equatable {
  final List<FoodEntity> favoriteFoods;
  final List<Restaurant> favoriteRestaurants;
  final List<String> favoriteFoodIds;
  final List<String> favoriteRestaurantIds;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final Map<String, dynamic>? favoritesStats;

  const FavoritesState({
    required this.favoriteFoods,
    required this.favoriteRestaurants,
    required this.favoriteFoodIds,
    required this.favoriteRestaurantIds,
    required this.isLoading,
    this.errorMessage,
    this.successMessage,
    this.favoritesStats,
  });

  factory FavoritesState.initial() {
    return const FavoritesState(
      favoriteFoods: [],
      favoriteRestaurants: [],
      favoriteFoodIds: [],
      favoriteRestaurantIds: [],
      isLoading: false,
      errorMessage: null,
      successMessage: null,
      favoritesStats: null,
    );
  }

  FavoritesState copyWith({
    List<FoodEntity>? favoriteFoods,
    List<Restaurant>? favoriteRestaurants,
    List<String>? favoriteFoodIds,
    List<String>? favoriteRestaurantIds,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    Map<String, dynamic>? favoritesStats,
  }) {
    return FavoritesState(
      favoriteFoods: favoriteFoods ?? this.favoriteFoods,
      favoriteRestaurants: favoriteRestaurants ?? this.favoriteRestaurants,
      favoriteFoodIds: favoriteFoodIds ?? this.favoriteFoodIds,
      favoriteRestaurantIds: favoriteRestaurantIds ?? this.favoriteRestaurantIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      favoritesStats: favoritesStats ?? this.favoritesStats,
    );
  }

  bool get hasFavorites => favoriteFoods.isNotEmpty || favoriteRestaurants.isNotEmpty;
  
  int get totalFavoritesCount => favoriteFoods.length + favoriteRestaurants.length;

  @override
  List<Object?> get props => [
        favoriteFoods,
        favoriteRestaurants,
        favoriteFoodIds,
        favoriteRestaurantIds,
        isLoading,
        errorMessage,
        successMessage,
        favoritesStats,
      ];
}