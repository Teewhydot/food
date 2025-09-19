import 'package:equatable/equatable.dart';

abstract class PaystackPaymentEvent extends Equatable {
  const PaystackPaymentEvent();

  @override
  List<Object?> get props => [];
}

class InitializePaystackPaymentEvent extends PaystackPaymentEvent {
  final String orderId;
  final double amount;
  final String email;
  final Map<String, dynamic>? metadata;

  const InitializePaystackPaymentEvent({
    required this.orderId,
    required this.amount,
    required this.email,
    this.metadata,
  });

  @override
  List<Object?> get props => [orderId, amount, email, metadata];
}

class VerifyPaystackPaymentEvent extends PaystackPaymentEvent {
  final String reference;
  final String orderId;

  const VerifyPaystackPaymentEvent({
    required this.reference,
    required this.orderId,
  });

  @override
  List<Object?> get props => [reference, orderId];
}

class GetTransactionStatusEvent extends PaystackPaymentEvent {
  final String reference;

  const GetTransactionStatusEvent({
    required this.reference,
  });

  @override
  List<Object?> get props => [reference];
}

class ClearPaystackPaymentEvent extends PaystackPaymentEvent {
  const ClearPaystackPaymentEvent();
}