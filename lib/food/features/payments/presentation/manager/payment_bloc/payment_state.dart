import '../../../domain/entities/card_entity.dart';
import '../../../domain/entities/payment_method_entity.dart';

abstract class PaymentState {
  const PaymentState();
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentMethodsLoaded extends PaymentState {
  final List<PaymentMethodEntity> paymentMethods;

  const PaymentMethodsLoaded(this.paymentMethods);
}

class SavedCardsLoaded extends PaymentState {
  final List<CardEntity> cards;

  const SavedCardsLoaded(this.cards);
}

class CardSaved extends PaymentState {
  final CardEntity card;

  const CardSaved(this.card);
}

class CardDeleted extends PaymentState {}

class PaymentProcessed extends PaymentState {
  final String transactionId;

  const PaymentProcessed(this.transactionId);
}

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);
}
