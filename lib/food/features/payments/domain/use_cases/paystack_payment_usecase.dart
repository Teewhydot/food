import 'package:dartz/dartz.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';

import '../../../../domain/failures/failures.dart';
import '../entities/paystack_transaction_entity.dart';
import '../repositories/paystack_payment_repository.dart';

class PaystackPaymentUseCase {
  final PaystackPaymentRepository _repository;

  PaystackPaymentUseCase(this._repository);

  Future<Either<Failure, PaystackTransactionEntity>> initializePayment({
    required String orderId,
    required double amount,
    required String email,
    Map<String, dynamic>? metadata,
  }) async {
    if (orderId.isEmpty) {
      return Left(
        InvalidDataFailure(failureMessage: 'Order ID cannot be empty'),
      );
    }

    if (amount <= 0) {
      return Left(
        InvalidDataFailure(failureMessage: 'Amount must be greater than zero'),
      );
    }

    if (email.isEmpty || !_isValidEmail(email)) {
      return Left(
        InvalidDataFailure(failureMessage: 'Valid email is required'),
      );
    }

    return await _repository.initializePayment(
      orderId: orderId,
      amount: amount,
      email: email,
      metadata: metadata,
    );
  }

  Future<Either<Failure, PaystackTransactionEntity>> verifyPayment({
    required String reference,
    required String orderId,
  }) async {
    if (reference.isEmpty) {
      return Left(
        InvalidDataFailure(failureMessage: 'Payment reference cannot be empty'),
      );
    }

    if (orderId.isEmpty) {
      return Left(
        InvalidDataFailure(failureMessage: 'Order ID cannot be empty'),
      );
    }

    return await _repository.verifyPayment(
      reference: reference,
      orderId: orderId,
    );
  }

  Future<Either<Failure, PaystackTransactionEntity>> getTransactionStatus({
    required String reference,
  }) async {
    if (reference.isEmpty) {
      return Left(
        InvalidDataFailure(failureMessage: 'Payment reference cannot be empty'),
      );
    }

    return await _repository.getTransactionStatus(reference: reference);
  }

  bool _isValidEmail(String email) {
    return GetUtils.isEmail(email);
  }
}
