import '../../../../core/services/floor_db_service/food/food_entity.dart';

class FoodEntity extends FoodFloorEntity {
  FoodEntity({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.rating,
    required super.imageUrl,
    required super.category,
    required super.restaurantId,
    required super.restaurantName,
    required super.ingredients,
    required super.isAvailable,
    required super.preparationTime,
    required super.calories,
    super.quantity = 1,
    required super.isVegetarian,
    required super.isVegan,
    required super.isGlutenFree,
    required super.lastUpdated,
  });

  factory FoodEntity.fromMap(Map<String, dynamic> map) {
    return FoodEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      rating: (map['rating'] as num).toDouble(),
      imageUrl: map['imageUrl'] as String,
      category: map['category'] as String,
      quantity: map['quantity'] as int? ?? 1,
      restaurantId: map['restaurantId'] as String,
      restaurantName: map['restaurantName'] as String,
      ingredients: List<String>.from(map['ingredients'] ?? []),
      isAvailable: map['isAvailable'] as bool? ?? true,
      preparationTime: map['preparationTime'] as String? ?? '',
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      isVegetarian: map['isVegetarian'] as bool? ?? false,
      isVegan: map['isVegan'] as bool? ?? false,
      isGlutenFree: map['isGlutenFree'] as bool? ?? false,
      lastUpdated: DateTime.now().millisecondsSinceEpoch, // Default to now
    );
  }

  FoodEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? rating,
    String? imageUrl,
    String? category,
    String? restaurantId,
    String? restaurantName,
    List<String>? ingredients,
    bool? isAvailable,
    String? preparationTime,
    int? calories,
    int? quantity,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
  }) {
    return FoodEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      ingredients: ingredients ?? this.ingredients,
      isAvailable: isAvailable ?? this.isAvailable,
      quantity: quantity ?? this.quantity,
      preparationTime: preparationTime ?? this.preparationTime,
      calories: calories ?? this.calories,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      lastUpdated: lastUpdated,
    );
  }
}
