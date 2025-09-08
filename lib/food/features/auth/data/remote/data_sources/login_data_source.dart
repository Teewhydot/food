import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/services/endpoint_service.dart';

abstract class LoginDataSource {
  Future<UserCredential> logUserInFirebase(String email, String password);
}

// implement firebase login functionality
class FirebaseLoginDSI implements LoginDataSource {
  final _endpointService = EndpointService();
  @override
  Future<UserCredential> logUserInFirebase(
    String email,
    String password,
  ) async {
    final auth = FirebaseAuth.instance;
    return await _endpointService.runWithConfig(
      'logUserInFirebase',
      () => auth.signInWithEmailAndPassword(email: email, password: password),
    );
  }
}
