import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
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
        defaultValue: 'https://us-central1-dfood-5aaf3.cloudfunctions.net',
      );
    }

    try {
      // Try to get from dotenv, but don't fail if not initialized
      return dotenv.env['DFOOD_FIREBASE_FUNCTIONS_URL'] ??
          'https://us-central1-dfood-5aaf3.cloudfunctions.net';
    } catch (e) {
      // If dotenv is not initialized, return the hardcoded URL
      return 'https://us-central1-dfood-5aaf3.cloudfunctions.net';
    }
  }

  // Helper method to get environment variable with fallback
  static String getEnvVar(String key, {String fallback = ''}) {
    if (kIsWeb) {
      // For web, use String.fromEnvironment
      const value = String.fromEnvironment('');
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
