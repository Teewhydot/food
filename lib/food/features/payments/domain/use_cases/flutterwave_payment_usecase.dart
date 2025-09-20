import 'package:dartz/dartz.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:get_it/get_it.dart';

import '../../../../domain/failures/failures.dart';
import '../entities/flutterwave_transaction_entity.dart';
import '../repositories/flutterwave_payment_repository.dart';

class FlutterwavePaymentUseCase {
  final _repository = GetIt.instance<FlutterwavePaymentRepository>();

  Future<Either<Failure, FlutterwaveTransactionEntity>> initializePayment({
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

  Future<Either<Failure, FlutterwaveTransactionEntity>> verifyPayment({
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

  Future<Either<Failure, FlutterwaveTransactionEntity>> getTransactionStatus({
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