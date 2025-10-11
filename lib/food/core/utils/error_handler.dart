import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/failures/failures.dart';
import 'logger.dart';

/// Centralized error handler that converts exceptions to Either<Failure, T>
class ErrorHandler {
  /// Handle any async operation and convert exceptions to failures
  static Future<Either<Failure, T>> handle<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    try {
      Logger.logBasic(
        'ErrorHandler.handle() starting${operationName != null ? " for $operationName" : ""}',
      );
      final result = await operation();
      if (operationName != null) {
        Logger.logSuccess('$operationName completed successfully');
      }
      return Right(result);
    } on DioError catch (e, stackTrace) {
      Logger.logError(
        'DioError Caught${operationName != null ? " in $operationName" : ""}: Type=${e.type}, Status=${e.response?.statusCode}, Message=${e.message}',
      );
      Logger.logError('DioError Response Data: ${e.response?.data}');
      final result = _handleDioError(e, operationName);
      Logger.logError(
        'DioError Handled${operationName != null ? " in $operationName" : ""}: ${result.failureMessage}',
      );
      return Left(result);
    } on FirebaseAuthException catch (e) {
      final message = _getFirebaseAuthMessage(e);
      Logger.logError(
        'Firebase Auth Error${operationName != null ? " in $operationName" : ""}: ${e.code} - $message',
      );
      return Left(AuthFailure(failureMessage: message));
    } on FirebaseException catch (e) {
      final message = _getFirebaseMessage(e);
      Logger.logError(
        'Firebase Error${operationName != null ? " in $operationName" : ""}: ${e.code} - $message',
      );
      return Left(ServerFailure(failureMessage: message));
    } on SocketException catch (_) {
      final message = 'Please check your internet connection and try again';
      Logger.logError(
        'Network Error${operationName != null ? " in $operationName" : ""}: No internet connection',
      );
      return Left(NoInternetFailure(failureMessage: message));
    } on TimeoutException catch (_) {
      final message = 'Request timed out. Please try again';
      Logger.logError(
        'Timeout Error${operationName != null ? " in $operationName" : ""}: Operation timed out',
      );
      return Left(TimeoutFailure(failureMessage: message));
    } on FormatException catch (e) {
      final message = 'Invalid data format. Please try again';
      Logger.logError(
        'Format Error${operationName != null ? " in $operationName" : ""}: ${e.message}',
      );
      return Left(UnknownFailure(failureMessage: message));
    } catch (e, stackTrace) {
      Logger.logError(
        'Catch-All Error${operationName != null ? " in $operationName" : ""}: Type=${e.runtimeType}, Error=$e',
      );
      Logger.logError('Stack trace: ${stackTrace.toString()}');

      // Check if this is actually a DioError that wasn't caught above
      if (e is DioError) {
        Logger.logError('ALERT: DioError reached catch-all block!');
        final result = _handleDioError(e, operationName);
        return Left(result);
      }

      return Left(UnknownFailure(failureMessage: e.toString()));
    }
  }

  /// Get user-friendly Firebase Auth error messages
  static String _getFirebaseAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address';
      case 'invalid-credential':
        return 'Incorrect login credentials. Please try again';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-disabled':
        return 'This account has been disabled. Contact support';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Contact support';
      case 'requires-recent-login':
        return 'Please log in again to continue';
      case 'email-already-verified':
        return 'Email is already verified';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again';
      case 'invalid-verification-id':
        return 'Verification session expired. Please try again';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return e.message ?? 'Authentication failed. Please try again';
    }
  }

  /// Handle stream operations and convert exceptions to Either stream
  static Stream<Either<Failure, T>> handleStream<T>(
    Stream<T> Function() streamOperation, {
    String? operationName,
  }) {
    final controller = StreamController<Either<Failure, T>>();

    try {
      final stream = streamOperation();

      stream.listen(
        (data) {
          if (operationName != null) {
            Logger.logSuccess('$operationName: Data received');
          }
          controller.add(Right(data));
        },
        onError: (error, stackTrace) {
          if (error is FirebaseAuthException) {
            final message = _getFirebaseAuthMessage(error);
            Logger.logError(
              'Stream Firebase Auth Error${operationName != null ? " in $operationName" : ""}: ${error.code} - $message',
            );
            controller.add(Left(AuthFailure(failureMessage: message)));
          } else if (error is FirebaseException) {
            final message = _getFirebaseMessage(error);
            Logger.logError(
              'Stream Firebase Error${operationName != null ? " in $operationName" : ""}: ${error.code} - $message',
            );
            controller.add(Left(ServerFailure(failureMessage: message)));
          } else if (error is DioError) {
            final failure = _handleDioError(error, operationName);
            controller.add(Left(failure));
          } else if (error is SocketException) {
            final message =
                'Please check your internet connection and try again';
            Logger.logError(
              'Stream Network Error${operationName != null ? " in $operationName" : ""}: No internet connection',
            );
            controller.add(Left(NoInternetFailure(failureMessage: message)));
          } else if (error is TimeoutException) {
            final message = 'Stream timed out. Please try again';
            Logger.logError(
              'Stream Timeout Error${operationName != null ? " in $operationName" : ""}: Operation timed out',
            );
            controller.add(Left(TimeoutFailure(failureMessage: message)));
          } else if (error is FormatException) {
            final message = 'Invalid data format in stream';
            Logger.logError(
              'Stream Format Error${operationName != null ? " in $operationName" : ""}: ${error.message}',
            );
            controller.add(Left(UnknownFailure(failureMessage: message)));
          } else {
            final message = 'Stream error occurred. Please try again';
            Logger.logError(
              'Stream Unknown Error${operationName != null ? " in $operationName" : ""}: $error',
            );
            controller.add(Left(UnknownFailure(failureMessage: message)));
          }
        },
        onDone: () {
          if (operationName != null) {
            Logger.logBasic('$operationName: Stream completed');
          }
          controller.close();
        },
        cancelOnError: false, // Continue stream even after errors
      );
    } catch (e) {
      final message = 'Failed to initialize stream';
      Logger.logError(
        'Stream Initialization Error${operationName != null ? " in $operationName" : ""}: $e',
      );
      controller.add(Left(UnknownFailure(failureMessage: message)));
      controller.close();
    }

    return controller.stream;
  }

  /// Get user-friendly Firebase error messages
  static String _getFirebaseMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You don\'t have permission to perform this action';
      case 'not-found':
        return 'The requested data was not found';
      case 'already-exists':
        return 'This data already exists';
      case 'resource-exhausted':
        return 'Service temporarily unavailable. Please try again';
      case 'failed-precondition':
        return 'Operation cannot be completed at this time';
      case 'aborted':
        return 'Operation was cancelled. Please try again';
      case 'out-of-range':
        return 'Invalid input provided';
      case 'unimplemented':
        return 'This feature is not yet available';
      case 'internal':
        return 'Internal server error. Please try again';
      case 'unavailable':
        return 'Service is temporarily unavailable';
      case 'data-loss':
        return 'Data error occurred. Please try again';
      case 'unauthenticated':
        return 'Please log in to continue';
      case 'deadline-exceeded':
        return 'Request timed out. Please try again';
      case 'cancelled':
        return 'Operation was cancelled';
      default:
        return e.message ?? 'Server error. Please try again';
    }
  }

  /// Handle DioError and convert to appropriate Failure type
  static Failure _handleDioError(DioError e, String? operationName) {
    final prefix = operationName != null ? ' in $operationName' : '';

    switch (e.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        Logger.logError('API Timeout Error$prefix: ${e.message}');
        return TimeoutFailure(
          failureMessage: 'Request timed out. Please try again',
        );

      case DioErrorType.response:
        return _handleBadResponse(e, prefix);

      case DioErrorType.cancel:
        Logger.logError('API Request Cancelled$prefix');
        return UnknownFailure(
          failureMessage: 'Request was cancelled. Please try again',
        );

      case DioErrorType.other:
        Logger.logError('API Connection Error$prefix: ${e.message}');
        if (e.error is SocketException) {
          return NoInternetFailure(
            failureMessage:
                'Please check your internet connection and try again',
          );
        }
        return UnknownFailure(
          failureMessage: 'An unexpected error occurred. Please try again',
        );
    }
  }

  /// Handle HTTP response errors based on status code
  static Failure _handleBadResponse(DioError e, String prefix) {
    final statusCode = e.response?.statusCode ?? 0;
    final message = _extractApiErrorMessage(e.response?.data);

    Logger.logError('API Response Error$prefix: $statusCode - $message');

    switch (statusCode) {
      case 400:
        return UnknownFailure(failureMessage: message);
      case 401:
        return AuthFailure(
          failureMessage:
              message.isEmpty
                  ? 'Session expired. Please log in again'
                  : message,
        );
      case 403:
        return AuthFailure(
          failureMessage:
              message.isEmpty
                  ? 'You don\'t have permission to perform this action'
                  : message,
        );
      case 404:
        return ServerFailure(
          failureMessage:
              message.isEmpty
                  ? 'The requested resource was not found'
                  : message,
        );
      case 409:
        return UnknownFailure(
          failureMessage:
              message.isEmpty ? 'This data already exists' : message,
        );
      case 422:
        return UnknownFailure(
          failureMessage: message.isEmpty ? 'Invalid data provided' : message,
        );
      case 429:
        return ServerFailure(
          failureMessage: 'Too many requests. Please try again later',
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerFailure(
          failureMessage: 'Server error. Please try again later',
        );
      default:
        return ServerFailure(
          failureMessage:
              message.isEmpty ? 'An error occurred. Please try again' : message,
        );
    }
  }

  /// Extract error message from API response data
  static String _extractApiErrorMessage(dynamic data) {
    if (data == null) return '';

    if (data is Map<String, dynamic>) {
      // First, check for Golang backend APIError structure
      // Format: { "code": "error_code", "message": "error message", "details": {...} }
      if (data.containsKey('status_code') && data.containsKey('error')) {
        final message = data['error'].toString();
        if (message.isNotEmpty) return message;
      }
    }

    if (data is String) return data;

    return '';
  }
}
