import 'package:meta/meta.dart';

import '../../../../home/domain/entities/food.dart';

/// Enhanced Cart Events using sealed classes
@immutable
sealed class CartEvent {
  const CartEvent();
}

/// Event to start listening to cart stream
@immutable
final class CartStreamStartedEvent extends CartEvent {
  const CartStreamStartedEvent();

  @override
  String toString() => 'CartStreamStartedEvent()';
}

/// Event to add food to cart
@immutable
final class CartAddFoodEvent extends CartEvent {
  final FoodEntity food;

  const CartAddFoodEvent({required this.food});

  @override
  String toString() => 'CartAddFoodEvent(food: ${food.name})';
}

/// Event to remove food from cart (decrease quantity by 1)
@immutable
final class CartRemoveFoodEvent extends CartEvent {
  final String foodId;

  const CartRemoveFoodEvent({required this.foodId});

  @override
  String toString() => 'CartRemoveFoodEvent(foodId: $foodId)';
}

/// Event to update food quantity
@immutable
final class CartUpdateQuantityEvent extends CartEvent {
  final String foodId;
  final int quantity;

  const CartUpdateQuantityEvent({
    required this.foodId,
    required this.quantity,
  });

  @override
  String toString() => 'CartUpdateQuantityEvent(foodId: $foodId, quantity: $quantity)';
}

/// Event to clear cart
@immutable
final class CartClearEvent extends CartEvent {
  const CartClearEvent();

  @override
  String toString() => 'CartClearEvent()';
}

/// Event when cart stream updates
@immutable
final class CartStreamUpdatedEvent extends CartEvent {
  final dynamic cartData; // Either<Failure, CartEntity>

  const CartStreamUpdatedEvent({required this.cartData});

  @override
  String toString() => 'CartStreamUpdatedEvent()';
}