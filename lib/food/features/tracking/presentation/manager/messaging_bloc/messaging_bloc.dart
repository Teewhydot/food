import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';

import '../../../domain/entities/message_entity.dart';
import '../../../domain/use_cases/chat_usecase.dart';

part 'messaging_event.dart';
// part 'messaging_state.dart'; // Commented out - using BaseState now

/// Migrated MessagingCubit to use BaseState<List<MessageEntity>> (converted from BLoC to Cubit for simplicity)
class MessagingBloc extends BaseCubit<BaseState<List<MessageEntity>>> {
  final ChatUseCase chatUseCase;
  StreamSubscription<List<MessageEntity>>? _messagesSubscription;
  String? _currentChatId;

  MessagingBloc({required this.chatUseCase}) : super(const InitialState<List<MessageEntity>>());

  void loadMessages(String chatId) async {
    emit(const LoadingState<List<MessageEntity>>(message: 'Loading messages...'));

    _currentChatId = chatId;

    // Cancel any existing subscription
    _messagesSubscription?.cancel();

    // Watch for real-time updates
    _messagesSubscription = chatUseCase
        .watchChatMessages(chatId)
        .listen(
          (messages) {
            if (messages.isEmpty) {
              emit(const EmptyState<List<MessageEntity>>(message: 'No messages yet'));
            } else {
              emit(
                LoadedState<List<MessageEntity>>(
                  data: messages,
                  lastUpdated: DateTime.now(),
                ),
              );
            }
          },
          onError: (error) {
            emit(
              ErrorState<List<MessageEntity>>(
                errorMessage: error.toString(),
                errorCode: 'messages_load_failed',
                isRetryable: true,
              ),
            );
          },
        );
  }

  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String message,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      emit(
        const ErrorState<List<MessageEntity>>(
          errorMessage: 'User not authenticated',
          errorCode: 'auth_required',
          isRetryable: false,
        ),
      );
      return;
    }

    // Show loading state briefly for sending
    emit(const LoadingState<List<MessageEntity>>(message: 'Sending message...'));

    final result = await chatUseCase.sendMessage(
      chatId: chatId,
      senderId: userId,
      receiverId: receiverId,
      content: message,
    );

    result.fold(
      (failure) => emit(
        ErrorState<List<MessageEntity>>(
          errorMessage: failure.failureMessage,
          errorCode: 'send_message_failed',
          isRetryable: true,
        ),
      ),
      (message) {
        // Message sent successfully
        // The stream subscription will automatically update the UI
        // Emit success notification
        emit(
          const SuccessState<List<MessageEntity>>(
            successMessage: 'Message sent',
          ),
        );
      },
    );
  }

  Future<void> deleteMessage(String messageId) async {
    emit(const LoadingState<List<MessageEntity>>(message: 'Deleting message...'));
    
    final result = await chatUseCase.deleteMessage(messageId);

    result.fold(
      (failure) => emit(
        ErrorState<List<MessageEntity>>(
          errorMessage: failure.failureMessage,
          errorCode: 'delete_message_failed',
          isRetryable: true,
        ),
      ),
      (_) {
        // Message deleted successfully
        // The stream subscription will automatically update the UI
        emit(
          const SuccessState<List<MessageEntity>>(
            successMessage: 'Message deleted',
          ),
        );
      },
    );
  }

  Future<void> updateMessage({
    required String messageId,
    required String newMessage,
  }) async {
    // This would require updating the data source to support message editing
    // For now, we'll emit an error
    emit(
      const ErrorState<List<MessageEntity>>(
        errorMessage: 'Message editing not yet implemented',
        errorCode: 'feature_not_implemented',
        isRetryable: false,
      ),
    );
  }

  Future<void> markMessageAsRead(String messageId) async {
    final result = await chatUseCase.markMessageAsRead(messageId);

    result.fold(
      (failure) => emit(
        ErrorState<List<MessageEntity>>(
          errorMessage: failure.failureMessage,
          errorCode: 'mark_read_failed',
          isRetryable: true,
        ),
      ),
      (_) {
        // Message marked as read - no need to emit success as it's a background action
      },
    );
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
