import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../app_state.dart';

/// Base state class that all application states should extend
/// Provides common functionality and automatic error/success detection
@immutable
sealed class BaseState<T> extends Equatable {
  const BaseState();

  /// Whether this state represents a loading condition
  bool get isLoading => this is LoadingState;

  /// Whether this state represents an error condition
  bool get isError => this is ErrorState;

  /// Whether this state represents a success condition
  bool get isSuccess => this is SuccessState;

  /// Whether this state has data
  bool get hasData => this is DataState && (this as DataState).data != null;

  /// Get error message if this is an error state
  String? get errorMessage => isError ? (this as ErrorState).errorMessage : null;

  /// Get success message if this is a success state
  String? get successMessage => isSuccess ? (this as SuccessState).successMessage : null;

  /// Get data if this is a data state
  T? get data => hasData ? (this as DataState<T>).data : null;

  @override
  List<Object?> get props => [];
}

/// Initial state - represents the starting state of a BLoC
@immutable
final class InitialState<T> extends BaseState<T> {
  const InitialState();

  @override
  String toString() => 'InitialState';
}

/// Loading state - represents ongoing operations
@immutable
final class LoadingState<T> extends BaseState<T> {
  final String? message;
  final double? progress;

  const LoadingState({this.message, this.progress});

  @override
  List<Object?> get props => [message, progress];

  @override
  String toString() => 'LoadingState(message: $message, progress: $progress)';
}

/// Success state - represents successful operations
@immutable
final class SuccessState<T> extends BaseState<T> implements AppSuccessState {
  @override
  final String successMessage;
  final Map<String, dynamic>? metadata;

  const SuccessState({
    required this.successMessage,
    this.metadata,
  });

  @override
  List<Object?> get props => [successMessage, metadata];

  @override
  String toString() => 'SuccessState(message: $successMessage)';
}

/// Error state - represents error conditions
@immutable
final class ErrorState<T> extends BaseState<T> implements AppErrorState {
  @override
  final String errorMessage;
  final Exception? exception;
  final StackTrace? stackTrace;
  final String? errorCode;
  final bool isRetryable;

  const ErrorState({
    required this.errorMessage,
    this.exception,
    this.stackTrace,
    this.errorCode,
    this.isRetryable = true,
  });

  @override
  List<Object?> get props => [errorMessage, exception, errorCode, isRetryable];

  @override
  String toString() => 'ErrorState(message: $errorMessage, code: $errorCode)';
}

/// Data state - represents states that contain data
@immutable
sealed class DataState<T> extends BaseState<T> {
  @override
  final T? data;

  const DataState({this.data});

  @override
  List<Object?> get props => [data];
}

/// Loaded state - represents successfully loaded data
@immutable
final class LoadedState<T> extends DataState<T> {
  final DateTime? lastUpdated;
  final bool isFromCache;

  const LoadedState({
    required T data,
    this.lastUpdated,
    this.isFromCache = false,
  }) : super(data: data);

  @override
  List<Object?> get props => [data, lastUpdated, isFromCache];

  @override
  String toString() => 'LoadedState(data: $data, fromCache: $isFromCache)';
}

/// Empty state - represents successful operation but no data
@immutable
final class EmptyState<T> extends DataState<T> {
  final String? message;

  const EmptyState({this.message}) : super(data: null);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'EmptyState(message: $message)';
}

/// Async state - for managing asynchronous operations with data
@immutable
sealed class AsyncState<T> extends DataState<T> {
  final bool isRefreshing;
  final String? operationId;

  const AsyncState({
    super.data,
    this.isRefreshing = false,
    this.operationId,
  });

  @override
  List<Object?> get props => [data, isRefreshing, operationId];
}

/// Async loading state - loading with optional existing data
@immutable
final class AsyncLoadingState<T> extends AsyncState<T> {
  final String? message;
  final double? progress;

  const AsyncLoadingState({
    super.data,
    this.message,
    this.progress,
    super.isRefreshing = false,
    super.operationId,
  });

  @override
  List<Object?> get props => [data, message, progress, isRefreshing, operationId];

  @override
  String toString() => 'AsyncLoadingState(data: ${data != null}, message: $message)';
}

/// Async loaded state - successfully loaded with data
@immutable
final class AsyncLoadedState<T> extends AsyncState<T> {
  final DateTime lastUpdated;
  final bool isFromCache;

  const AsyncLoadedState({
    required super.data,
    required this.lastUpdated,
    this.isFromCache = false,
    super.isRefreshing = false,
    super.operationId,
  });

  @override
  List<Object?> get props => [data, lastUpdated, isFromCache, isRefreshing, operationId];

  @override
  String toString() => 'AsyncLoadedState(data: $data, lastUpdated: $lastUpdated)';
}

/// Async error state - error with optional existing data
@immutable
final class AsyncErrorState<T> extends AsyncState<T> implements AppErrorState {
  @override
  final String errorMessage;
  final Exception? exception;
  final String? errorCode;
  final bool isRetryable;

  const AsyncErrorState({
    required this.errorMessage,
    super.data,
    this.exception,
    this.errorCode,
    this.isRetryable = true,
    super.isRefreshing = false,
    super.operationId,
  });

  @override
  List<Object?> get props => [
        data,
        errorMessage,
        exception,
        errorCode,
        isRetryable,
        isRefreshing,
        operationId,
      ];

  @override
  String toString() => 'AsyncErrorState(data: ${data != null}, error: $errorMessage)';
}