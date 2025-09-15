import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, [this.statusCode]);

  @override
  List<Object?> get props => [message, statusCode];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.statusCode]);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// AI-specific failures
class AIServiceFailure extends Failure {
  const AIServiceFailure(super.message, [super.statusCode]);
}

class FunctionExecutionFailure extends Failure {
  const FunctionExecutionFailure(super.message);
}

class WidgetRenderingFailure extends Failure {
  const WidgetRenderingFailure(super.message);
}