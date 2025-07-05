import '../../../domain/entities/card_entity.dart';

abstract class PaymentEvent {
  const PaymentEvent();
}

class GetPaymentMethodsEvent extends PaymentEvent {}

class GetSavedCardsEvent extends PaymentEvent {
  final String userId;

  const GetSavedCardsEvent(this.userId);
}

class SaveCardEvent extends PaymentEvent {
  final CardEntity card;

  const SaveCardEvent(this.card);
}

class DeleteCardEvent extends PaymentEvent {
  final String cardId;

  const DeleteCardEvent(this.cardId);
}

class ProcessPaymentEvent extends PaymentEvent {
  final String paymentMethodId;
  final double amount;
  final String currency;
  final Map<String, dynamic> metadata;

  const ProcessPaymentEvent({
    required this.paymentMethodId,
    required this.amount,
    required this.currency,
    required this.metadata,
  });
}
