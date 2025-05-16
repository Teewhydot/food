import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  // Timeout duration for Firebase operations
  final Duration _timeoutDuration = const Duration(seconds: 10);

  // Pre-call interceptor (e.g., logging)
  void _onRequest(String operation) {}

  // Post-call interceptor (e.g., logging)
  void _onResponse(String operation, dynamic result) {}

  // Generic method to handle Firebase operations with timeout, interceptors, and error handling
  Future<T> runWithConfig<T>(
    String operation,
    Future<T> Function() firebaseCall,
  ) async {
    _onRequest(operation);
    try {
      final result = await firebaseCall().timeout(_timeoutDuration);
      _onResponse(operation, result);
      return result;
    } on TimeoutException {
      throw Exception('Operation "$operation" timed out.');
    } on FirebaseAuthException catch (e) {
      throw Exception('FirebaseAuth Error in "$operation": ${e.message}');
    } on FirebaseException catch (e) {
      throw Exception('Firebase Error in "$operation": ${e.message}');
    } on SocketException {
      throw Exception('No internet connection during "$operation".');
    } catch (e) {
      throw Exception('Unknown error in "$operation": $e');
    }
  }
}
