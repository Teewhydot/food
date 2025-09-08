import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
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
      final result = await operation();
      if (operationName != null) {
        Logger.logSuccess('$operationName completed successfully');
      }
      return Right(result);
    } on FirebaseAuthException catch (e) {
      final message = _getFirebaseAuthMessage(e);
      Logger.logError('Firebase Auth Error${operationName != null ? " in $operationName" : ""}: ${e.code} - $message');
      return Left(AuthFailure(failureMessage: message));
    } on FirebaseException catch (e) {
      final message = _getFirebaseMessage(e);
      Logger.logError('Firebase Error${operationName != null ? " in $operationName" : ""}: ${e.code} - $message');
      return Left(ServerFailure(failureMessage: message));
    } on SocketException catch (_) {
      final message = 'Please check your internet connection and try again';
      Logger.logError('Network Error${operationName != null ? " in $operationName" : ""}: No internet connection');
      return Left(NoInternetFailure(failureMessage: message));
    } on TimeoutException catch (_) {
      final message = 'Request timed out. Please try again';
      Logger.logError('Timeout Error${operationName != null ? " in $operationName" : ""}: Operation timed out');
      return Left(TimeoutFailure(failureMessage: message));
    } on FormatException catch (e) {
      final message = 'Invalid data format. Please try again';
      Logger.logError('Format Error${operationName != null ? " in $operationName" : ""}: ${e.message}');
      return Left(UnknownFailure(failureMessage: message));
    } catch (e) {
      final message = 'Something went wrong. Please try again';
      Logger.logError('Unknown Error${operationName != null ? " in $operationName" : ""}: $e');
      return Left(UnknownFailure(failureMessage: message));
    }
  }

  /// Handle sync operations (for validation, etc.)
  static Either<Failure, T> handleSync<T>(
    T Function() operation, {
    String? operationName,
  }) {
    try {
      final result = operation();
      if (operationName != null) {
        Logger.logSuccess('$operationName completed successfully');
      }
      return Right(result);
    } on FormatException catch (e) {
      final message = 'Invalid data format';
      Logger.logError('Format Error${operationName != null ? " in $operationName" : ""}: ${e.message}');
      return Left(ValidationFailure(failureMessage: message));
    } catch (e) {
      final message = 'Operation failed';
      Logger.logError('Error${operationName != null ? " in $operationName" : ""}: $e');
      return Left(UnknownFailure(failureMessage: message));
    }
  }

  /// Get user-friendly Firebase Auth error messages
  static String _getFirebaseAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address';
      case 'wrong-password':
        return 'Incorrect password. Please try again';
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
}