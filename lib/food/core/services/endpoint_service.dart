import 'dart:async';

import '../utils/logger.dart';

/// Simplified endpoint service that only handles logging and timeouts
/// Use with ErrorHandler.handle() for consistent error handling
class EndpointService {
  final Duration _timeoutDuration = const Duration(seconds: 120); // Increase to 2 minutes for payment operations

  /// Execute operation with logging and timeout - doesn't transform errors
  Future<T> runWithConfig<T>(
    String operation,
    Future<T> Function() endpointCall,
  ) async {
    Logger.logBasic('Starting operation: $operation');
    
    try {
      final result = await endpointCall().timeout(_timeoutDuration);
      Logger.logSuccess('Completed operation: $operation');
      return result;
    } catch (e) {
      Logger.logError('Operation "$operation" failed: $e');
      rethrow; // Don't transform errors - let ErrorHandler handle them
    }
  }

  /// Execute operation with custom timeout
  Future<T> runWithTimeout<T>(
    String operation,
    Future<T> Function() endpointCall,
    Duration timeout,
  ) async {
    Logger.logBasic('Starting operation: $operation (timeout: ${timeout.inSeconds}s)');
    
    try {
      final result = await endpointCall().timeout(timeout);
      Logger.logSuccess('Completed operation: $operation');
      return result;
    } catch (e) {
      Logger.logError('Operation "$operation" failed: $e');
      rethrow;
    }
  }
}
