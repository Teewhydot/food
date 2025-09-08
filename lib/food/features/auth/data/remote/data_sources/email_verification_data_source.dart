import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/services/endpoint_service.dart';

abstract class EmailVerificationDataSource {
  Future<void> sendEmailVerification(String email);
}

class FirebaseEmailVerificationDSI implements EmailVerificationDataSource {
  final _endpointService = EndpointService();

  @override
  Future<void> sendEmailVerification(String email) async {
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;

    if (currentUser != null && currentUser.email == email) {
      // If the user is logged in and email matches, send verification directly
      await _endpointService.runWithConfig("send email verification", () {
        return currentUser.sendEmailVerification();
      });
    } else {
      // If no user is logged in or emails don't match, we need to create a verification link
      // Firebase doesn't have a direct API to send verification without login, so we send password reset as fallback
      await _endpointService.runWithConfig("send email verification", () {
        return auth.sendPasswordResetEmail(email: email);
      });
    }
  }
}
