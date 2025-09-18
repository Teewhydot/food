import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../domain/failures/failures.dart';
import '../../../home/domain/entities/food.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../remote/data_sources/cart_remote_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final cartRemoteDataSource = GetIt.instance<CartRemoteDataSource>();

  @override
  Stream<Either<Failure, CartEntity>> getCartStream() async* {
    try {
      await for (final cartEntity in cartRemoteDataSource.getCartStream()) {
        yield Right<Failure, CartEntity>(cartEntity);
      }
    } catch (error) {
      yield Left<Failure, CartEntity>(
        UnknownFailure(failureMessage: 'Failed to get cart stream: ${error.toString()}')
      );
    }
  }

  @override
  Future<Either<Failure, void>> addFoodToCart(FoodEntity food) {
    return ErrorHandler.handle(
      () async => await cartRemoteDataSource.addFoodToCart(food),
      operationName: 'Add Food to Cart',
    );
  }

  @override
  Future<Either<Failure, void>> removeFoodFromCart(String foodId) {
    return ErrorHandler.handle(
      () async => await cartRemoteDataSource.removeFoodFromCart(foodId),
      operationName: 'Remove Food from Cart',
    );
  }

  @override
  Future<Either<Failure, void>> updateFoodQuantity(String foodId, int quantity) {
    return ErrorHandler.handle(
      () async => await cartRemoteDataSource.updateFoodQuantity(foodId, quantity),
      operationName: 'Update Food Quantity',
    );
  }

  @override
  Future<Either<Failure, void>> clearCart() {
    return ErrorHandler.handle(
      () async => await cartRemoteDataSource.clearCart(),
      operationName: 'Clear Cart',
    );
  }

  @override
  Future<Either<Failure, CartEntity>> getCurrentCart() {
    return ErrorHandler.handle(
      () async => await cartRemoteDataSource.getCurrentCart(),
      operationName: 'Get Current Cart',
    );
  }
}