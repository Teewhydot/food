import 'package:equatable/equatable.dart';

class AIFunction extends Equatable {
  final String name;
  final String description;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> metadata; // Enhanced metadata for AI input parsing

  const AIFunction({
    required this.name,
    required this.description,
    required this.parameters,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [name, description, parameters, metadata];
}

class AIFunctionExecutionResult extends Equatable {
  final bool success;
  final dynamic data;
  final String? error;
  final String? message;
  final bool requiresConfirmation;
  final String? widgetType;
  final List<Map<String, dynamic>> actions;

  const AIFunctionExecutionResult({
    required this.success,
    this.data,
    this.error,
    this.message,
    this.requiresConfirmation = false,
    this.widgetType,
    this.actions = const [],
  });

  @override
  List<Object?> get props => [
        success,
        data,
        error,
        message,
        requiresConfirmation,
        widgetType,
        actions,
      ];
}