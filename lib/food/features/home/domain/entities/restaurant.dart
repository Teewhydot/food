import 'package:food/food/features/home/domain/entities/restaurant_food_category.dart';

class Restaurant {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final List<RestaurantFoodCategory> categories;
  final double rating, distance;
  final int reviewCount, deliveryTime;

  Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.categories,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTime,
    required this.distance,
  });
}
