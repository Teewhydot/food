import 'package:dartz/dartz.dart';

import '../../../../domain/failures/failures.dart';
import '../entities/cart_entity.dart';
import '../../../home/domain/entities/food.dart';

abstract class CartRepository {
  Stream<Either<Failure, CartEntity>> getCartStream();
  Future<Either<Failure, void>> addFoodToCart(FoodEntity food);
  Future<Either<Failure, void>> removeFoodFromCart(String foodId);
  Future<Either<Failure, void>> updateFoodQuantity(String foodId, int quantity);
  Future<Either<Failure, void>> clearCart();
  Future<Either<Failure, CartEntity>> getCurrentCart();
}