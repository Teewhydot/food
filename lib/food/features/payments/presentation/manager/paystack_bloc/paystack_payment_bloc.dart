import 'package:bloc/bloc.dart';
import '../../../domain/use_cases/paystack_payment_usecase.dart';
import 'paystack_payment_event.dart';
import 'paystack_payment_state.dart';

class PaystackPaymentBloc extends Bloc<PaystackPaymentEvent, PaystackPaymentState> {
  final PaystackPaymentUseCase _paystackPaymentUseCase;

  PaystackPaymentBloc(this._paystackPaymentUseCase) : super(const PaystackPaymentInitial()) {
    on<InitializePaystackPaymentEvent>(_onInitializePayment);
    on<VerifyPaystackPaymentEvent>(_onVerifyPayment);
    on<GetTransactionStatusEvent>(_onGetTransactionStatus);
    on<ClearPaystackPaymentEvent>(_onClearPayment);
  }

  Future<void> _onInitializePayment(
    InitializePaystackPaymentEvent event,
    Emitter<PaystackPaymentState> emit,
  ) async {
    emit(const PaystackPaymentLoading());

    final result = await _paystackPaymentUseCase.initializePayment(
      orderId: event.orderId,
      amount: event.amount,
      email: event.email,
      metadata: event.metadata,
    );

    result.fold(
      (failure) => emit(PaystackPaymentError(message: failure.failureMessage)),
      (transaction) => emit(PaystackPaymentInitialized(transaction: transaction)),
    );
  }

  Future<void> _onVerifyPayment(
    VerifyPaystackPaymentEvent event,
    Emitter<PaystackPaymentState> emit,
  ) async {
    emit(const PaystackPaymentLoading());

    final result = await _paystackPaymentUseCase.verifyPayment(
      reference: event.reference,
      orderId: event.orderId,
    );

    result.fold(
      (failure) => emit(PaystackPaymentError(message: failure.failureMessage)),
      (transaction) => emit(PaystackPaymentVerified(transaction: transaction)),
    );
  }

  Future<void> _onGetTransactionStatus(
    GetTransactionStatusEvent event,
    Emitter<PaystackPaymentState> emit,
  ) async {
    emit(const PaystackPaymentLoading());

    final result = await _paystackPaymentUseCase.getTransactionStatus(
      reference: event.reference,
    );

    result.fold(
      (failure) => emit(PaystackPaymentError(message: failure.failureMessage)),
      (transaction) => emit(PaystackPaymentStatusRetrieved(transaction: transaction)),
    );
  }

  void _onClearPayment(
    ClearPaystackPaymentEvent event,
    Emitter<PaystackPaymentState> emit,
  ) {
    emit(const PaystackPaymentInitial());
  }
}