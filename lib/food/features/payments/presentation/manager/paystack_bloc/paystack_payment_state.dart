import 'package:equatable/equatable.dart';
import '../../../domain/entities/paystack_transaction_entity.dart';

abstract class PaystackPaymentState extends Equatable {
  const PaystackPaymentState();

  @override
  List<Object?> get props => [];
}

class PaystackPaymentInitial extends PaystackPaymentState {
  const PaystackPaymentInitial();
}

class PaystackPaymentLoading extends PaystackPaymentState {
  const PaystackPaymentLoading();
}

class PaystackPaymentInitialized extends PaystackPaymentState {
  final PaystackTransactionEntity transaction;

  const PaystackPaymentInitialized({
    required this.transaction,
  });

  @override
  List<Object?> get props => [transaction];
}

class PaystackPaymentVerified extends PaystackPaymentState {
  final PaystackTransactionEntity transaction;

  const PaystackPaymentVerified({
    required this.transaction,
  });

  @override
  List<Object?> get props => [transaction];
}

class PaystackPaymentStatusRetrieved extends PaystackPaymentState {
  final PaystackTransactionEntity transaction;

  const PaystackPaymentStatusRetrieved({
    required this.transaction,
  });

  @override
  List<Object?> get props => [transaction];
}

class PaystackPaymentError extends PaystackPaymentState {
  final String message;

  const PaystackPaymentError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}