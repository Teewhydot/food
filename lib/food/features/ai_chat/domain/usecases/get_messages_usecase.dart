import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUseCase implements StreamUseCase<List<ChatMessage>, GetMessagesParams> {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  @override
  Stream<Either<Failure, List<ChatMessage>>> call(GetMessagesParams params) {
    return repository.getMessages(params.roomId);
  }
}

class GetMessagesParams extends Equatable {
  final String roomId;

  const GetMessagesParams({required this.roomId});

  @override
  List<Object> get props => [roomId];
}