import 'package:dartz/dartz.dart';
import '../../../../domain/failures/failures.dart';
import '../entities/flutterwave_transaction_entity.dart';

abstract class FlutterwavePaymentRepository {
  Future<Either<Failure, FlutterwaveTransactionEntity>> initializePayment({
    required String orderId,
    required double amount,
    required String email,
    required Map<String, dynamic>? metadata,
  });

  Future<Either<Failure, FlutterwaveTransactionEntity>> verifyPayment({
    required String reference,
    required String orderId,
  });

  Future<Either<Failure, FlutterwaveTransactionEntity>> getTransactionStatus({
    required String reference,
  });
}