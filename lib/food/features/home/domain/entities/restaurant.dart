import 'package:food/food/core/services/floor_db_service/restaurant/restaurant_entity.dart';

class Restaurant extends RestaurantFloorEntity {
  Restaurant({
    required super.id,
    required super.name,
    required super.description,
    required super.location,
    required super.distance,
    required super.rating,
    required super.deliveryTime,
    required super.deliveryFee,
    required super.imageUrl,
    required super.category,
    required super.isOpen,
    required super.latitude,
    required super.longitude,
    required super.lastUpdated,
  });
}
