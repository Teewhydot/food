import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/services/paystack_service.dart';
import '../../../../../core/utils/logger.dart';

abstract class PaystackPaymentDataSource {
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

class FirebasePaystackPaymentDataSource implements PaystackPaymentDataSource {
  final PaystackService _paystackService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebasePaystackPaymentDataSource(this._paystackService);

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

      Logger.logBasic('Initializing Paystack payment for order: $orderId');

      final result = await _paystackService.initializePayment(
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
      Logger.logBasic('Verifying Paystack payment: $reference');

      final result = await _paystackService.verifyPayment(
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

      final result = await _paystackService.getTransactionStatus(
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