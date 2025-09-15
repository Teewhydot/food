import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/ai_function.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_service_repository.dart';
import '../datasources/remote/ai_service_remote_datasource.dart';
import '../models/ai_function_model.dart';
import '../models/chat_message_model.dart';

class AIServiceRepositoryImpl implements AIServiceRepository {
  final AIServiceRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AIServiceRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> sendMessage(
    String message,
    List<ChatMessage> context,
  ) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(ServerFailure('No internet connection', 503));
      }

      final contextModels =
          context.map((msg) => ChatMessageModel.fromEntity(msg)).toList();

      final response =
          await remoteDataSource.sendMessage(message, contextModels);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Failed to send message: $e', 500));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> sendMessageWithFunctions(
    String message,
    List<ChatMessage> context,
    List<AIFunction> availableFunctions,
  ) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(ServerFailure('No internet connection', 503));
      }

      final contextModels =
          context.map((msg) => ChatMessageModel.fromEntity(msg)).toList();

      final functionModels = availableFunctions
          .map((func) => AIFunctionModel.fromEntity(func))
          .toList();

      final response = await remoteDataSource.sendMessageWithFunctions(
        message,
        contextModels,
        functionModels,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(
          ServerFailure('Failed to send message with functions: $e', 500));
    }
  }

  @override
  Stream<Either<Failure, String>> sendStreamingMessage(
    String message,
    List<ChatMessage> context,
  ) async* {
    try {
      if (!await networkInfo.isConnected) {
        yield const Left(ServerFailure('No internet connection', 503));
        return;
      }

      final contextModels =
          context.map((msg) => ChatMessageModel.fromEntity(msg)).toList();

      yield* remoteDataSource
          .sendStreamingMessage(message, contextModels)
          .map((chunk) => Right<Failure, String>(chunk))
          .handleError((error) {
        if (error is ServerException) {
          return Left<Failure, String>(
            ServerFailure(error.message, error.statusCode),
          );
        }
        return Left<Failure, String>(
          ServerFailure('Streaming error: $error', 500),
        );
      });
    } catch (e) {
      yield Left(ServerFailure('Failed to start streaming: $e', 500));
    }
  }
}