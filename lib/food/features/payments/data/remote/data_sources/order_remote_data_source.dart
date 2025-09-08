import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/entities/order_entity.dart';

abstract class OrderRemoteDataSource {
  Future<OrderEntity> createOrder(OrderEntity order);
  Future<List<OrderEntity>> getUserOrders(String userId);
  Future<OrderEntity> getOrderById(String orderId);
  Future<OrderEntity> updateOrderStatus(String orderId, OrderStatus status);
  Future<void> cancelOrder(String orderId);
}

class FirebaseOrderRemoteDataSource implements OrderRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<OrderEntity> createOrder(OrderEntity order) async {
    final orderData = {
      'userId': order.userId,
      'restaurantId': order.restaurantId,
      'restaurantName': order.restaurantName,
      'items':
          order.items
              .map(
                (item) => {
                  'foodId': item.foodId,
                  'foodName': item.foodName,
                  'price': item.price,
                  'quantity': item.quantity,
                  'total': item.total,
                  'specialInstructions': item.specialInstructions,
                },
              )
              .toList(),
      'subtotal': order.subtotal,
      'deliveryFee': order.deliveryFee,
      'tax': order.tax,
      'total': order.total,
      'deliveryAddress': order.deliveryAddress,
      'paymentMethod': order.paymentMethod,
      'status': order.status.toString().split('.').last,
      'createdAt': FieldValue.serverTimestamp(),
      'notes': order.notes,
    };

    final docRef = await _firestore.collection('orders').add(orderData);

    return OrderEntity(
      id: docRef.id,
      userId: order.userId,
      restaurantId: order.restaurantId,
      restaurantName: order.restaurantName,
      items: order.items,
      subtotal: order.subtotal,
      deliveryFee: order.deliveryFee,
      tax: order.tax,
      total: order.total,
      deliveryAddress: order.deliveryAddress,
      paymentMethod: order.paymentMethod,
      status: order.status,
      createdAt: DateTime.now(),
      notes: order.notes,
    );
  }

  @override
  Future<List<OrderEntity>> getUserOrders(String userId) async {
    final snapshot =
        await _firestore
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs.map((doc) => _orderFromFirestore(doc)).toList();
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();

    if (!doc.exists) {
      throw Exception('Order not found');
    }

    return _orderFromFirestore(doc);
  }

  @override
  Future<OrderEntity> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    final updateData = {
      'status': status.toString().split('.').last,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (status == OrderStatus.delivered) {
      updateData['deliveredAt'] = FieldValue.serverTimestamp();
    }

    await _firestore.collection('orders').doc(orderId).update(updateData);

    return getOrderById(orderId);
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
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
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
      deliveryPersonName: data['deliveryPersonName'],
      deliveryPersonPhone: data['deliveryPersonPhone'],
      trackingUrl: data['trackingUrl'],
      notes: data['notes'],
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
