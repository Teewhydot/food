import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../core/utils/logger.dart';
import 'base_state.dart';

/// Base BLoC class that provides common functionality
/// All BLoCs should extend this class for consistency
abstract class BaseBloC<Event, State extends BaseState> extends Bloc<Event, State> {
  BaseBloC(super.initialState) {
    // Add common transformers and middleware
    _setupCommonHandlers();
  }

  void _setupCommonHandlers() {
    // Log state transitions for debugging
    stream.listen((state) {
      Logger.logBasic('$runtimeType: $state');
      
      if (state.isError) {
        Logger.logError('$runtimeType Error: ${state.errorMessage}');
      }
      
      if (state.isSuccess) {
        Logger.logSuccess('$runtimeType Success: ${state.successMessage}');
      }
    });
  }

  /// Handle exceptions and emit appropriate error states
  @protected
  void handleException(Exception exception, [StackTrace? stackTrace]) {
    Logger.logError('$runtimeType Exception: $exception');
    // Subclasses should override this to emit appropriate error states
  }

  /// Emit loading state with optional message
  @protected
  void emitLoading([String? message, double? progress]) {
    // Subclasses should implement this
  }

  /// Emit success state with message
  @protected
  void emitSuccess(String message, [Map<String, dynamic>? metadata]) {
    // Subclasses should implement this
  }

  /// Emit error state with message and optional exception
  @protected
  void emitError(
    String message, {
    Exception? exception,
    StackTrace? stackTrace,
    String? errorCode,
    bool isRetryable = true,
  }) {
    // Subclasses should implement this
  }

  @override
  void onTransition(Transition<Event, State> transition) {
    super.onTransition(transition);
    Logger.logBasic('$runtimeType Transition: ${transition.currentState} -> ${transition.nextState}');
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    Logger.logError('$runtimeType Error: $error');
  }
}

/// Base Cubit class that provides common functionality
/// All Cubits should extend this class for consistency
abstract class BaseCubit<State extends BaseState> extends Cubit<State> {
  BaseCubit(super.initialState) {
    _setupCommonHandlers();
  }

  void _setupCommonHandlers() {
    // Log state transitions for debugging
    stream.listen((state) {
      Logger.logBasic('$runtimeType: $state');
      
      if (state.isError) {
        Logger.logError('$runtimeType Error: ${state.errorMessage}');
      }
      
      if (state.isSuccess) {
        Logger.logSuccess('$runtimeType Success: ${state.successMessage}');
      }
    });
  }

  /// Handle exceptions and emit appropriate error states
  @protected
  void handleException(Exception exception, [StackTrace? stackTrace]) {
    Logger.logError('$runtimeType Exception: $exception');
    emitError(exception.toString(), exception: exception, stackTrace: stackTrace);
  }

  /// Emit loading state with optional message
  @protected
  void emitLoading([String? message, double? progress]) {
    emit(LoadingState<dynamic>(message: message, progress: progress) as State);
  }

  /// Emit success state with message
  @protected
  void emitSuccess(String message, [Map<String, dynamic>? metadata]) {
    emit(SuccessState<dynamic>(successMessage: message, metadata: metadata) as State);
  }

  /// Emit error state with message and optional exception
  @protected
  void emitError(
    String message, {
    Exception? exception,
    StackTrace? stackTrace,
    String? errorCode,
    bool isRetryable = true,
  }) {
    emit(ErrorState<dynamic>(
      errorMessage: message,
      exception: exception,
      stackTrace: stackTrace,
      errorCode: errorCode,
      isRetryable: isRetryable,
    ) as State);
  }

  /// Execute an async operation with automatic error handling
  @protected
  Future<void> executeAsync<T>(
    Future<T> Function() operation, {
    void Function(T result)? onSuccess,
    void Function(Exception exception)? onError,
    String? loadingMessage,
    String? successMessage,
  }) async {
    try {
      emitLoading(loadingMessage);
      final result = await operation();
      
      if (onSuccess != null) {
        onSuccess(result);
      } else if (successMessage != null) {
        emitSuccess(successMessage);
      }
    } on Exception catch (e, stackTrace) {
      if (onError != null) {
        onError(e);
      } else {
        handleException(e, stackTrace);
      }
    }
  }

  @override
  void onChange(Change<State> change) {
    super.onChange(change);
    Logger.logBasic('$runtimeType Change: ${change.currentState} -> ${change.nextState}');
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    Logger.logError('$runtimeType Error: $error');
  }
}