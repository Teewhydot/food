abstract class Failure {
  final String failureMessage;
  Failure({required this.failureMessage});
}

class ServerFailure extends Failure {
  ServerFailure({required super.failureMessage});
}

class AuthFailure extends Failure {
  AuthFailure({required super.failureMessage});
}

class ValidationFailure extends Failure {
  ValidationFailure({required super.failureMessage});
}

class CacheFailure extends Failure {
  CacheFailure({required super.failureMessage});
}

class UnknownFailure extends Failure {
  UnknownFailure({required super.failureMessage});
}

class NoInternetFailure extends Failure {
  NoInternetFailure({required super.failureMessage});
}

class TimeoutFailure extends Failure {
  TimeoutFailure({required super.failureMessage});
}

class InvalidDataFailure extends Failure {
  InvalidDataFailure({required super.failureMessage});
}
