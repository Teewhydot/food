import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food/food/features/tracking/domain/entities/chat_entity.dart';
import 'package:food/food/features/tracking/domain/use_cases/chat_usecase.dart';
import 'package:food/food/features/tracking/presentation/manager/chats_bloc/chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  final ChatUseCase chatUseCase;
  StreamSubscription<List<ChatEntity>>? _chatsSubscription;

  ChatsCubit({required this.chatUseCase}) : super(ChatsInitial());

  void loadChats() async {
    emit(ChatsLoading());

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      emit(ChatsError('User not authenticated'));
      return;
    }

    // Cancel any existing subscription
    _chatsSubscription?.cancel();

    // Watch for real-time updates
    _chatsSubscription = chatUseCase
        .watchUserChats(userId)
        .listen(
          (chats) {
            emit(ChatsLoaded(chats: chats));
          },
          onError: (error) {
            emit(ChatsError(error.toString()));
          },
        );
  }

  Future<void> createChat({
    required String otherUserId,
    required String orderId,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      emit(ChatsError('User not authenticated'));
      return;
    }

    final result = await chatUseCase.createOrGetChat(
      userId: userId,
      otherUserId: otherUserId,
      orderId: orderId,
    );

    result.fold((failure) => emit(ChatsError(failure.failureMessage)), (chat) {
      // Chat created, reload chats
      loadChats();
    });
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}
