import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/ai_function.dart';
import '../entities/chat_message.dart';

abstract class AIServiceRepository {
  Future<Either<Failure, String>> sendMessage(
    String message,
    List<ChatMessage> context,
  );

  Future<Either<Failure, Map<String, dynamic>?>> sendMessageWithFunctions(
    String message,
    List<ChatMessage> context,
    List<AIFunction> availableFunctions,
  );

  Stream<Either<Failure, String>> sendStreamingMessage(
    String message,
    List<ChatMessage> context,
  );
}
