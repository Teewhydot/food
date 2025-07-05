import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';
import '../entities/card_entity.dart';
import '../entities/payment_method_entity.dart';
import '../repositories/payment_repository.dart';

class PaymentUseCase {
  final PaymentRepository repository;

  PaymentUseCase(this.repository);

  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods() async {
    return await repository.getPaymentMethods();
  }

  Future<Either<Failure, List<CardEntity>>> getSavedCards(String userId) async {
    return await repository.getSavedCards(userId);
  }

  Future<Either<Failure, CardEntity>> saveCard(CardEntity card) async {
    return await repository.saveCard(card);
  }

  Future<Either<Failure, void>> deleteCard(String cardId) async {
    return await repository.deleteCard(cardId);
  }

  Future<Either<Failure, String>> processPayment({
    required String paymentMethodId,
    required double amount,
    required String currency,
    required Map<String, dynamic> metadata,
  }) async {
    return await repository.processPayment(
      paymentMethodId: paymentMethodId,
      amount: amount,
      currency: currency,
      metadata: metadata,
    );
  }
}