part of 'messaging_bloc.dart';

@immutable
sealed class MessagingEvent {}

final class LoadMessagesEvent extends MessagingEvent {
  final String chatId;

  LoadMessagesEvent({required this.chatId});
}

final class SendMessageEvent extends MessagingEvent {
  final String chatId;
  final String message;

  SendMessageEvent({required this.chatId, required this.message});
}

final class DeleteMessageEvent extends MessagingEvent {
  final String chatId;
  final String messageId;

  DeleteMessageEvent({required this.chatId, required this.messageId});
}

final class UpdateMessageEvent extends MessagingEvent {
  final String chatId;
  final String messageId;
  final String newMessage;

  UpdateMessageEvent({
    required this.chatId,
    required this.messageId,
    required this.newMessage,
  });
}

final class ClearMessagesEvent extends MessagingEvent {
  final String chatId;

  ClearMessagesEvent({required this.chatId});
}
