import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/food/core/network/dio_client.dart';
import 'package:food/food/core/utils/logger.dart';

import '../../../domain/entities/order_entity.dart';

abstract class OrderRemoteDataSource {
  Stream<List<OrderEntity>> streamUserOrders(String userId);
  Stream<OrderEntity?> streamOrderById(String orderId);
  Future<void> cancelOrder(String orderId);
}

// New interface for REST API-based implementations
abstract class OrderRestDataSource {
  Future<OrderEntity> createOrder(OrderEntity order);
  Future<List<OrderEntity>> getUserOrders(String userId, {int limit = 20, int offset = 0});
  Future<OrderEntity> getOrderById(String orderId);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<void> cancelOrder(String orderId);
  Future<OrderEntity> trackOrder(String orderId);
}

class FirebaseOrderRemoteDataSource implements OrderRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Stream<List<OrderEntity>> streamUserOrders(String userId) {
    return _firestore
        .collection('food_orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => _orderFromFirestore(doc)).toList(),
        );
  }

  @override
  Stream<OrderEntity?> streamOrderById(String orderId) {
    return _firestore
        .collection('food_orders')
        .doc(orderId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return _orderFromFirestore(snapshot);
    });
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await _firestore.collection('food_orders').doc(orderId).update({
      'status': OrderStatus.cancelled.toString().split('.').last,
      'cancelledAt': FieldValue.serverTimestamp(),
    });
  }

  OrderEntity _orderFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OrderEntity(
      id: doc.id,
      userId: data['userId'] ?? '',
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
      items:
          (data['items'] as List<dynamic>? ?? []).map((item) {
            return OrderItem(
              foodId: item['foodId'] ?? '',
              foodName: item['foodName'] ?? '',
              price: (item['price'] ?? 0).toDouble(),
              quantity: item['quantity'] ?? 0,
              total: (item['total'] ?? 0).toDouble(),
              specialInstructions: item['specialInstructions'],
            );
          }).toList(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0).toDouble(),
      tax: (data['tax'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      deliveryAddress: data['deliveryAddress'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      status: _parseOrderStatus(data['status'] ?? 'pending'),
      serviceStatus: _parseOrderStatus(data['service_status'] ?? 'pending'),
      createdAt: _parseDateTimeRequired(data['createdAt']),
      deliveredAt: _parseDateTimeNullable(data['deliveredAt']),
      deliveryPersonName: data['deliveryPersonName'],
      deliveryPersonPhone: data['deliveryPersonPhone'],
      trackingUrl: data['trackingUrl'],
      notes: data['notes'],
    );
  }

  DateTime _parseDateTimeRequired(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    if (dateValue is Timestamp) {
      return dateValue.toDate();
    } else if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    } else if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }

    return DateTime.now();
  }

  DateTime? _parseDateTimeNullable(dynamic dateValue) {
    if (dateValue == null) return null;

    if (dateValue is Timestamp) {
      return dateValue.toDate();
    } else if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return null;
      }
    } else if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }

    return null;
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

class GolangOrderRestDataSource implements OrderRestDataSource {
  final _dioClient = DioClient();

