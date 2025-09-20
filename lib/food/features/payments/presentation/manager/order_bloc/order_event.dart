import '../../../domain/entities/order_entity.dart';

abstract class OrderEvent {
  const OrderEvent();
}

class CreateOrderEvent extends OrderEvent {
  final OrderEntity order;

  const CreateOrderEvent(this.order);
}

class GetUserOrdersEvent extends OrderEvent {
  final String userId;

  const GetUserOrdersEvent(this.userId);
}

class StreamUserOrdersEvent extends OrderEvent {
  final String userId;

  const StreamUserOrdersEvent(this.userId);
}

class GetOrderByIdEvent extends OrderEvent {
  final String orderId;

  const GetOrderByIdEvent(this.orderId);
}

class UpdateOrderStatusEvent extends OrderEvent {
  final String orderId;
  final OrderStatus status;

  const UpdateOrderStatusEvent(this.orderId, this.status);
}

class CancelOrderEvent extends OrderEvent {
  final String orderId;

  const CancelOrderEvent(this.orderId);
}
