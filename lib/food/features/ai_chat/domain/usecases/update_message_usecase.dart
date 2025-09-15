import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class UpdateMessageUseCase implements UseCase<void, UpdateMessageParams> {
  final ChatRepository repository;

  UpdateMessageUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateMessageParams params) async {
    return await repository.updateMessage(params.roomId, params.message);
  }
}

class UpdateMessageParams extends Equatable {
  final String roomId;
  final ChatMessage message;

  const UpdateMessageParams({
    required this.roomId,
    required this.message,
  });

  @override
  List<Object> get props => [roomId, message];
}