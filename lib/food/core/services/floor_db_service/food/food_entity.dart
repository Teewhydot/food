import 'package:floor/floor.dart';
import '../converters/string_list_converter.dart';

@Entity(tableName: 'foods')
@TypeConverters([StringListConverter])
class FoodFloorEntity {
  @PrimaryKey()
  final String id;
  final String name;
  final String description;
  final double price;
  final double rating;
  final String imageUrl;
  final String category;
  final String restaurantId;
  final String restaurantName;
  final List<String> ingredients; // JSON string
  final bool isAvailable;
  final String preparationTime;
  int calories, quantity;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final int lastUpdated;

  FoodFloorEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.category,
    required this.restaurantId,
    required this.restaurantName,
    required this.ingredients,
    required this.isAvailable,
    required this.preparationTime,
    required this.calories,
    required this.quantity,
    required this.isVegetarian,
    required this.isVegan,
    required this.isGlutenFree,
    required this.lastUpdated,
  });
}
