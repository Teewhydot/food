import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/use_cases/order_usecase.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderUseCase orderUseCase;

  OrderBloc({required this.orderUseCase}) : super(OrderInitial()) {
    on<CreateOrderEvent>(_onCreateOrder);
    on<GetUserOrdersEvent>(_onGetUserOrders);
    on<GetOrderByIdEvent>(_onGetOrderById);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<CancelOrderEvent>(_onCancelOrder);
  }

  Future<void> _onCreateOrder(
    CreateOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await orderUseCase.createOrder(event.order);
    result.fold(
      (failure) => emit(OrderError(failure.failureMessage)),
      (order) => emit(OrderCreated(order)),
    );
  }

  Future<void> _onGetUserOrders(
    GetUserOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await orderUseCase.getUserOrders(event.userId);
    result.fold(
      (failure) => emit(OrderError(failure.failureMessage)),
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

  Future<void> _onGetOrderById(
    GetOrderByIdEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await orderUseCase.getOrderById(event.orderId);
    result.fold(
      (failure) => emit(OrderError(failure.failureMessage)),
      (order) => emit(OrderLoaded(order)),
    );
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await orderUseCase.updateOrderStatus(
      event.orderId,
      event.status,
    );
    result.fold(
      (failure) => emit(OrderError(failure.failureMessage)),
      (order) => emit(OrderStatusUpdated(order)),
    );
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await orderUseCase.cancelOrder(event.orderId);
    result.fold(
      (failure) => emit(OrderError(failure.failureMessage)),
      (_) => emit(OrderCancelled()),
    );
  }
}
