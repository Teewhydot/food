import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/message_entity.dart';

part 'messaging_event.dart';
part 'messaging_state.dart';

class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {
  MessagingBloc() : super(MessagingInitial()) {
    on<LoadMessagesEvent>((event, emit) async {
      emit(MessagingLoading());
      // Simulate a network call to load messages
      await Future.delayed(Duration(seconds: 2), () {
        final messages = [
          MessageEntity(
            id: Uuid().v4(),
            senderId: 'user1',
            receiverId: 'user2',
            content: 'Hello!',
            timestamp: DateTime.now(),
          ),
        ];
        emit(MessagingLoaded(messages: messages));
      });
    });
    on<SendMessageEvent>((event, emit) async {
      emit(MessagingLoading());
      // Simulate sending a message
      await Future.delayed(Duration(seconds: 1), () {
        final newMessage = MessageEntity(
          id: Uuid().v4(),
          senderId: event.chatId,
          receiverId: 'receiverId', // Replace with actual receiver ID
          content: event.message,
          timestamp: DateTime.now(),
        );
        final currentState = state;
        if (currentState is MessagingLoaded) {
          final updatedMessages = List<MessageEntity>.from(
            currentState.messages,
          )..add(newMessage);
          emit(MessagingLoaded(messages: updatedMessages));
        }
      });
    });
    on<DeleteMessageEvent>((event, emit) async {
      emit(MessagingLoading());
      // Simulate deleting a message
      await Future.delayed(Duration(seconds: 1), () {
        final currentState = state;
        if (currentState is MessagingLoaded) {
          final updatedMessages =
              currentState.messages
                  .where((msg) => msg.id != event.messageId)
                  .toList();
          emit(MessagingLoaded(messages: updatedMessages));
        }
      });
    });
    on<UpdateMessageEvent>((event, emit) async {
      emit(MessagingLoading());
      // Simulate updating a message
      await Future.delayed(Duration(seconds: 1), () {
        final currentState = state;
        if (currentState is MessagingLoaded) {
          final updatedMessages =
              currentState.messages.map((msg) {
                if (msg.id == event.messageId) {
                  return MessageEntity(
                    id: msg.id,
                    senderId: msg.senderId,
                    receiverId: msg.receiverId,
                    content: event.newMessage,
                    timestamp: msg.timestamp,
                  );
                }
                return msg;
              }).toList();
          emit(MessagingLoaded(messages: updatedMessages));
        }
      });
    });
  }
}
