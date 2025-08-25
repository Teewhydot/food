import '../../../home/domain/entities/food.dart';

/// Entity to hold cart information
class CartEntity {
  final List<FoodEntity> items;
  final double totalPrice;
  final int itemCount;

  const CartEntity({
    required this.items,
    required this.totalPrice,
    required this.itemCount,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  CartEntity copyWith({
    List<FoodEntity>? items,
    double? totalPrice,
    int? itemCount,
  }) {
    return CartEntity(
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}