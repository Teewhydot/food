import 'package:equatable/equatable.dart';

abstract class FlutterwavePaymentEvent extends Equatable {
  const FlutterwavePaymentEvent();

  @override
  List<Object?> get props => [];
}

class InitializeFlutterwavePaymentEvent extends FlutterwavePaymentEvent {
  final String orderId;
  final double amount;
  final String email;
  final Map<String, dynamic>? metadata;

  const InitializeFlutterwavePaymentEvent({
    required this.orderId,
    required this.amount,
    required this.email,
    this.metadata,
  });

  @override
  List<Object?> get props => [orderId, amount, email, metadata];
}

class VerifyFlutterwavePaymentEvent extends FlutterwavePaymentEvent {
  final String reference;
  final String orderId;

  const VerifyFlutterwavePaymentEvent({
    required this.reference,
    required this.orderId,
  });

  @override
  List<Object?> get props => [reference, orderId];
}

class GetFlutterwaveTransactionStatusEvent extends FlutterwavePaymentEvent {
  final String reference;

  const GetFlutterwaveTransactionStatusEvent({
    required this.reference,
  });

  @override
  List<Object?> get props => [reference];
}

class ClearFlutterwavePaymentEvent extends FlutterwavePaymentEvent {
  const ClearFlutterwavePaymentEvent();
}