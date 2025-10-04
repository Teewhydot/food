import 'package:firebase_auth/firebase_auth.dart';

abstract class UpdatePasswordDataSource {
  Future<void> updatePassword(String currentPassword, String newPassword);
}

class FirebaseUpdatePasswordDSI implements UpdatePasswordDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found');
    }

    if (user.email == null) {
      throw Exception('User email not available');
    }

    // Re-authenticate user before password update (Firebase requirement)
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      // Re-authenticate
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Current password is incorrect');
      } else if (e.code == 'weak-password') {
        throw Exception('New password is too weak');
      } else if (e.code == 'requires-recent-login') {
        throw Exception('Please log in again to update your password');
      } else {
        throw Exception(e.message ?? 'Failed to update password');
      }
    }
  }
}
