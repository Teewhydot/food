import 'package:floor/floor.dart';
import 'order_entity.dart';

@dao
abstract class OrderDao {
  @Query('SELECT * FROM orders WHERE userId = :userId ORDER BY createdAt DESC')
  Future<List<OrderFloorEntity>> getUserOrders(String userId);

  @Query('SELECT * FROM orders WHERE id = :id')
  Future<OrderFloorEntity?> getOrderById(String id);

  @Query('SELECT * FROM orders WHERE userId = :userId AND status = :status')
  Future<List<OrderFloorEntity>> getUserOrdersByStatus(String userId, String status);

  @Query('SELECT * FROM orders WHERE userId = :userId ORDER BY createdAt DESC LIMIT 10')
  Future<List<OrderFloorEntity>> getRecentOrders(String userId);

  @Query('SELECT * FROM orders WHERE userId = :userId AND status IN ("pending", "confirmed", "preparing", "onTheWay")')
  Future<List<OrderFloorEntity>> getActiveOrders(String userId);

  @insert
  Future<void> insertOrder(OrderFloorEntity order);

  @insert
  Future<void> insertOrders(List<OrderFloorEntity> orders);

  @update
  Future<void> updateOrder(OrderFloorEntity order);

  @Query('UPDATE orders SET status = :status WHERE id = :orderId')
  Future<void> updateOrderStatus(String orderId, String status);

  @delete
  Future<void> deleteOrder(OrderFloorEntity order);

  @Query('DELETE FROM orders WHERE userId = :userId')
  Future<void> deleteUserOrders(String userId);

  @Query('DELETE FROM orders WHERE createdAt < :timestamp')
  Future<void> deleteOldOrders(int timestamp);
}