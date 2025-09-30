import 'dart:convert';
import '../app_database.dart';
import 'order_entity.dart';
import '../../../../features/payments/domain/entities/order_entity.dart';

class OrderDatabaseService {
  final AppDatabase _database;

  OrderDatabaseService(this._database);

  Future<List<OrderEntity>> getUserOrders(String userId) async {
    final entities = await _database.orderDao.getUserOrders(userId);
    return entities.map(_toDomainEntity).toList();
  }

  Future<OrderEntity?> getOrderById(String id) async {
    final entity = await _database.orderDao.getOrderById(id);
    return entity != null ? _toDomainEntity(entity) : null;
  }

  Future<List<OrderEntity>> getActiveOrders(String userId) async {
    final entities = await _database.orderDao.getActiveOrders(userId);
    return entities.map(_toDomainEntity).toList();
  }

  Future<void> saveOrder(OrderEntity order) async {
    final entity = _toFloorEntity(order);
    await _database.orderDao.insertOrder(entity);
  }

  Future<void> saveOrders(List<OrderEntity> orders) async {
    final entities = orders.map(_toFloorEntity).toList();
    await _database.orderDao.insertOrders(entities);
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _database.orderDao.updateOrderStatus(
      orderId,
      status.toString().split('.').last,
    );
  }

  Future<void> deleteOldOrders(Duration age) async {
    final timestamp = DateTime.now().subtract(age).millisecondsSinceEpoch;
    await _database.orderDao.deleteOldOrders(timestamp);
  }

  OrderEntity _toDomainEntity(OrderFloorEntity entity) {
    final itemsList = json.decode(entity.items) as List<dynamic>;
    final items = itemsList.map((item) => OrderItem(
      foodId: item['foodId'],
      foodName: item['foodName'],
      price: item['price'].toDouble(),
      quantity: item['quantity'],
      total: item['total'].toDouble(),
      specialInstructions: item['specialInstructions'],
    )).toList();

    return OrderEntity(
      id: entity.id,
      userId: entity.userId,
      restaurantId: entity.restaurantId,
      restaurantName: entity.restaurantName,
      items: items,
      subtotal: entity.subtotal,
      deliveryFee: entity.deliveryFee,
      tax: entity.tax,
      total: entity.total,
      deliveryAddress: entity.deliveryAddress,
      paymentMethod: entity.paymentMethod,
      status: _parseOrderStatus(entity.status),
      serviceStatus: _parseOrderStatus(entity.serviceStatus),
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAt),
      deliveredAt: entity.deliveredAt != null
          ? DateTime.fromMillisecondsSinceEpoch(entity.deliveredAt!)
          : null,
      deliveryPersonName: entity.deliveryPersonName,
      deliveryPersonPhone: entity.deliveryPersonPhone,
      trackingUrl: entity.trackingUrl,
      notes: entity.notes,
    );
  }

  OrderFloorEntity _toFloorEntity(OrderEntity order) {
    final itemsJson = json.encode(order.items.map((item) => {
      'foodId': item.foodId,
      'foodName': item.foodName,
      'price': item.price,
      'quantity': item.quantity,
      'total': item.total,
      'specialInstructions': item.specialInstructions,
    }).toList());

    return OrderFloorEntity(
      id: order.id,
      userId: order.userId,
      restaurantId: order.restaurantId,
      restaurantName: order.restaurantName,
      items: itemsJson,
      subtotal: order.subtotal,
      deliveryFee: order.deliveryFee,
      tax: order.tax,
      total: order.total,
      deliveryAddress: order.deliveryAddress,
      paymentMethod: order.paymentMethod,
      status: order.status.toString().split('.').last,
      serviceStatus: order.serviceStatus.toString().split('.').last,
      createdAt: order.createdAt.millisecondsSinceEpoch,
      deliveredAt: order.deliveredAt?.millisecondsSinceEpoch,
      deliveryPersonName: order.deliveryPersonName,
      deliveryPersonPhone: order.deliveryPersonPhone,
      trackingUrl: order.trackingUrl,
      notes: order.notes,
    );
  }

  OrderStatus _parseOrderStatus(String status) {
    switch (status) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'onTheWay':
        return OrderStatus.onTheWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}