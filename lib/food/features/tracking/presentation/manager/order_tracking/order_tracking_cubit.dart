import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../payments/domain/use_cases/order_usecase.dart';
import 'order_tracking_state.dart';

class OrderTrackingCubit extends Cubit<OrderTrackingState> {
  final OrderUseCase _orderUseCase = GetIt.instance<OrderUseCase>();
  StreamSubscription? _orderSubscription;

  OrderTrackingCubit() : super(OrderTrackingInitial());

  void startTrackingOrder(String orderId) {
    emit(OrderTrackingLoading());

    _orderSubscription?.cancel();
    _orderSubscription = _orderUseCase.streamOrderById(orderId).listen(
      (result) {
        result.fold(
          (failure) => emit(OrderTrackingError(failure.failureMessage)),
          (order) {
            if (order == null) {
              emit(OrderNotFound());
            } else {
              emit(OrderTrackingLoaded(order));
            }
          },
        );
      },
    );
  }

  void stopTracking() {
    _orderSubscription?.cancel();
    emit(OrderTrackingInitial());
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    return super.close();
  }
}