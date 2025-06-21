part of 'messaging_bloc.dart';

@immutable
sealed class MessagingState {}

final class MessagingInitial extends MessagingState {}

final class MessagingLoading extends MessagingState {}

final class MessagingLoaded extends MessagingState {
  final List<MessageEntity> messages;

  MessagingLoaded({required this.messages});
}

final class MessagingError extends MessagingState implements AppErrorState {
  @override
  final String errorMessage;

  MessagingError({required this.errorMessage});
}
