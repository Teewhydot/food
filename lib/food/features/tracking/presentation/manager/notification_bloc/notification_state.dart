import 'package:flutter/material.dart';
import 'package:food/food/core/bloc/app_state.dart';
import 'package:food/food/features/tracking/domain/entities/notification_entity.dart';

@immutable
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;

  NotificationLoaded({required this.notifications});
}

class NotificationError extends NotificationState implements AppErrorState {
  @override
  final String errorMessage;

  NotificationError({required this.errorMessage});
}
