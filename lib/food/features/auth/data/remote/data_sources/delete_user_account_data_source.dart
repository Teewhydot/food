import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class DeleteUserAccountDataSource {
  Future<void> deleteUserAccount();
}

class FirebaseDeleteUserAccountDSI implements DeleteUserAccountDataSource {
  @override
  Future<void> deleteUserAccount() async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final user = auth.currentUser;

    if (user != null) {
      // Delete user data from Firestore first
      try {
        await firestore.collection('users').doc(user.uid).delete();
      } catch (e) {
        // If Firestore deletion fails, we can still attempt to delete the auth account
        // Logging the error might be helpful
      }

      // Delete the authentication account
      await user.delete();
    } else {
      throw Exception('No user is currently signed in');
    }
  }
}
