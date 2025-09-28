class ApiConstants {
  static const timeOutInSeconds = Duration(seconds: 30);
  static const String internetConnection =
      "Please check your Internet connection";
  static const String timeOut = "Service Timeout";
  static const String errorMessage = "An error occurred, please try again";

  // Flutterwave API Endpoints (v4)
  static const String flutterwaveOAuthToken = '/oauth/token';
  static const String flutterwaveDirectCharges = '/orchestration/direct-orders';
  static const String flutterwaveTransactions = '/transactions';
  static const String flutterwaveTransactionVerify = '/verify';

  // Cache Keys
  static const String flutterwaveOAuthTokenCacheKey = 'flutterwave_oauth_token';
}
