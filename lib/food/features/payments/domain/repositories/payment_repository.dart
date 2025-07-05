import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';
import '../entities/card_entity.dart';
import '../entities/order_entity.dart';
import '../entities/payment_method_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods();
  Future<Either<Failure, List<CardEntity>>> getSavedCards(String userId);
  Future<Either<Failure, CardEntity>> saveCard(CardEntity card);
  Future<Either<Failure, void>> deleteCard(String cardId);
  Future<Either<Failure, String>> processPayment({
    required String paymentMethodId,
    required double amount,
    required String currency,
    required Map<String, dynamic> metadata,
  });
  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order);
  Future<Either<Failure, List<OrderEntity>>> getUserOrders(String userId);
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);
  Future<Either<Failure, OrderEntity>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  );
  Future<Either<Failure, void>> cancelOrder(String orderId);
}