  OrderEntity _parseOrder(Map<String, dynamic> data) {
    return OrderEntity(
      id: data['id'] ?? '',
      userId: data['user_id'] ?? '',
      restaurantId: data['restaurant_id'] ?? '',
      restaurantName: data['restaurant_name'] ?? '',
      items: (data['items'] as List? ?? []).map((item) {
        return OrderItem(
          foodId: item['foodId'] ?? item['food_id'] ?? '',
          foodName: item['foodName'] ?? item['name'] ?? '',
          price: (item['price'] ?? 0).toDouble(),
          quantity: item['quantity'] ?? 0,
          total: (item['total'] ?? 0).toDouble(),
          specialInstructions: item['specialInstructions'] ?? item['special_instructions'],
        );
      }).toList(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      deliveryFee: (data['delivery_fee'] ?? 0).toDouble(),
      tax: (data['tax'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      deliveryAddress: data['delivery_address'] ?? '',
      paymentMethod: data['payment_method'] ?? '',
      status: _parseOrderStatus(data['status'] ?? 'pending'),
      serviceStatus: _parseOrderStatus(data['service_status'] ?? 'pending'),
      createdAt: DateTime.parse(data['created_at'] ?? DateTime.now().toIso8601String()),
      deliveredAt: data['delivered_at'] != null ? DateTime.parse(data['delivered_at']) : null,
      deliveryPersonName: data['delivery_person_name'] ?? data['deliveryPersonName'],
      deliveryPersonPhone: data['delivery_person_phone'] ?? data['deliveryPersonPhone'],
      trackingUrl: data['tracking_url'] ?? data['trackingUrl'],
      notes: data['notes'],
    );
  }

  OrderStatus _parseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ontheway':
      case 'on_the_way':
        return OrderStatus.onTheWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  @override
  Future<OrderEntity> createOrder(OrderEntity order) async {
    Logger.logBasic('GolangOrderRestDataSource.createOrder() called');
    Logger.logBasic('Making POST request to /api/v1/orders');
    final res = await _dioClient.post(
      "/api/v1/orders",
      requestBody: {
        "restaurantId": order.restaurantId,
        "restaurantName": order.restaurantName,
        "items": order.items.map((item) => {
          "foodId": item.foodId,
          "name": item.foodName,
          "price": item.price,
          "quantity": item.quantity,
          "specialInstructions": item.specialInstructions,
        }).toList(),
        "subtotal": order.subtotal,
        "deliveryFee": order.deliveryFee,
        "tax": order.tax,
        "total": order.total,
        "deliveryAddress": order.deliveryAddress,
        "paymentMethodId": order.paymentMethod,
        "notes": order.notes,
      },
    );
    Logger.logBasic('POST request successful, parsing response');
    final createdOrder = _parseOrder(res.data);
    Logger.logSuccess('Order created successfully');
    return createdOrder;
  }

  @override
  Future<List<OrderEntity>> getUserOrders(String userId, {int limit = 20, int offset = 0}) async {
    Logger.logBasic('GolangOrderRestDataSource.getUserOrders() called');
    Logger.logBasic('Making GET request to /api/v1/orders/user/$userId');
    final res = await _dioClient.get(
      "/api/v1/orders/user/$userId",
      queryParameters: {"limit": limit, "offset": offset},
    );
    Logger.logBasic('GET request successful, parsing response');
    final data = res.data['data'] as List;
    final orders = data.map((item) => _parseOrder(item)).toList();
    Logger.logSuccess('Parsed ${orders.length} orders');
    return orders;
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    Logger.logBasic('GolangOrderRestDataSource.getOrderById() called');
    Logger.logBasic('Making GET request to /api/v1/orders/$orderId');
    final res = await _dioClient.get("/api/v1/orders/$orderId");
    Logger.logBasic('GET request successful, parsing response');
    final order = _parseOrder(res.data);
    Logger.logSuccess('Order parsed successfully');
    return order;
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    Logger.logBasic('GolangOrderRestDataSource.updateOrderStatus() called');
    Logger.logBasic('Making PUT request to /api/v1/orders/$orderId/status');
    await _dioClient.put(
      "/api/v1/orders/$orderId/status",
      data: {"status": status.toString().split('.').last},
    );
    Logger.logBasic('PUT request successful');
    Logger.logSuccess('Order status updated');
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    Logger.logBasic('GolangOrderRestDataSource.cancelOrder() called');
    Logger.logBasic('Making DELETE request to /api/v1/orders/$orderId');
    await _dioClient.delete("/api/v1/orders/$orderId");
    Logger.logBasic('DELETE request successful');
    Logger.logSuccess('Order cancelled successfully');
  }

  @override
  Future<OrderEntity> trackOrder(String orderId) async {
    Logger.logBasic('GolangOrderRestDataSource.trackOrder() called');
    Logger.logBasic('Making GET request to /api/v1/orders/$orderId/track');
    final res = await _dioClient.get("/api/v1/orders/$orderId/track");
    Logger.logBasic('GET request successful, parsing response');
    final order = _parseOrder(res.data);
    Logger.logSuccess('Order tracking info parsed successfully');
    return order;
  }
}
