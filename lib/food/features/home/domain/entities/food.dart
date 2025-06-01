import 'package:food/food/features/home/domain/entities/restaurant.dart';

class FoodEntity {
  final String id, name, description, imageUrl, category, restaurantName;
  final double price, rating;
  final Restaurant restaurant;

  FoodEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.category,
    required this.restaurantName,
    required this.restaurant,
  });
}
