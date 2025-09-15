import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/ai_function.dart';
import '../entities/chat_message.dart';
import '../repositories/ai_service_repository.dart';

class SendAIMessageUseCase implements UseCase<String, SendAIMessageParams> {
  final AIServiceRepository repository;

  SendAIMessageUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(SendAIMessageParams params) async {
    return await repository.sendMessage(params.message, params.context);
  }
}

class SendAIMessageWithFunctionsUseCase 
    implements UseCase<Map<String, dynamic>?, SendAIMessageWithFunctionsParams> {
  final AIServiceRepository repository;

  SendAIMessageWithFunctionsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>?>> call(
      SendAIMessageWithFunctionsParams params) async {
    return await repository.sendMessageWithFunctions(
      params.message,
      params.context,
      params.availableFunctions,
    );
  }
}

class SendStreamingAIMessageUseCase 
    implements StreamUseCase<String, SendAIMessageParams> {
  final AIServiceRepository repository;

  SendStreamingAIMessageUseCase(this.repository);

  @override
  Stream<Either<Failure, String>> call(SendAIMessageParams params) {
    return repository.sendStreamingMessage(params.message, params.context);
  }
}

class SendAIMessageParams extends Equatable {
  final String message;
  final List<ChatMessage> context;

  const SendAIMessageParams({
    required this.message,
    required this.context,
  });

  @override
  List<Object> get props => [message, context];
}

class SendAIMessageWithFunctionsParams extends Equatable {
  final String message;
  final List<ChatMessage> context;
  final List<AIFunction> availableFunctions;

  const SendAIMessageWithFunctionsParams({
    required this.message,
    required this.context,
    required this.availableFunctions,
  });

  @override
  List<Object> get props => [message, context, availableFunctions];
}