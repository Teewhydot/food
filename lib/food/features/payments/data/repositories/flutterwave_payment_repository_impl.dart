import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import '../../../../domain/failures/failures.dart';
import '../../domain/entities/flutterwave_transaction_entity.dart';
import '../../domain/repositories/flutterwave_payment_repository.dart';
import '../remote/data_sources/flutterwave_payment_data_source.dart';

class FlutterwavePaymentRepositoryImpl implements FlutterwavePaymentRepository {
  final _flutterwaveDataSource = GetIt.instance<FlutterwavePaymentDataSource>();

  @override
  Future<Either<Failure, FlutterwaveTransactionEntity>> initializePayment({
    required String orderId,
    required double amount,
    required String email,
    required Map<String, dynamic>? metadata,
  }) async {
    try {
      final result = await _flutterwaveDataSource.initializePayment(
        orderId: orderId,
        amount: amount,
        email: email,
        metadata: metadata,
      );

      final transaction = FlutterwaveTransactionEntity.fromJson(result);
      return Right(transaction);
    } catch (e) {
      return Left(ServerFailure(failureMessage: 'Failed to initialize payment: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FlutterwaveTransactionEntity>> verifyPayment({
    required String reference,
    required String orderId,
  }) async {
    try {
      final result = await _flutterwaveDataSource.verifyPayment(
        reference: reference,
        orderId: orderId,
      );

      final transaction = FlutterwaveTransactionEntity.fromJson(result);
      return Right(transaction);
    } catch (e) {
      return Left(ServerFailure(failureMessage: 'Failed to verify payment: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FlutterwaveTransactionEntity>> getTransactionStatus({
    required String reference,
  }) async {
    try {
      final result = await _flutterwaveDataSource.getTransactionStatus(
        reference: reference,
      );

      final transaction = FlutterwaveTransactionEntity.fromJson(result);
      return Right(transaction);
    } catch (e) {
      return Left(ServerFailure(failureMessage: 'Failed to get transaction status: ${e.toString()}'));
    }
  }
}