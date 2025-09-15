import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_message.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatEvent {
  final String roomId;

  const LoadMessages(this.roomId);

  @override
  List<Object> get props => [roomId];
}

class SendMessage extends ChatEvent {
  final String roomId;
  final String content;
  final MessageType messageType;
  final String? imageUrl;
  final String? documentUrl;
  final String? replyToId;

  const SendMessage({
    required this.roomId,
    required this.content,
    this.messageType = MessageType.text,
    this.imageUrl,
    this.documentUrl,
    this.replyToId,
  });

  @override
  List<Object?> get props => [
        roomId,
        content,
        messageType,
        imageUrl,
        documentUrl,
        replyToId,
      ];
}

class SendAIMessage extends ChatEvent {
  final String roomId;
  final String content;
  final List<ChatMessage> context;
  final bool withFunctions;

  const SendAIMessage({
    required this.roomId,
    required this.content,
    required this.context,
    this.withFunctions = true,
  });

  @override
  List<Object> get props => [roomId, content, context, withFunctions];
}

class UpdateMessage extends ChatEvent {
  final String roomId;
  final ChatMessage message;

  const UpdateMessage({
    required this.roomId,
    required this.message,
  });

  @override
  List<Object> get props => [roomId, message];
}

class MarkMessagesAsRead extends ChatEvent {
  final String roomId;
  final String userId;

  const MarkMessagesAsRead({
    required this.roomId,
    required this.userId,
  });

  @override
  List<Object> get props => [roomId, userId];
}

class HandleWidgetInteraction extends ChatEvent {
  final String messageId;
  final String action;
  final Map<String, dynamic> parameters;

  const HandleWidgetInteraction({
    required this.messageId,
    required this.action,
    required this.parameters,
  });

  @override
  List<Object> get props => [messageId, action, parameters];
}

class RetryFailedMessage extends ChatEvent {
  final String messageId;

  const RetryFailedMessage(this.messageId);

  @override
  List<Object> get props => [messageId];
}