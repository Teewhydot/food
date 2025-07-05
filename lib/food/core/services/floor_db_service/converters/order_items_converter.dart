import 'dart:convert';
import 'package:floor/floor.dart';
import '../../../../features/payments/domain/entities/order_entity.dart';

class OrderItemsConverter extends TypeConverter<List<OrderItem>, String> {
  @override
  List<OrderItem> decode(String databaseValue) {
    final List<dynamic> jsonList = json.decode(databaseValue);
    return jsonList.map((item) => OrderItem(
      foodId: item['foodId'],
      foodName: item['foodName'],
      price: item['price'].toDouble(),
      quantity: item['quantity'],
      total: item['total'].toDouble(),
      specialInstructions: item['specialInstructions'],
    )).toList();
  }

  @override
  String encode(List<OrderItem> value) {
    return json.encode(value.map((item) => {
      'foodId': item.foodId,
      'foodName': item.foodName,
      'price': item.price,
      'quantity': item.quantity,
      'total': item.total,
      'specialInstructions': item.specialInstructions,
    }).toList());
  }
}