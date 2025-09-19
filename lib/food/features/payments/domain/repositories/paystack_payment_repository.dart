import 'package:dartz/dartz.dart';
import '../../../../domain/failures/failures.dart';
import '../entities/paystack_transaction_entity.dart';

abstract class PaystackPaymentRepository {
  Future<Either<Failure, PaystackTransactionEntity>> initializePayment({
    required String orderId,
    required double amount,
    required String email,
    required Map<String, dynamic>? metadata,
  });

  Future<Either<Failure, PaystackTransactionEntity>> verifyPayment({
    required String reference,
    required String orderId,
  });

  Future<Either<Failure, PaystackTransactionEntity>> getTransactionStatus({
    required String reference,
  });
}