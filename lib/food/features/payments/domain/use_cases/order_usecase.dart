import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/payments/data/repositories/orders_repository_impl.dart';

import '../entities/order_entity.dart';

class OrderUseCase {
  final repository = OrderRepositoryImpl();

  Stream<Either<Failure, List<OrderEntity>>> streamUserOrders(String userId) {
    return repository.streamUserOrders(userId);
  }

  Future<Either<Failure, void>> cancelOrder(String orderId) async {
    return await repository.cancelOrder(orderId);
  }
}
