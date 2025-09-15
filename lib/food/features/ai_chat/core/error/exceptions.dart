class ServerException implements Exception {
  final String message;
  final int statusCode;

  const ServerException(this.message, this.statusCode);

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class AIServiceException implements Exception {
  final String message;
  final int? statusCode;

  const AIServiceException(this.message, [this.statusCode]);

  @override
  String toString() => 'AIServiceException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class FunctionExecutionException implements Exception {
  final String message;
  final String functionName;

  const FunctionExecutionException(this.message, this.functionName);

  @override
  String toString() => 'FunctionExecutionException in $functionName: $message';
}

class WidgetRenderingException implements Exception {
  final String message;
  final String widgetType;

  const WidgetRenderingException(this.message, this.widgetType);

  @override
  String toString() => 'WidgetRenderingException for $widgetType: $message';
}