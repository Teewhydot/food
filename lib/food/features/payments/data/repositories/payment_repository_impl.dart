import 'package:dartz/dartz.dart';
import 'package:food/food/core/utils/handle_exceptions.dart';
import 'package:food/food/domain/failures/failures.dart';
import '../../domain/entities/card_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../remote/data_sources/order_remote_data_source.dart';
import '../remote/data_sources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource paymentRemoteDataSource;
  final OrderRemoteDataSource orderRemoteDataSource;

  PaymentRepositoryImpl({
    required this.paymentRemoteDataSource,
    required this.orderRemoteDataSource,
  });

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods() {
    return handleExceptions(() async {
      return await paymentRemoteDataSource.getPaymentMethods();
    });
  }

  @override
  Future<Either<Failure, List<CardEntity>>> getSavedCards(String userId) {
    return handleExceptions(() async {
      return await paymentRemoteDataSource.getSavedCards(userId);
    });
  }

  @override
  Future<Either<Failure, CardEntity>> saveCard(CardEntity card) {
    return handleExceptions(() async {
      return await paymentRemoteDataSource.saveCard(card);
    });
  }

  @override
  Future<Either<Failure, void>> deleteCard(String cardId) {
    return handleExceptions(() async {
      await paymentRemoteDataSource.deleteCard(cardId);
    });
  }

  @override
  Future<Either<Failure, String>> processPayment({
    required String paymentMethodId,
    required double amount,
    required String currency,
    required Map<String, dynamic> metadata,
  }) {
    return handleExceptions(() async {
      return await paymentRemoteDataSource.processPayment(
        paymentMethodId: paymentMethodId,
        amount: amount,
        currency: currency,
        metadata: metadata,
      );
    });
  }

  @override
  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order) {
    return handleExceptions(() async {
      return await orderRemoteDataSource.createOrder(order);
    });
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getUserOrders(String userId) {
    return handleExceptions(() async {
      return await orderRemoteDataSource.getUserOrders(userId);
    });
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) {
    return handleExceptions(() async {
      return await orderRemoteDataSource.getOrderById(orderId);
    });
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) {
    return handleExceptions(() async {
      return await orderRemoteDataSource.updateOrderStatus(orderId, status);
    });
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String orderId) {
    return handleExceptions(() async {
      await orderRemoteDataSource.cancelOrder(orderId);
    });
  }
}