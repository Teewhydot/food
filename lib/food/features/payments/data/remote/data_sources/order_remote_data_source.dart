import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/entities/order_entity.dart';

abstract class OrderRemoteDataSource {
  Stream<List<OrderEntity>> streamUserOrders(String userId);
  Future<void> cancelOrder(String orderId);
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
