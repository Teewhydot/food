import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/features/tracking/domain/entities/chat_entity.dart';
import 'package:food/food/features/tracking/domain/use_cases/chat_usecase.dart';
// import 'package:food/food/features/tracking/presentation/manager/chats_bloc/chats_state.dart'; // Commented out - using BaseState now

/// Migrated ChatsCubit to use BaseState<List<ChatEntity>>
class ChatsCubit extends BaseCubit<BaseState<List<ChatEntity>>> {
  final ChatUseCase chatUseCase;
  StreamSubscription<List<ChatEntity>>? _chatsSubscription;

  ChatsCubit({required this.chatUseCase}) : super(const InitialState<List<ChatEntity>>());

  void loadChats() async {
    emit(const LoadingState<List<ChatEntity>>(message: 'Loading chats...'));

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      emit(
        const ErrorState<List<ChatEntity>>(
          errorMessage: 'User not authenticated',
          errorCode: 'auth_required',
          isRetryable: false,
        ),
      );
      return;
    }

    // Cancel any existing subscription
    _chatsSubscription?.cancel();

    // Watch for real-time updates
    _chatsSubscription = chatUseCase
        .watchUserChats(userId)
        .listen(
          (chats) {
            if (chats.isEmpty) {
              emit(const EmptyState<List<ChatEntity>>(message: 'No chats yet'));
            } else {
              emit(
                LoadedState<List<ChatEntity>>(
                  data: chats,
                  lastUpdated: DateTime.now(),
                ),
              );
            }
          },
          onError: (error) {
            emit(
              ErrorState<List<ChatEntity>>(
                errorMessage: error.toString(),
                errorCode: 'chats_load_failed',
                isRetryable: true,
              ),
            );
          },
        );
  }

  Future<void> createChat({
    required String otherUserId,
    required String orderId,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      emit(
        const ErrorState<List<ChatEntity>>(
          errorMessage: 'User not authenticated',
          errorCode: 'auth_required',
          isRetryable: false,
        ),
      );
      return;
    }

    emit(const LoadingState<List<ChatEntity>>(message: 'Creating chat...'));

    final result = await chatUseCase.createOrGetChat(
      userId: userId,
      otherUserId: otherUserId,
      orderId: orderId,
    );

    result.fold(
      (failure) => emit(
        ErrorState<List<ChatEntity>>(
          errorMessage: failure.failureMessage,
          errorCode: 'create_chat_failed',
          isRetryable: true,
        ),
      ),
      (chat) {
        // Chat created successfully
        emit(
          const SuccessState<List<ChatEntity>>(
            successMessage: 'Chat created successfully',
          ),
        );
        // Reload chats to get updated list
        loadChats();
      },
    );
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}
