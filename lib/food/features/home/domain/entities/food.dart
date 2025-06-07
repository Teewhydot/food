import 'package:food/food/features/home/domain/entities/restaurant.dart';

class FoodEntity {
  final String id, name, description, imageUrl, category, restaurantName;
  final double price, rating;
  int quantity; // Default quantity set to 1
  final Restaurant? restaurant;

  FoodEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.category,
    required this.restaurantName,
    this.restaurant,
    this.quantity = 1,
  });

  FoodEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    double? rating,
    String? category,
    String? restaurantName,
    Restaurant? restaurant,
    int? quantity,
  }) {
    return FoodEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurant: restaurant ?? this.restaurant,
      quantity: quantity ?? this.quantity,
    );
  }
}
