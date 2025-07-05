import '../../../domain/entities/order_entity.dart';

abstract class OrderState {
  const OrderState();
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderCreated extends OrderState {
  final OrderEntity order;

  const OrderCreated(this.order);
}

class OrdersLoaded extends OrderState {
  final List<OrderEntity> orders;

  const OrdersLoaded(this.orders);
}

class OrderLoaded extends OrderState {
  final OrderEntity order;

  const OrderLoaded(this.order);
}

class OrderStatusUpdated extends OrderState {
  final OrderEntity order;

  const OrderStatusUpdated(this.order);
}

class OrderCancelled extends OrderState {}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);
}
