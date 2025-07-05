abstract class RestaurantEvent {
  const RestaurantEvent();
}

class GetRestaurantsEvent extends RestaurantEvent {}

class GetNearbyRestaurantsEvent extends RestaurantEvent {
  final double latitude;
  final double longitude;

  const GetNearbyRestaurantsEvent({
    required this.latitude,
    required this.longitude,
  });
}

class GetPopularRestaurantsEvent extends RestaurantEvent {}

class GetRestaurantByIdEvent extends RestaurantEvent {
  final String id;

  const GetRestaurantByIdEvent(this.id);
}

class GetRestaurantsByCategoryEvent extends RestaurantEvent {
  final String category;

  const GetRestaurantsByCategoryEvent(this.category);
}

class GetRestaurantMenuEvent extends RestaurantEvent {
  final String restaurantId;

  const GetRestaurantMenuEvent(this.restaurantId);
}
