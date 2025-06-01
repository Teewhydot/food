import 'package:food/food/features/payments/domain/entities/payment_method_entity.dart';

class CardEntity {
  final PaymentMethodEntity paymentMethodEntity;
  final int pan, cvv;
  final int mExp, yExp; // Month and Year expiry data respectively.

  CardEntity({
    required this.paymentMethodEntity,
    required this.pan,
    required this.cvv,
    required this.mExp,
    required this.yExp,
  });
}
