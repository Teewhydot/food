import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/usecases/get_messages_usecase.dart';
import '../../../domain/usecases/send_message_usecase.dart';
import '../../../domain/usecases/send_ai_message_usecase.dart';
import '../../../domain/usecases/chat_room_usecases.dart';
import '../../services/ai_function_registry.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetMessagesUseCase getMessages;
  final SendMessageUseCase sendMessage;
  final SendAIMessageUseCase sendAIMessage;
  final SendAIMessageWithFunctionsUseCase sendAIMessageWithFunctions;
  final SendStreamingAIMessageUseCase sendStreamingAIMessage;
  final MarkMessagesAsReadUseCase markMessagesAsRead;
  final AIFunctionRegistry functionRegistry;
  final FirebaseAuth _firebaseAuth;

  StreamSubscription? _messagesSubscription;
  StreamSubscription? _streamingSubscription;

  ChatBloc({
    required this.getMessages,
    required this.sendMessage,
    required this.sendAIMessage,
    required this.sendAIMessageWithFunctions,
    required this.sendStreamingAIMessage,
    required this.markMessagesAsRead,
    required this.functionRegistry,
    required FirebaseAuth firebaseAuth,
  })  : _firebaseAuth = firebaseAuth,
        super(ChatInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<SendAIMessage>(_onSendAIMessage);
    on<UpdateMessage>(_onUpdateMessage);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<HandleWidgetInteraction>(_onHandleWidgetInteraction);
    on<RetryFailedMessage>(_onRetryFailedMessage);
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _streamingSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());

    _messagesSubscription?.cancel();
    _messagesSubscription = getMessages(GetMessagesParams(roomId: event.roomId))
        .listen(
      (either) {
        either.fold(
          (failure) {
            if (!isClosed) {
              add(LoadMessages(event.roomId)); // Retry on failure
            }
          },
          (messages) {
            if (!isClosed) {
              emit(ChatLoaded(messages: messages));
            }
          },
        );
      },
    );
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(const ChatError(message: 'User not authenticated'));
      return;
    }

    // Create message entity
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUser.uid,
      senderName: currentUser.displayName ?? 'Unknown User',
      senderType: SenderType.user,
      content: event.content,
      messageType: event.messageType,
      timestamp: DateTime.now(),
      readBy: [currentUser.uid],
      imageUrl: event.imageUrl,
      documentUrl: event.documentUrl,
      replyToId: event.replyToId,
    );

    // Show pending state
    final currentState = state;
    if (currentState is ChatLoaded) {
      emit(ChatMessageSending(
        messages: currentState.messages,
        pendingMessage: message,
      ));
    }

    // Send message
    final result = await sendMessage(SendMessageParams(
      roomId: event.roomId,
      message: message,
    ));

    result.fold(
      (failure) {
        if (currentState is ChatLoaded) {
          emit(ChatMessageSendError(
            messages: currentState.messages,
            error: failure.message,
            failedMessage: message,
          ));
        }
      },
      (_) {
        if (currentState is ChatLoaded) {
          emit(ChatMessageSent([message, ...currentState.messages]));
        }
      },
    );
  }

  Future<void> _onSendAIMessage(SendAIMessage event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    emit(currentState.copyWith(isAIResponding: true));

    if (event.withFunctions) {
      await _sendAIMessageWithFunctions(event, emit, currentState);
    } else {
      await _sendSimpleAIMessage(event, emit, currentState);
    }
  }

  Future<void> _sendAIMessageWithFunctions(
    SendAIMessage event,
    Emitter<ChatState> emit,
    ChatLoaded currentState,
  ) async {
    final availableFunctions = functionRegistry.getAvailableFunctions();

    final result = await sendAIMessageWithFunctions(
      SendAIMessageWithFunctionsParams(
        message: event.content,
        context: event.context,
        availableFunctions: availableFunctions,
      ),
    );

    result.fold(
      (failure) {
        emit(ChatError(message: failure.message));
      },
      (response) async {
        if (response == null) {
          emit(const ChatError(message: 'Empty AI response'));
          return;
        }

        await _handleAIResponse(response, event, emit, currentState);
      },
    );
  }

  Future<void> _sendSimpleAIMessage(
    SendAIMessage event,
    Emitter<ChatState> emit,
    ChatLoaded currentState,
  ) async {
    // Use streaming response for better UX
    _streamingSubscription?.cancel();
    
    String accumulatedContent = '';
    
    _streamingSubscription = sendStreamingAIMessage(
      SendAIMessageParams(
        message: event.content,
        context: event.context,
      ),
    ).listen(
      (either) {
        either.fold(
          (failure) {
            emit(ChatError(message: failure.message));
          },
          (chunk) {
            accumulatedContent += chunk;
            emit(ChatAIResponding(
              messages: currentState.messages,
              streamingContent: accumulatedContent,
            ));
          },
        );
      },
      onDone: () {
        if (accumulatedContent.isNotEmpty) {
          _createAIMessage(
            content: accumulatedContent,
            roomId: event.roomId,
            emit: emit,
            currentState: currentState,
          );
        }
      },
    );
  }

  Future<void> _handleAIResponse(
    Map<String, dynamic> response,
    SendAIMessage event,
    Emitter<ChatState> emit,
    ChatLoaded currentState,
  ) async {
    final responseType = response['type'] as String?;

    if (responseType == 'function_call') {
      await _handleFunctionCall(response, event, emit, currentState);
    } else {
      final content = response['content'] as String? ?? 'No response content';
      _createAIMessage(
        content: content,
        roomId: event.roomId,
        emit: emit,
        currentState: currentState,
      );
    }
  }

  Future<void> _handleFunctionCall(
    Map<String, dynamic> response,
    SendAIMessage event,
    Emitter<ChatState> emit,
    ChatLoaded currentState,
  ) async {
    final functionCall = response['function_call'] as Map<String, dynamic>?;
    if (functionCall == null) {
      emit(const ChatError(message: 'Invalid function call response'));
      return;
    }

    final functionName = functionCall['name'] as String?;
    final argumentsJson = functionCall['arguments'] as String?;
    
    if (functionName == null || argumentsJson == null) {
      emit(const ChatError(message: 'Invalid function call parameters'));
      return;
    }

    try {
      // Execute the function
      final result = await functionRegistry.executeFunction(
        functionName,
        argumentsJson,
      );

      // Create AI message with function result
      await _createFunctionResultMessage(
        result: result,
        functionName: functionName,
        roomId: event.roomId,
        emit: emit,
        currentState: currentState,
      );
    } catch (e) {
      emit(ChatError(message: 'Function execution failed: $e'));
    }
  }

  Future<void> _createFunctionResultMessage({
    required Map<String, dynamic> result,
    required String functionName,
    required String roomId,
    required Emitter<ChatState> emit,
    required ChatLoaded currentState,
  }) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return;

    final widgetType = result['widget_type'] as String?;
    final message = result['message'] as String? ?? 'Function executed successfully';

    ChatMessage aiMessage;

    if (widgetType != null) {
      // Create widget message
      aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'ai_assistant',
        senderName: 'AI Assistant',
        senderType: SenderType.ai,
        content: message,
        messageType: MessageType.widget,
        timestamp: DateTime.now(),
        readBy: [],
        functionCallData: {
          'function_name': functionName,
          'result': result,
        },
        // widgetData: _createWidgetData(result), // TODO: Implement widget data creation
      );
    } else {
      // Create text message
      aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'ai_assistant',
        senderName: 'AI Assistant',
        senderType: SenderType.ai,
        content: message,
        messageType: MessageType.text,
        timestamp: DateTime.now(),
        readBy: [],
        functionCallData: {
          'function_name': functionName,
          'result': result,
        },
      );
    }

    // Send AI message
    final sendResult = await sendMessage(SendMessageParams(
      roomId: roomId,
      message: aiMessage,
    ));

    sendResult.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (_) => emit(ChatAIResponseReceived(
        messages: [aiMessage, ...currentState.messages],
        aiMessage: aiMessage,
      )),
    );
  }

  void _createAIMessage({
    required String content,
    required String roomId,
    required Emitter<ChatState> emit,
    required ChatLoaded currentState,
  }) async {
    final aiMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'ai_assistant',
      senderName: 'AI Assistant',
      senderType: SenderType.ai,
      content: content,
      messageType: MessageType.text,
      timestamp: DateTime.now(),
      readBy: [],
    );

    // Send AI message
    final result = await sendMessage(SendMessageParams(
      roomId: roomId,
      message: aiMessage,
    ));

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (_) => emit(ChatAIResponseReceived(
        messages: [aiMessage, ...currentState.messages],
        aiMessage: aiMessage,
      )),
    );
  }

  Future<void> _onUpdateMessage(UpdateMessage event, Emitter<ChatState> emit) async {
    // TODO: Implement message update logic
  }

  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsRead event,
    Emitter<ChatState> emit,
  ) async {
    await markMessagesAsRead(MarkMessagesAsReadParams(
      roomId: event.roomId,
      userId: event.userId,
    ));
  }

  Future<void> _onHandleWidgetInteraction(
    HandleWidgetInteraction event,
    Emitter<ChatState> emit,
  ) async {
    // TODO: Implement widget interaction handling
    emit(ChatWidgetInteractionHandled(
      messages: (state as ChatLoaded).messages,
      result: 'Widget interaction handled: ${event.action}',
    ));
  }

  Future<void> _onRetryFailedMessage(
    RetryFailedMessage event,
    Emitter<ChatState> emit,
  ) async {
    // TODO: Implement message retry logic
  }
}