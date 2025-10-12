import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food/food/core/network/dio_client.dart';
import 'package:food/food/core/utils/logger.dart';

import '../../../../../core/services/endpoint_service.dart';

abstract class DeleteUserAccountDataSource {
  Future<void> deleteUserAccount(String email, String token);
}

class FirebaseDeleteUserAccountDSI implements DeleteUserAccountDataSource {
  final _endpointService = EndpointService();

  @override
  Future<void> deleteUserAccount(String email, String token) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final user = auth.currentUser;

    if (user != null) {
      // Delete user data from Firestore first
      try {
        await _endpointService.runWithConfig("delete account", () {
          return firestore.collection('users').doc(user.uid).delete();
        });
      } catch (e) {
        // If Firestore deletion fails, we can still attempt to delete the auth account
        // Logging the error might be helpful
      }

      // Delete the authentication account
      await _endpointService.runWithConfig("delete auth account", () {
        return user.delete();
      });
    } else {
      throw Exception('No user is currently signed in');
    }
  }
}

class GolangDeleteUserAccountDSI implements DeleteUserAccountDataSource {
  final _dioClient = DioClient();

  @override
  Future<void> deleteUserAccount(String email, String token) async {
    Logger.logBasic('GolangDeleteUserAccountDSI.deleteUserAccount() called');
    Logger.logBasic('Making DELETE request to /api/v1/auth/account');
    await _dioClient.delete(
      "/api/v1/auth/account",
      data: {
        "email": email,
        "token": token,
      },
    );
    Logger.logBasic('DELETE request successful');
    Logger.logSuccess('User account deleted successfully');
  }
}
