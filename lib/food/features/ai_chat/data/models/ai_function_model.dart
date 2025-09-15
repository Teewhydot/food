import '../../domain/entities/ai_function.dart';

class AIFunctionModel extends AIFunction {
  const AIFunctionModel({
    required super.name,
    required super.description,
    required super.parameters,
    super.metadata = const {},
  });

  factory AIFunctionModel.fromJson(Map<String, dynamic> json) {
    return AIFunctionModel(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'parameters': parameters,
      'metadata': metadata,
    };
  }

  factory AIFunctionModel.fromEntity(AIFunction entity) {
    return AIFunctionModel(
      name: entity.name,
      description: entity.description,
      parameters: entity.parameters,
      metadata: entity.metadata,
    );
  }
}

class AIFunctionExecutionResultModel extends AIFunctionExecutionResult {
  const AIFunctionExecutionResultModel({
    required super.success,
    super.data,
    super.error,
    super.message,
    super.requiresConfirmation = false,
    super.widgetType,
    super.actions = const [],
  });

  factory AIFunctionExecutionResultModel.fromJson(Map<String, dynamic> json) {
    return AIFunctionExecutionResultModel(
      success: json['success'] ?? false,
      data: json['data'],
      error: json['error'],
      message: json['message'],
      requiresConfirmation: json['requires_confirmation'] ?? false,
      widgetType: json['widget_type'],
      actions: (json['actions'] as List?)
          ?.map((action) => Map<String, dynamic>.from(action))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'error': error,
      'message': message,
      'requires_confirmation': requiresConfirmation,
      'widget_type': widgetType,
      'actions': actions,
    };
  }

  factory AIFunctionExecutionResultModel.fromEntity(AIFunctionExecutionResult entity) {
    return AIFunctionExecutionResultModel(
      success: entity.success,
      data: entity.data,
      error: entity.error,
      message: entity.message,
      requiresConfirmation: entity.requiresConfirmation,
      widgetType: entity.widgetType,
      actions: entity.actions,
    );
  }
}