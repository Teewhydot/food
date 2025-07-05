import 'dart:convert';

import 'package:floor/floor.dart';

import '../../../../features/home/domain/entities/food.dart';
import '../../../../features/home/domain/entities/restaurant_food_category.dart';

class RestaurantCategoryConverter
    extends TypeConverter<List<RestaurantFoodCategory>, String> {
  @override
  List<RestaurantFoodCategory> decode(String databaseValue) {
    final List<dynamic> jsonList = json.decode(databaseValue);
    return jsonList.map((json) => _categoryFromJson(json)).toList();
  }

  @override
  String encode(List<RestaurantFoodCategory> value) {
    final jsonList =
        value.map((category) => _categoryToJson(category)).toList();
    return json.encode(jsonList);
  }

  Map<String, dynamic> _categoryToJson(RestaurantFoodCategory category) {
    return {
      'category': category.category,
      'imageUrl': category.imageUrl,
      'foods': category.foods.map((food) => _foodToJson(food)).toList(),
    };
  }

  RestaurantFoodCategory _categoryFromJson(Map<String, dynamic> json) {
    return RestaurantFoodCategory(
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      foods:
          (json['foods'] as List)
              .map((foodJson) => _foodFromJson(foodJson))
              .toList(),
    );
  }

  Map<String, dynamic> _foodToJson(FoodEntity food) {
    return {
      'id': food.id,
      'name': food.name,
      'description': food.description,
      'price': food.price,
      'imageUrl': food.imageUrl,
      'category': food.category,
      'ingredients': food.ingredients,
      'rating': food.rating,
      'isAvailable': food.isAvailable,
      'preparationTime': food.preparationTime,
      'isVegetarian': food.isVegetarian,
      'isVegan': food.isVegan,
      'isGlutenFree': food.isGlutenFree,
    };
  }

  FoodEntity _foodFromJson(Map<String, dynamic> json) {
    return FoodEntity(
      id: json['id'] as String,
      calories: (json['calories'] as int),
      name: json['name'] as String,
      isGlutenFree: json['isGlutenFree'] as bool? ?? false,
      lastUpdated: 1,
      restaurantId: json['restaurantId'] as String? ?? '',
      restaurantName: json['restaurantName'] as String? ?? '',
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      ingredients: List<String>.from(json['ingredients'] ?? []),
      rating: (json['rating'] as num).toDouble(),
      isAvailable: json['isAvailable'] as bool,
      quantity: json['quantity'] as int? ?? 0,
      preparationTime: json['preparationTime'] as String ?? '',
      isVegetarian: json['isVegetarian'] as bool? ?? false,
      isVegan: json['isVegan'] as bool? ?? false,
    );
  }
}
