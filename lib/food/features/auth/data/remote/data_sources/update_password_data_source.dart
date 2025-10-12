import 'package:firebase_auth/firebase_auth.dart';
import 'package:food/food/core/network/dio_client.dart';
import 'package:food/food/core/utils/logger.dart';

abstract class UpdatePasswordDataSource {
  Future<void> updatePassword(
    String email,
    String currentPassword,
    String newPassword,
  );
}

class FirebaseUpdatePasswordDSI implements UpdatePasswordDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> updatePassword(
    String email,
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

class GolangUpdatePasswordDSI implements UpdatePasswordDataSource {
  final _dioClient = DioClient();

  @override
  Future<void> updatePassword(
    String email,
    String currentPassword,
    String newPassword,
  ) async {
    Logger.logBasic('GolangUpdatePasswordDSI.updatePassword() called');
    Logger.logBasic('Making PUT request to /api/v1/auth/password');
    await _dioClient.put(
      "/api/v1/auth/password",
      data: {
        "email": email,
        "current_password": currentPassword,
        "new_password": newPassword,
      },
    );
    Logger.logBasic('PUT request successful');
    Logger.logSuccess('Password updated successfully');
  }
}
