import 'package:equatable/equatable.dart';
import '../../../domain/entities/flutterwave_transaction_entity.dart';

abstract class FlutterwavePaymentState extends Equatable {
  const FlutterwavePaymentState();

  @override
  List<Object?> get props => [];
}

class FlutterwavePaymentInitial extends FlutterwavePaymentState {
  const FlutterwavePaymentInitial();
}

class FlutterwavePaymentLoading extends FlutterwavePaymentState {
  const FlutterwavePaymentLoading();
}

class FlutterwavePaymentInitialized extends FlutterwavePaymentState {
  final FlutterwaveTransactionEntity transaction;

  const FlutterwavePaymentInitialized({
    required this.transaction,
  });

  @override
  List<Object?> get props => [transaction];
}

class FlutterwavePaymentVerified extends FlutterwavePaymentState {
  final FlutterwaveTransactionEntity transaction;

  const FlutterwavePaymentVerified({
    required this.transaction,
  });

  @override
  List<Object?> get props => [transaction];
}

class FlutterwavePaymentStatusRetrieved extends FlutterwavePaymentState {
  final FlutterwaveTransactionEntity transaction;

  const FlutterwavePaymentStatusRetrieved({
    required this.transaction,
  });

  @override
  List<Object?> get props => [transaction];
}

class FlutterwavePaymentError extends FlutterwavePaymentState {
  final String message;

  const FlutterwavePaymentError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}