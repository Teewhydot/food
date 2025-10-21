import 'package:firebase_auth/firebase_auth.dart';
import 'package:food/food/core/network/dio_client.dart';
import 'package:food/food/core/utils/logger.dart';

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

class GolangSignOutDSI implements SignOutDataSource {
  final _dioClient = DioClient();

  @override
  Future<void> signOut() async {
    Logger.logBasic('GolangSignOutDSI.signOut() called');
    Logger.logBasic('Making POST request to /api/v1/auth/logout');
    await _dioClient.post("/api/v1/auth/logout");
    Logger.logBasic('POST request successful');

    // Clear stored tokens
    await _dioClient.clearAuthToken();
    Logger.logSuccess('User signed out successfully');
  }
}
