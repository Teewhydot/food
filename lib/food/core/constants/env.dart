import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  // Google Maps API Key
  static String? get mapsKey => dotenv.env['GOOGLE_MAPS_API_KEY'];
  
  // OpenWeatherMap API Key  
  static String? get openWeatherMapKey => dotenv.env['OPENWEATHERMAP_API_KEY'];
  
  // Debug Mode
  static bool get debugMode => 
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true' || kDebugMode;
  
  // API Configuration
  static String get baseUrl => 
      dotenv.env['BASE_URL'] ?? 'https://api.example.com';
  
  static String get apiVersion => 
      dotenv.env['API_VERSION'] ?? 'v1';
  
  // Helper method to get environment variable with fallback
  static String getEnvVar(String key, {String fallback = ''}) {
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
    final requiredVars = ['GOOGLE_MAPS_API_KEY'];
    bool allValid = true;
    
    for (final varName in requiredVars) {
      if (dotenv.env[varName] == null || dotenv.env[varName]!.isEmpty) {
        if (kDebugMode) {
          debugPrint('ERROR: Required environment variable $varName is missing');
        }
        allValid = false;
      }
    }
    
    return allValid;
  }
}
