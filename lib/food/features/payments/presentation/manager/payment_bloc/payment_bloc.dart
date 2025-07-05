import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/use_cases/payment_usecase.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentUseCase paymentUseCase;

  PaymentBloc({required this.paymentUseCase}) : super(PaymentInitial()) {
    on<GetPaymentMethodsEvent>(_onGetPaymentMethods);
    on<GetSavedCardsEvent>(_onGetSavedCards);
    on<SaveCardEvent>(_onSaveCard);
    on<DeleteCardEvent>(_onDeleteCard);
    on<ProcessPaymentEvent>(_onProcessPayment);
  }

  Future<void> _onGetPaymentMethods(
    GetPaymentMethodsEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await paymentUseCase.getPaymentMethods();
    result.fold(
      (failure) => emit(PaymentError(failure.failureMessage)),
      (paymentMethods) => emit(PaymentMethodsLoaded(paymentMethods)),
    );
  }

  Future<void> _onGetSavedCards(
    GetSavedCardsEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await paymentUseCase.getSavedCards(event.userId);
    result.fold(
      (failure) => emit(PaymentError(failure.failureMessage)),
      (cards) => emit(SavedCardsLoaded(cards)),
    );
  }

  Future<void> _onSaveCard(
    SaveCardEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await paymentUseCase.saveCard(event.card);
    result.fold(
      (failure) => emit(PaymentError(failure.failureMessage)),
      (card) => emit(CardSaved(card)),
    );
  }

  Future<void> _onDeleteCard(
    DeleteCardEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await paymentUseCase.deleteCard(event.cardId);
    result.fold(
      (failure) => emit(PaymentError(failure.failureMessage)),
      (_) => emit(CardDeleted()),
    );
  }

  Future<void> _onProcessPayment(
    ProcessPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    final result = await paymentUseCase.processPayment(
      paymentMethodId: event.paymentMethodId,
      amount: event.amount,
      currency: event.currency,
      metadata: event.metadata,
    );
    result.fold(
      (failure) => emit(PaymentError(failure.failureMessage)),
      (transactionId) => emit(PaymentProcessed(transactionId)),
    );
  }
}
