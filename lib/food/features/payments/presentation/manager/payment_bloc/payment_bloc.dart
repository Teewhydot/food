import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';

import '../../../domain/entities/card_entity.dart';
import '../../../domain/entities/payment_method_entity.dart';
import '../../../domain/use_cases/payment_usecase.dart';
import 'payment_event.dart';
// import 'payment_state.dart'; // Commented out - using BaseState now

/// Migrated PaymentBloc to use BaseState<dynamic>
class PaymentBloc extends BaseBloC<PaymentEvent, BaseState<dynamic>> {
  final PaymentUseCase paymentUseCase;

  PaymentBloc({required this.paymentUseCase}) : super(const InitialState<dynamic>()) {
    on<GetPaymentMethodsEvent>(_onGetPaymentMethods);
    on<GetSavedCardsEvent>(_onGetSavedCards);
    on<SaveCardEvent>(_onSaveCard);
    on<DeleteCardEvent>(_onDeleteCard);
    on<ProcessPaymentEvent>(_onProcessPayment);
  }

  Future<void> _onGetPaymentMethods(
    GetPaymentMethodsEvent event,
    Emitter<BaseState<dynamic>> emit,
  ) async {
    emit(const LoadingState<List<PaymentMethodEntity>>(message: 'Loading payment methods...'));
    final result = await paymentUseCase.getPaymentMethods();
    result.fold(
      (failure) => emit(
        ErrorState<List<PaymentMethodEntity>>(
          errorMessage: failure.failureMessage,
          errorCode: 'payment_methods_fetch_failed',
          isRetryable: true,
        ),
      ),
      (paymentMethods) => paymentMethods.isEmpty
          ? emit(const EmptyState<List<PaymentMethodEntity>>(message: 'No payment methods available'))
          : emit(
              LoadedState<List<PaymentMethodEntity>>(
                data: paymentMethods,
                lastUpdated: DateTime.now(),
              ),
            ),
    );
  }

  Future<void> _onGetSavedCards(
    GetSavedCardsEvent event,
    Emitter<BaseState<dynamic>> emit,
  ) async {
    emit(const LoadingState<List<CardEntity>>(message: 'Loading saved cards...'));
    final result = await paymentUseCase.getSavedCards(event.userId);
    result.fold(
      (failure) => emit(
        ErrorState<List<CardEntity>>(
          errorMessage: failure.failureMessage,
          errorCode: 'saved_cards_fetch_failed',
          isRetryable: true,
        ),
      ),
      (cards) => cards.isEmpty
          ? emit(const EmptyState<List<CardEntity>>(message: 'No saved cards found'))
          : emit(
              LoadedState<List<CardEntity>>(
                data: cards,
                lastUpdated: DateTime.now(),
              ),
            ),
    );
  }

  Future<void> _onSaveCard(
    SaveCardEvent event,
    Emitter<BaseState<dynamic>> emit,
  ) async {
    emit(const LoadingState<CardEntity>(message: 'Saving card...'));
    final result = await paymentUseCase.saveCard(event.card);
    result.fold(
      (failure) => emit(
        ErrorState<CardEntity>(
          errorMessage: failure.failureMessage,
          errorCode: 'save_card_failed',
          isRetryable: true,
        ),
      ),
      (card) {
        emit(
          LoadedState<CardEntity>(
            data: card,
            lastUpdated: DateTime.now(),
          ),
        );
        emit(
          const SuccessState<CardEntity>(
            successMessage: 'Card saved successfully',
          ),
        );
      },
    );
  }

  Future<void> _onDeleteCard(
    DeleteCardEvent event,
    Emitter<BaseState<dynamic>> emit,
  ) async {
    emit(const LoadingState<void>(message: 'Deleting card...'));
    final result = await paymentUseCase.deleteCard(event.cardId);
    result.fold(
      (failure) => emit(
        ErrorState<void>(
          errorMessage: failure.failureMessage,
          errorCode: 'delete_card_failed',
          isRetryable: true,
        ),
      ),
      (_) => emit(
        const SuccessState<void>(
          successMessage: 'Card deleted successfully',
        ),
      ),
    );
  }

  Future<void> _onProcessPayment(
    ProcessPaymentEvent event,
    Emitter<BaseState<dynamic>> emit,
  ) async {
    emit(const LoadingState<String>(message: 'Processing payment...'));
    final result = await paymentUseCase.processPayment(
      paymentMethodId: event.paymentMethodId,
      amount: event.amount,
      currency: event.currency,
      metadata: event.metadata,
    );
    result.fold(
      (failure) => emit(
        ErrorState<String>(
          errorMessage: failure.failureMessage,
          errorCode: 'payment_process_failed',
          isRetryable: true,
        ),
      ),
      (transactionId) {
        emit(
          LoadedState<String>(
            data: transactionId,
            lastUpdated: DateTime.now(),
          ),
        );
        emit(
          const SuccessState<String>(
            successMessage: 'Payment processed successfully',
          ),
        );
      },
    );
  }
}
