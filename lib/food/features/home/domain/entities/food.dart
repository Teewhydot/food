class FoodEntity {
  final String id, name, description, imageUrl, category, restaurantName;
  final double price, rating;

  FoodEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.category,
    required this.restaurantName,
  });
}
