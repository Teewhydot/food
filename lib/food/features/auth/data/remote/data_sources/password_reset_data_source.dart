import 'package:firebase_auth/firebase_auth.dart';
import 'package:food/food/core/network/dio_client.dart';
import 'package:food/food/core/utils/logger.dart';

abstract class PasswordResetDataSource {
  Future<void> sendPasswordResetEmail(String email);
}

class FirebasePasswordResetDSI implements PasswordResetDataSource {
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final auth = FirebaseAuth.instance;
    await auth.sendPasswordResetEmail(email: email);
  }
}

class GolangPasswordResetDSI implements PasswordResetDataSource {
  final _dioClient = DioClient();

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    Logger.logBasic('GolangPasswordResetDSI.sendPasswordResetEmail() called');
    Logger.logBasic('Making POST request to /api/v1/auth/forgot-password');
    await _dioClient.post(
      "/api/v1/auth/forgot-password",
      requestBody: {"email": email},
    );
    Logger.logBasic('POST request successful');
    Logger.logSuccess('Password reset email sent successfully');
  }
}
