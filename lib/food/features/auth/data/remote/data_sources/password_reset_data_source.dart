import 'package:firebase_auth/firebase_auth.dart';

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
