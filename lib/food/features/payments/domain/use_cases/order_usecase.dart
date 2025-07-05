import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/payment_repository.dart';

class OrderUseCase {
  final PaymentRepository repository;

  OrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order) async {
    return await repository.createOrder(order);
  }

  Future<Either<Failure, List<OrderEntity>>> getUserOrders(String userId) async {
    return await repository.getUserOrders(userId);
  }

  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    return await repository.getOrderById(orderId);
  }

  Future<Either<Failure, OrderEntity>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    return await repository.updateOrderStatus(orderId, status);
  }

  Future<Either<Failure, void>> cancelOrder(String orderId) async {
    return await repository.cancelOrder(orderId);
  }
}