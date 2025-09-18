import 'package:dartz/dartz.dart';

import '../../../../domain/failures/failures.dart';
import '../../../home/domain/entities/food.dart';
import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';
import '../../data/repositories/cart_repository_impl.dart';

class CartUseCase {
  final CartRepository cartRepo = CartRepositoryImpl();

  /// Get real-time cart stream from Firebase
  Stream<Either<Failure, CartEntity>> getCartStream() {
    return cartRepo.getCartStream();
  }

  /// Add food item to cart
  Future<Either<Failure, void>> addFoodToCart(FoodEntity food) {
    if (food.id.isEmpty) {
      return Future.value(Left(ValidationFailure(
        failureMessage: 'Food ID cannot be empty'
      )));
    }
    return cartRepo.addFoodToCart(food);
  }

  /// Remove food item from cart (decreases quantity by 1)
  Future<Either<Failure, void>> removeFoodFromCart(String foodId) {
    if (foodId.isEmpty) {
      return Future.value(Left(ValidationFailure(
        failureMessage: 'Food ID cannot be empty'
      )));
    }
    return cartRepo.removeFoodFromCart(foodId);
  }

  /// Update food quantity in cart
  Future<Either<Failure, void>> updateFoodQuantity(String foodId, int quantity) {
    if (foodId.isEmpty) {
      return Future.value(Left(ValidationFailure(
        failureMessage: 'Food ID cannot be empty'
      )));
    }
    if (quantity < 0) {
      return Future.value(Left(ValidationFailure(
        failureMessage: 'Quantity cannot be negative'
      )));
    }
    return cartRepo.updateFoodQuantity(foodId, quantity);
  }

  /// Clear all items from cart
  Future<Either<Failure, void>> clearCart() {
    return cartRepo.clearCart();
  }

  /// Get current cart state (one-time fetch)
  Future<Either<Failure, CartEntity>> getCurrentCart() {
    return cartRepo.getCurrentCart();
  }
}