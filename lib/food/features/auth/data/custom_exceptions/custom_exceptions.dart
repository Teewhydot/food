class LoginException implements Exception {}

class GeneralException implements Exception {}

class SignUpException implements Exception {}

class UserNotAuthenticatedException implements Exception {
  final String message;
  UserNotAuthenticatedException(this.message);
  
  @override
  String toString() => 'UserNotAuthenticatedException: $message';
}
