import 'package:firebase_auth/firebase_auth.dart';

abstract class SignOutDataSource {
  Future<void> signOut();
}

class FirebaseSignOutDSI implements SignOutDataSource {
  @override
  Future<void> signOut() async {
    final auth = FirebaseAuth.instance;
    await auth.signOut();
  }
}
