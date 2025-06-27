import 'package:firebase_auth/firebase_auth.dart';

abstract class RegisterDataSource {
  Future<UserCredential> registerUser(String email, String password);
}

// implement firebase login functionality
class RegisterDataSourceImplementation implements RegisterDataSource {
  @override
  Future<UserCredential> registerUser(String email, String password) async {
    final auth = FirebaseAuth.instance;
    return await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
