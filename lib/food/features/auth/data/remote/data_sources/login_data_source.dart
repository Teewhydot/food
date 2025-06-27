import 'package:firebase_auth/firebase_auth.dart';

abstract class LoginDataSource {
  Future<UserCredential> logUserInFirebase(String email, String password);
}

// implement firebase login functionality
class LoginDataSourceImplementation implements LoginDataSource {
  @override
  Future<UserCredential> logUserInFirebase(
    String email,
    String password,
  ) async {
    final auth = FirebaseAuth.instance;
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
