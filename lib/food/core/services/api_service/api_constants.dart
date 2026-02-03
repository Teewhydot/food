class ApiConstants {
  static const timeOutInSeconds = Duration(seconds: 30);
  static const String internetConnection =
      "Please check your Internet connection";
  static const String timeOut = "Service Timeout";
  static const String errorMessage = "An error occurred, please try again";

  // Flutterwave API Endpoints (v3)
  static const String flutterwaveCharges = '/v3/charges';
  static const String flutterwaveValidateCharge = '/v3/validate-charge';
  static const String flutterwaveTransactions = '/v3/transactions';
  static const String flutterwaveTransactionVerify = '/v3/transactions/';
}
