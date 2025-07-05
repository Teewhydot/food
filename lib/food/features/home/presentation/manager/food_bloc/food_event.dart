abstract class FoodEvent {
  const FoodEvent();
}

class GetAllFoodsEvent extends FoodEvent {}

class GetPopularFoodsEvent extends FoodEvent {}

class GetFoodsByCategoryEvent extends FoodEvent {
  final String category;

  const GetFoodsByCategoryEvent(this.category);
}

class GetFoodByIdEvent extends FoodEvent {
  final String id;

  const GetFoodByIdEvent(this.id);
}

class GetFoodsByRestaurantEvent extends FoodEvent {
  final String restaurantId;

  const GetFoodsByRestaurantEvent(this.restaurantId);
}

class GetRecommendedFoodsEvent extends FoodEvent {}
