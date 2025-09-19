import 'package:dartz/dartz.dart';
import '../../../../domain/failures/failures.dart';
import '../../domain/entities/paystack_transaction_entity.dart';
import '../../domain/repositories/paystack_payment_repository.dart';
import '../remote/data_sources/paystack_payment_data_source.dart';

class PaystackPaymentRepositoryImpl implements PaystackPaymentRepository {
  final PaystackPaymentDataSource _paystackDataSource;

  PaystackPaymentRepositoryImpl(this._paystackDataSource);

  @override
  Future<Either<Failure, PaystackTransactionEntity>> initializePayment({
    required String orderId,
    required double amount,
    required String email,
    required Map<String, dynamic>? metadata,
  }) async {
    try {
      final result = await _paystackDataSource.initializePayment(
        orderId: orderId,
        amount: amount,
        email: email,
        metadata: metadata,
      );

      final transaction = PaystackTransactionEntity.fromJson(result);
      return Right(transaction);
    } catch (e) {
      return Left(ServerFailure(failureMessage: 'Failed to initialize payment: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PaystackTransactionEntity>> verifyPayment({
    required String reference,
    required String orderId,
  }) async {
    try {
      final result = await _paystackDataSource.verifyPayment(
        reference: reference,
        orderId: orderId,
      );

      final transaction = PaystackTransactionEntity.fromJson(result);
      return Right(transaction);
    } catch (e) {
      return Left(ServerFailure(failureMessage: 'Failed to verify payment: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PaystackTransactionEntity>> getTransactionStatus({
    required String reference,
  }) async {
    try {
      final result = await _paystackDataSource.getTransactionStatus(
        reference: reference,
      );

      final transaction = PaystackTransactionEntity.fromJson(result);
      return Right(transaction);
    } catch (e) {
      return Left(ServerFailure(failureMessage: 'Failed to get transaction status: ${e.toString()}'));
    }
  }
}