class ServerException implements Exception {
  final String? errorMessage;
  ServerException({this.errorMessage});
}

class NoInternetException implements Exception {
  final String? errorMessage;
  NoInternetException({this.errorMessage});
}

class UnknownException implements Exception {
  final String? errorMessage;
  UnknownException({this.errorMessage});
}

class TimeoutException implements Exception {
  final String? errorMessage;
  TimeoutException({this.errorMessage});
}
