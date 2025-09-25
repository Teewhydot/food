import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';

import '../entities/order_entity.dart';

abstract class OrderRepository {
  Stream<Either<Failure, List<OrderEntity>>> streamUserOrders(String userId);
  Stream<Either<Failure, OrderEntity?>> streamOrderById(String orderId);
  Future<Either<Failure, void>> cancelOrder(String orderId);
}
