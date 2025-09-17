import 'package:dartz/dartz.dart';
import 'package:food/food/features/tracking/data/repositories/notification_repository_impl.dart';

import '../../../../domain/failures/failures.dart';
import '../entities/notification_entity.dart';

class NotificationUseCase {
  final repository = NotificationRepositoryImpl();

  Future<Either<Failure, NotificationEntity>> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    return repository.sendNotification(
      userId: userId,
      title: title,
      body: body,
      data: data,
    );
  }

  Future<Either<Failure, void>> markNotificationAsRead(String notificationId) {
    return repository.markNotificationAsRead(notificationId);
  }

  Future<Either<Failure, void>> deleteNotification(String notificationId) {
    return repository.deleteNotification(notificationId);
  }

  Future<Either<Failure, String?>> getFCMToken() {
    return repository.getFCMToken();
  }

  Future<Either<Failure, void>> updateFCMToken(String userId, String token) {
    return repository.updateFCMToken(userId, token);
  }

  Stream<Either<Failure, List<NotificationEntity>>> watchUserNotifications(
    String userId,
  ) {
    return repository.watchUserNotifications(userId);
  }

  Future<Either<Failure, void>> sendPushNotification({
    required String targetUserId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    return repository.sendPushNotification(
      targetUserId: targetUserId,
      title: title,
      body: body,
      data: data,
    );
  }

  Future<Either<Failure, void>> sendOrderNotification({
    required String targetUserId,
    required String orderId,
    required String status,
  }) {
    String title;
    String body;

    switch (status.toLowerCase()) {
      case 'confirmed':
        title = 'Order Confirmed';
        body = 'Your order has been confirmed and is being prepared.';
        break;
      case 'preparing':
        title = 'Order Being Prepared';
        body = 'Your order is currently being prepared.';
        break;
      case 'ontheway':
        title = 'Order On The Way';
        body = 'Your order is on the way! Get ready to enjoy your meal.';
        break;
      case 'delivered':
        title = 'Order Delivered';
        body = 'Your order has been delivered. Enjoy your meal!';
        break;
      case 'cancelled':
        title = 'Order Cancelled';
        body = 'Your order has been cancelled.';
        break;
      default:
        title = 'Order Update';
        body = 'There\'s an update on your order.';
    }

    return repository.sendPushNotification(
      targetUserId: targetUserId,
      title: title,
      body: body,
      data: {'type': 'order_update', 'orderId': orderId, 'status': status},
    );
  }

  Future<Either<Failure, void>> sendChatNotification({
    required String targetUserId,
    required String senderName,
    required String message,
    required String chatId,
  }) {
    return repository.sendPushNotification(
      targetUserId: targetUserId,
      title: 'New Message from $senderName',
      body: message,
      data: {'type': 'new_message', 'chatId': chatId, 'senderName': senderName},
    );
  }
}
