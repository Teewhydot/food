import 'package:floor/floor.dart';

import '../../../../features/home/domain/entities/restaurant_food_category.dart';
import '../converters/restaurant_category_converter.dart';

@Entity(tableName: 'restaurants')
@TypeConverters([RestaurantCategoryConverter])
class RestaurantFloorEntity {
  @PrimaryKey()
  final String id;
  final String name;
  final String description;
  final String location;
  final double distance;
  final double rating;
  final String deliveryTime;
  final double deliveryFee;
  final String imageUrl;
  final List<RestaurantFoodCategory> category;
  final bool isOpen;
  final double latitude;
  final double longitude;
  final int lastUpdated;

  RestaurantFloorEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.distance,
    required this.rating,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.imageUrl,
    required this.category,
    required this.isOpen,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
  });
}
