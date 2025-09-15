import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase implements UseCase<void, SendMessageParams> {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SendMessageParams params) async {
    return await repository.sendMessage(params.roomId, params.message);
  }
}

class SendMessageParams extends Equatable {
  final String roomId;
  final ChatMessage message;

  const SendMessageParams({
    required this.roomId,
    required this.message,
  });

  @override
  List<Object> get props => [roomId, message];
}