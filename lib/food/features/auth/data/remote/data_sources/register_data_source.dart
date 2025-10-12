import 'package:food/food/core/network/dio_client.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';

abstract class RegisterDataSource {
  Future<UserProfileEntity> registerUser(
    String firstName,
    String lastName,
    String email,
    String phoneNumber,
    String password,
  );
}

// implement firebase login functionality
// class FirebaseRegisterDSI implements RegisterDataSource {
//   @override
//   Future<UserCredential> registerUsers(String email, String password) async {
//     final auth = FirebaseAuth.instance;
//     return await auth.createUserWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//   }
// }

class GolangRegisterDSI implements RegisterDataSource {
  final _dioClient = DioClient();

  @override
  Future<UserProfileEntity> registerUser(
    String firstName,
    String lastName,
    String email,
    String phoneNumber,
    String password,
  ) async {
    Logger.logBasic('GolangRegisterDSI.registerUserGolang() called');
    Logger.logBasic('Making POST request to /api/v1/auth/register');
    final res = await _dioClient.post(
      "/api/v1/auth/register",
      requestBody: {
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone_number": phoneNumber,
        "password": password,
      },
    );
    Logger.logBasic('POST request successful, parsing response');
    final data = res.data;
    final userData = data['user'];
    final user = UserProfileEntity.fromJson(userData);
    Logger.logSuccess('User profile parsed successfully');
    return user;
  }
}
