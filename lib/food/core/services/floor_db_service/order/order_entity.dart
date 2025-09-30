import 'package:floor/floor.dart';

@Entity(tableName: 'orders')
class OrderFloorEntity {
  @PrimaryKey()
  final String id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final String items; // JSON string
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;
  final String deliveryAddress;
  final String paymentMethod;
  final String status;
  final String serviceStatus;
  final int createdAt;
  final int? deliveredAt;
  final String? deliveryPersonName;
  final String? deliveryPersonPhone;
  final String? trackingUrl;
  final String? notes;

  OrderFloorEntity({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.status,
    required this.serviceStatus,
    required this.createdAt,
    this.deliveredAt,
    this.deliveryPersonName,
    this.deliveryPersonPhone,
    this.trackingUrl,
    this.notes,
  });
}