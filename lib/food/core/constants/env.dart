import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  //Golang Base Url
  static String get golangBaseUrl {
    if (kIsWeb) {
      return const String.fromEnvironment(
        'GOLANG_BASE_URL',
        defaultValue: 'https://food-backend-rho.vercel.app',
      );
    }

    try {
      // Try to get from dotenv, but don't fail if not initialized
      return dotenv.env['GOLANG_BASE_URL'] ??
          'https://food-backend-rho.vercel.app';
    } catch (e) {
      // If dotenv is not initialized, return the default URL
      if (kDebugMode) {
        debugPrint('Warning: dotenv not initialized when accessing GOLANG_BASE_URL: $e');
      }
      return 'https://food-backend-rho.vercel.app';
    }
  }
  // Google Maps API Key
  static String? get mapsKey =>
      kIsWeb
          ? const String.fromEnvironment('GOOGLE_MAPS_API_KEY')
          : dotenv.env['GOOGLE_MAPS_API_KEY'];

  // OpenWeatherMap API Key
  static String? get openWeatherMapKey =>
      kIsWeb
          ? const String.fromEnvironment('OPENWEATHERMAP_API_KEY')
          : dotenv.env['OPENWEATHERMAP_API_KEY'];

  // Debug Mode
  static bool get debugMode =>
      kIsWeb
          ? const String.fromEnvironment('DEBUG_MODE').toLowerCase() ==
                  'true' ||
              kDebugMode
          : dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true' || kDebugMode;

  // API Configuration
  static String get baseUrl =>
      kIsWeb
          ? const String.fromEnvironment(
            'BASE_URL',
            defaultValue: 'https://api.example.com',
          )
          : dotenv.env['BASE_URL'] ?? 'https://api.example.com';

  static String get apiVersion =>
      kIsWeb
          ? const String.fromEnvironment('API_VERSION', defaultValue: 'v1')
          : dotenv.env['API_VERSION'] ?? 'v1';

  // Firebase Cloud Functions URL
  static String get firebaseCloudFunctionsUrl {
    if (kIsWeb) {
      return const String.fromEnvironment(
        'DFOOD_FIREBASE_FUNCTIONS_URL',
        defaultValue: 'https://us-central1-sirteefy-food.cloudfunctions.net',
      );
    }

    try {
      // Try to get from dotenv, but don't fail if not initialized
      return dotenv.env['DFOOD_FIREBASE_FUNCTIONS_URL'] ??
          'https://us-central1-sirteefy-food.cloudfunctions.net';
    } catch (e) {
      // If dotenv is not initialized, return the hardcoded URL
      return 'https://us-central1-sirteefy-food.cloudfunctions.net';
    }
  }

  // Flutterwave v3 Configuration
  // v3 uses Secret Key authentication instead of OAuth 2.0
  // Environment is determined by the key prefix:
  // - TEST keys: FLWSECK_TEST-xxx, FLWPUBK_TEST-xxx
  // - LIVE keys: FLWSECK-xxx, FLWPUBK-xxx

  static String? get flutterwaveSecretKey =>
      kIsWeb
          ? const String.fromEnvironment('FLUTTERWAVE_SECRET_KEY')
          : dotenv.env['FLUTTERWAVE_SECRET_KEY'];

  static String? get flutterwavePublicKey =>
      kIsWeb
          ? const String.fromEnvironment('FLUTTERWAVE_PUBLIC_KEY')
          : dotenv.env['FLUTTERWAVE_PUBLIC_KEY'];

  static String? get flutterwaveEncryptionKey =>
      kIsWeb
          ? const String.fromEnvironment('FLUTTERWAVE_ENCRYPTION_KEY')
          : dotenv.env['FLUTTERWAVE_ENCRYPTION_KEY'];

  static String? get flutterwaveSecretHash =>
      kIsWeb
          ? const String.fromEnvironment('FLUTTERWAVE_SECRET_HASH')
          : dotenv.env['FLUTTERWAVE_SECRET_HASH'];

  // Check if v3 credentials are configured
  static bool get hasFlutterwaveCredentials =>
      flutterwaveSecretKey != null &&
      flutterwaveSecretKey!.isNotEmpty;

  // Determine if using production keys (LIVE keys don't have _TEST- prefix)
  static bool get isFlutterwaveProduction {
    final key = flutterwaveSecretKey ?? '';
    return key.startsWith('FLWSECK-') && !key.startsWith('FLWSECK_TEST-');
  }

  // SECURITY: Card Encryption Key Configuration
  // NEVER hardcode encryption keys in source code!
  static String? get cardEncryptionKey {
    if (kIsWeb) {
      return const String.fromEnvironment('CARD_ENCRYPTION_KEY');
    } else {
      try {
        return dotenv.env['CARD_ENCRYPTION_KEY'];
      } catch (e) {
        // dotenv not initialized yet
        if (kDebugMode) {
          debugPrint(
            'Warning: dotenv not initialized when accessing CARD_ENCRYPTION_KEY: $e',
          );
        }
        return null;
      }
    }
  }

  // Check if encryption key is properly configured
  static bool get hasCardEncryptionKey =>
      cardEncryptionKey != null && cardEncryptionKey!.isNotEmpty;

  // Flutterwave v3 API Configuration
  // v3 uses a single base URL for both sandbox and production
  // Environment is determined by the Secret Key prefix
  static String get flutterwaveBaseUrl {
    // v3 uses the same URL for both environments
    return 'https://api.flutterwave.com';
  }

  // Helper method to get environment variable with fallback
  static String getEnvVar(String key, {String fallback = ''}) {
    if (kIsWeb) {
      // For web, use String.fromEnvironment
      // Since we can't use dynamic keys with const, return fallback for web
      // The specific getters above should be used instead
      return fallback;
    }

    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      if (kDebugMode) {
        debugPrint('Warning: Environment variable $key is not set or empty');
      }
      return fallback;
    }
    return value;
  }

  // Helper method to check if all required environment variables are set
  static bool validateRequiredEnvVars() {
    if (kIsWeb) {
      // For web builds, check using the specific getters
      final mapsKeyValid = mapsKey != null && mapsKey!.isNotEmpty;
      if (!mapsKeyValid && kDebugMode) {
        debugPrint(
          'ERROR: Required environment variable GOOGLE_MAPS_API_KEY is missing',
        );
      }
      return mapsKeyValid;
    }

    final requiredVars = ['GOOGLE_MAPS_API_KEY'];
    bool allValid = true;

    for (final varName in requiredVars) {
      if (dotenv.env[varName] == null || dotenv.env[varName]!.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            'ERROR: Required environment variable $varName is missing',
          );
        }
        allValid = false;
      }
    }

    return allValid;
  }
}
