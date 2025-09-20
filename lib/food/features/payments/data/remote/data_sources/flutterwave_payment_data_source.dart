import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/services/flutterwave_service.dart';
import '../../../../../core/utils/logger.dart';

abstract class FlutterwavePaymentDataSource {
  Future<Map<String, dynamic>> initializePayment({
    required String orderId,
    required double amount,
    required String email,
    required Map<String, dynamic>? metadata,
  });

  Future<Map<String, dynamic>> verifyPayment({
    required String reference,
    required String orderId,
  });

  Future<Map<String, dynamic>> getTransactionStatus({
    required String reference,
  });
}

class FirebaseFlutterwavePaymentDataSource implements FlutterwavePaymentDataSource {
  final FlutterwaveService _flutterwaveService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseFlutterwavePaymentDataSource(this._flutterwaveService);

  @override
  Future<Map<String, dynamic>> initializePayment({
    required String orderId,
    required double amount,
    required String email,
    required Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      Logger.logBasic('Initializing Flutterwave payment for order: $orderId');

      final result = await _flutterwaveService.initializePayment(
        orderId: orderId,
        amount: amount,
        email: email,
        userId: user.uid,
        metadata: metadata,
      );

      Logger.logSuccess('Payment initialization successful');
      return result;
    } catch (e) {
      Logger.logError('Payment initialization failed: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> verifyPayment({
    required String reference,
    required String orderId,
  }) async {
    try {
      Logger.logBasic('Verifying Flutterwave payment: $reference');

      final result = await _flutterwaveService.verifyPayment(
        reference: reference,
        orderId: orderId,
      );

      Logger.logSuccess('Payment verification completed');
      return result;
    } catch (e) {
      Logger.logError('Payment verification failed: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getTransactionStatus({
    required String reference,
  }) async {
    try {
      Logger.logBasic('Getting transaction status: $reference');

      final result = await _flutterwaveService.getTransactionStatus(
        reference: reference,
      );

      Logger.logSuccess('Transaction status retrieved');
      return result;
    } catch (e) {
      Logger.logError('Failed to get transaction status: $e');
      rethrow;
    }
  }
}