import 'package:food/food/features/home/domain/entities/food.dart';

class RestaurantFoodCategory {
  final String category;
  final String imageUrl;
  final List<FoodEntity> foods;

  RestaurantFoodCategory({
    required this.category,
    required this.imageUrl,
    required this.foods,
  });
}
