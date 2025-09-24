import 'package:dartz/dartz.dart';
import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/tracking/domain/entities/notification_entity.dart';

import '../../../domain/use_cases/notification_usecase.dart';

class NotificationCubit extends BaseCubit<BaseState<List<NotificationEntity>>> {
  NotificationCubit() : super(const InitialState<List<NotificationEntity>>());
  final notificationsUseCase = NotificationUseCase();

  Stream<Either<Failure, List<NotificationEntity>>> watchNotifications(
    String userId,
  ) async* {
    yield* notificationsUseCase.watchUserNotifications(userId);
  }
}
