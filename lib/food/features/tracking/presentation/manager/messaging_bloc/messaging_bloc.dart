import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food/food/core/bloc/app_state.dart';
import 'package:meta/meta.dart';

import '../../../domain/entities/message_entity.dart';
import '../../../domain/use_cases/chat_usecase.dart';

part 'messaging_event.dart';
part 'messaging_state.dart';

class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {
  final ChatUseCase chatUseCase;
  StreamSubscription<List<MessageEntity>>? _messagesSubscription;
  String? _currentChatId;

  MessagingBloc({required this.chatUseCase}) : super(MessagingInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<DeleteMessageEvent>(_onDeleteMessage);
    on<UpdateMessageEvent>(_onUpdateMessage);
    on<MarkMessageAsReadEvent>(_onMarkMessageAsRead);
  }

  Future<void> _onLoadMessages(
    LoadMessagesEvent event,
    Emitter<MessagingState> emit,
  ) async {
    emit(MessagingLoading());

    _currentChatId = event.chatId;

    // Cancel any existing subscription
    _messagesSubscription?.cancel();

    // Watch for real-time updates
    _messagesSubscription = chatUseCase
        .watchChatMessages(event.chatId)
        .listen(
          (messages) {
            emit(MessagingLoaded(messages: messages));
          },
          onError: (error) {
            emit(MessagingError(error.toString()));
          },
        );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<MessagingState> emit,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      emit(MessagingError('User not authenticated'));
      return;
    }

    final result = await chatUseCase.sendMessage(
      chatId: event.chatId,
      senderId: userId,
      receiverId: event.receiverId,
      content: event.message,
    );

    result.fold((failure) => emit(MessagingError(failure.failureMessage)), (
      message,
    ) {
      // Message sent successfully
      // The stream subscription will automatically update the UI
    });
  }

  Future<void> _onDeleteMessage(
    DeleteMessageEvent event,
    Emitter<MessagingState> emit,
  ) async {
    final result = await chatUseCase.deleteMessage(event.messageId);

    result.fold((failure) => emit(MessagingError(failure.failureMessage)), (_) {
      // Message deleted successfully
      // The stream subscription will automatically update the UI
    });
  }

  Future<void> _onUpdateMessage(
    UpdateMessageEvent event,
    Emitter<MessagingState> emit,
  ) async {
    // This would require updating the data source to support message editing
    // For now, we'll emit an error
    emit(MessagingError('Message editing not yet implemented'));
  }

  Future<void> _onMarkMessageAsRead(
    MarkMessageAsReadEvent event,
    Emitter<MessagingState> emit,
  ) async {
    final result = await chatUseCase.markMessageAsRead(event.messageId);

    result.fold((failure) => emit(MessagingError(failure.failureMessage)), (_) {
      // Message marked as read
    });
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
