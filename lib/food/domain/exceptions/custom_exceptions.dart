class ServerException implements Exception {}

class NoInternetException implements Exception {}

class UnknownException implements Exception {
  final String? errorMessage;
  UnknownException({this.errorMessage});
}

class TimeoutException implements Exception {}
