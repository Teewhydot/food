import 'package:dartz/dartz.dart';
import 'package:food/food/features/tracking/data/repositories/notification_repository_impl.dart';

import '../../../../domain/failures/failures.dart';
import '../entities/notification_entity.dart';

class NotificationUseCase {
  final repository = NotificationRepositoryImpl();

  Future<Either<Failure, void>> markNotificationAsRead(String notificationId) {
    return repository.markNotificationAsRead(notificationId);
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
}
