import 'package:firebase_auth/firebase_auth.dart';
import 'package:food/food/core/network/dio_client.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';

import '../../../../../core/services/endpoint_service.dart';

abstract class LoginDataSource {
  Future<UserProfileEntity> logUserIn(String email, String password);
}

// implement firebase login functionality
class FirebaseLoginDSI implements LoginDataSource {
  final _endpointService = EndpointService();
  @override
  Future<UserProfileEntity> logUserIn(String email, String password) async {
    final auth = FirebaseAuth.instance;
    final res = await _endpointService.runWithConfig(
      'logUserInFirebase',
      () => auth.signInWithEmailAndPassword(email: email, password: password),
    );
    return UserProfileEntity(
      id: res.user?.uid,
      firstName: res.user?.displayName?.split(' ').first ?? '',
      lastName: res.user?.displayName?.split(' ').last ?? '',
      email: res.user?.email ?? "",
      phoneNumber: res.user?.phoneNumber ?? "",
      firstTimeLogin: false,
    );
  }
}

class GolangLoginDSI implements LoginDataSource {
  final _dioClient = DioClient();
  @override
  Future<UserProfileEntity> logUserIn(String email, String password) async {
    Logger.logBasic('GolangLoginDSI.logUserIn() called');
    try {
      Logger.logBasic('Making POST request to /api/v1/auth/login');
      final res = await _dioClient.post(
        "/api/v1/auth/login",
        requestBody: {"email": email, "password": password},
      );
      Logger.logBasic('POST request successful, parsing response');
      final data = res.data;
      final userData = data['user'];
      final user = UserProfileEntity.fromJson(userData);
      Logger.logSuccess('User profile parsed successfully');
      return user;
    } catch (e) {
      Logger.logError('GolangLoginDSI caught error: Type=${e.runtimeType}, Error=$e');
      rethrow; // Important: rethrow so ErrorHandler can catch it
    }
  }
}
