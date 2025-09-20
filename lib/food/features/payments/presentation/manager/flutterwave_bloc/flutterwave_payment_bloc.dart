import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/use_cases/flutterwave_payment_usecase.dart';
import 'flutterwave_payment_event.dart';
import 'flutterwave_payment_state.dart';

class FlutterwavePaymentBloc extends Bloc<FlutterwavePaymentEvent, FlutterwavePaymentState> {
  final _flutterwavePaymentUseCase = GetIt.instance<FlutterwavePaymentUseCase>();

  FlutterwavePaymentBloc() : super(const FlutterwavePaymentInitial()) {
    on<InitializeFlutterwavePaymentEvent>(_onInitializePayment);
    on<VerifyFlutterwavePaymentEvent>(_onVerifyPayment);
    on<GetFlutterwaveTransactionStatusEvent>(_onGetTransactionStatus);
    on<ClearFlutterwavePaymentEvent>(_onClearPayment);
  }

  Future<void> _onInitializePayment(
    InitializeFlutterwavePaymentEvent event,
    Emitter<FlutterwavePaymentState> emit,
  ) async {
    emit(const FlutterwavePaymentLoading());

    final result = await _flutterwavePaymentUseCase.initializePayment(
      orderId: event.orderId,
      amount: event.amount,
      email: event.email,
      metadata: event.metadata,
    );

    result.fold(
      (failure) => emit(FlutterwavePaymentError(message: failure.failureMessage)),
      (transaction) => emit(FlutterwavePaymentInitialized(transaction: transaction)),
    );
  }

  Future<void> _onVerifyPayment(
    VerifyFlutterwavePaymentEvent event,
    Emitter<FlutterwavePaymentState> emit,
  ) async {
    emit(const FlutterwavePaymentLoading());

    final result = await _flutterwavePaymentUseCase.verifyPayment(
      reference: event.reference,
      orderId: event.orderId,
    );

    result.fold(
      (failure) => emit(FlutterwavePaymentError(message: failure.failureMessage)),
      (transaction) => emit(FlutterwavePaymentVerified(transaction: transaction)),
    );
  }

  Future<void> _onGetTransactionStatus(
    GetFlutterwaveTransactionStatusEvent event,
    Emitter<FlutterwavePaymentState> emit,
  ) async {
    emit(const FlutterwavePaymentLoading());

    final result = await _flutterwavePaymentUseCase.getTransactionStatus(
      reference: event.reference,
    );

    result.fold(
      (failure) => emit(FlutterwavePaymentError(message: failure.failureMessage)),
      (transaction) => emit(FlutterwavePaymentStatusRetrieved(transaction: transaction)),
    );
  }

  void _onClearPayment(
    ClearFlutterwavePaymentEvent event,
    Emitter<FlutterwavePaymentState> emit,
  ) {
    emit(const FlutterwavePaymentInitial());
  }
}