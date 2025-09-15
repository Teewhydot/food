import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_message.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final bool isAIResponding;

  const ChatLoaded({
    required this.messages,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.isAIResponding = false,
  });

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isLoadingMore,
    bool? hasReachedMax,
    bool? isAIResponding,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isAIResponding: isAIResponding ?? this.isAIResponding,
    );
  }

  @override
  List<Object?> get props => [messages, isLoadingMore, hasReachedMax, isAIResponding];
}

class ChatError extends ChatState {
  final String message;
  final String? errorCode;

  const ChatError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

class ChatMessageSending extends ChatState {
  final List<ChatMessage> messages;
  final ChatMessage pendingMessage;

  const ChatMessageSending({
    required this.messages,
    required this.pendingMessage,
  });

  @override
  List<Object> get props => [messages, pendingMessage];
}

class ChatMessageSent extends ChatState {
  final List<ChatMessage> messages;

  const ChatMessageSent(this.messages);

  @override
  List<Object> get props => [messages];
}

class ChatMessageSendError extends ChatState {
  final List<ChatMessage> messages;
  final String error;
  final ChatMessage? failedMessage;

  const ChatMessageSendError({
    required this.messages,
    required this.error,
    this.failedMessage,
  });

  @override
  List<Object?> get props => [messages, error, failedMessage];
}

class ChatAIResponding extends ChatState {
  final List<ChatMessage> messages;
  final String? streamingContent;

  const ChatAIResponding({
    required this.messages,
    this.streamingContent,
  });

  @override
  List<Object?> get props => [messages, streamingContent];
}

class ChatAIResponseReceived extends ChatState {
  final List<ChatMessage> messages;
  final ChatMessage aiMessage;

  const ChatAIResponseReceived({
    required this.messages,
    required this.aiMessage,
  });

  @override
  List<Object> get props => [messages, aiMessage];
}

class ChatWidgetInteractionHandled extends ChatState {
  final List<ChatMessage> messages;
  final String result;

  const ChatWidgetInteractionHandled({
    required this.messages,
    required this.result,
  });

  @override
  List<Object> get props => [messages, result];
}