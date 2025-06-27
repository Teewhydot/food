import 'package:firebase_auth/firebase_auth.dart';

abstract class EmailVerificationDataSource {
  Future<void> sendEmailVerification(String email);
}

class FirebaseEmailVerificationDSI implements EmailVerificationDataSource {
  @override
  Future<void> sendEmailVerification(String email) async {
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;

    if (currentUser != null && currentUser.email == email) {
      // If the user is logged in and email matches, send verification directly
      await currentUser.sendEmailVerification();
    } else {
      // If no user is logged in or emails don't match, we need to create a verification link
      // Firebase doesn't have a direct API to send verification without login, so we send password reset as fallback
      await auth.sendPasswordResetEmail(email: email);
    }
  }
}
