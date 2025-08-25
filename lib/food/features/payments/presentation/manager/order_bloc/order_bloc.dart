import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';

import '../../../domain/entities/order_entity.dart';
import '../../../domain/use_cases/order_usecase.dart';
import 'order_event.dart';
// import 'order_state.dart'; // Commented out - using BaseState now

/// Migrated OrderBloc to use BaseState<dynamic>
class OrderBloc extends BaseBloC<OrderEvent, BaseState<dynamic>> {
  final OrderUseCase orderUseCase;

  OrderBloc({required this.orderUseCase}) : super(const InitialState<dynamic>()) {
    on<CreateOrderEvent>(_onCreateOrder);
    on<GetUserOrdersEvent>(_onGetUserOrders);
    on<GetOrderByIdEvent>(_onGetOrderById);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<CancelOrderEvent>(_onCancelOrder);
  }

  Future<void> _onCreateOrder(
    CreateOrderEvent event,
    Emitter<BaseState<dynamic>> emit,
  ) async {
    emit(const LoadingState<OrderEntity>(message: 'Creating order...'));
    final result = await orderUseCase.createOrder(event.order);
    result.fold(
      (failure) => emit(
        ErrorState<OrderEntity>(
          errorMessage: failure.failureMessage,
          errorCode: 'create_order_failed',
          isRetryable: true,
        ),
      ),
      (order) {
        emit(
          LoadedState<OrderEntity>(
            data: order,
            lastUpdated: DateTime.now(),
          ),
        );
        emit(
          const SuccessState<OrderEntity>(
            successMessage: 'Order created successfully',
          ),
        );
      },
    );
  }

  Future<void> _onGetUserOrders(
    GetUserOrdersEvent event,
    Emitter<BaseState<dynamic>> emit,
  ) async {
    emit(const LoadingState<List<OrderEntity>>(message: 'Loading your orders...'));
    final result = await orderUseCase.getUserOrders(event.userId);
    result.fold(
      (failure) => emit(
        ErrorState<List<OrderEntity>>(
          errorMessage: failure.failureMessage,
          errorCode: 'user_orders_fetch_failed',
          isRetryable: true,
        ),
      ),
      (orders) => orders.isEmpty
          ? emit(const EmptyState<List<OrderEntity>>(message: 'No orders found'))
          : emit(
              LoadedState<List<OrderEntity>>(
                data: orders,
                lastUpdated: DateTime.now(),
              ),
            ),
    );
  }

  Future<void> _onGetOrderById(
    GetOrderByIdEvent event,
    Emitter<BaseState<dynamic>> emit,
  ) async {
    emit(const LoadingState<OrderEntity>(message: 'Loading order details...'));
    final result = await orderUseCase.getOrderById(event.orderId);
    result.fold(
      (failure) => emit(
        ErrorState<OrderEntity>(
          errorMessage: failure.failureMessage,
          errorCode: 'order_fetch_failed',
          isRetryable: true,
        ),
      ),
      (order) => emit(
        LoadedState<OrderEntity>(
          data: order,
          lastUpdated: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<BaseState<dynamic>> emit,
  ) async {
    emit(const LoadingState<OrderEntity>(message: 'Updating order status...'));
    final result = await orderUseCase.updateOrderStatus(
      event.orderId,
      event.status,
    );
    result.fold(
      (failure) => emit(
        ErrorState<OrderEntity>(
          errorMessage: failure.failureMessage,
          errorCode: 'update_order_status_failed',
          isRetryable: true,
        ),
      ),
      (order) {
        emit(
          LoadedState<OrderEntity>(
            data: order,
            lastUpdated: DateTime.now(),
          ),
        );
        emit(
          const SuccessState<OrderEntity>(
            successMessage: 'Order status updated successfully',
          ),
        );
      },
    );
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<BaseState<dynamic>> emit,
  ) async {
    emit(const LoadingState<void>(message: 'Cancelling order...'));
    final result = await orderUseCase.cancelOrder(event.orderId);
    result.fold(
      (failure) => emit(
        ErrorState<void>(
          errorMessage: failure.failureMessage,
          errorCode: 'cancel_order_failed',
          isRetryable: true,
        ),
      ),
      (_) => emit(
        const SuccessState<void>(
          successMessage: 'Order cancelled successfully',
        ),
      ),
    );
  }
}
