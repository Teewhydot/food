
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  onTheWay,
  delivered,
  cancelled,
}

class OrderEntity {
  final String id;
  final String userId;
  final String restaurantId;
  final String restaurantName;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;
  final String deliveryAddress;
  final String paymentMethod;
  final OrderStatus status;
  final OrderStatus serviceStatus; // Tracks delivery updates from Firebase
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? deliveryPersonName;
  final String? deliveryPersonPhone;
  final String? trackingUrl;
  final String? notes;

  OrderEntity({
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

class OrderItem {
  final String foodId;
  final String foodName;
  final double price;
  final int quantity;
  final double total;
  final String? specialInstructions;

  OrderItem({
    required this.foodId,
    required this.foodName,
    required this.price,
    required this.quantity,
    required this.total,
    this.specialInstructions,
  });
}