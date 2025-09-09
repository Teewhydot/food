import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:food/firebase_options.dart';
import 'package:food/food/core/constants/env.dart';
import 'package:food/food/core/services/floor_db_service/user_profile/user_profile_database_service.dart';

import '../core/services/floor_db_service/address/address_database_service.dart';
import '../core/services/floor_db_service/recent_keywords/recent_keywords_database_service.dart';
import '../dependency_injection/set_up.dart';

class AppConfig {
  static Future<void> init() async {
    // Initialize app configurations here
    // For example, setting up environment variables, logging, etc.
    WidgetsFlutterBinding.ensureInitialized();
    setupDIService();
    await RecentKeywordsDatabaseService().database;
    await AddressDatabaseService().database;
    await UserProfileDatabaseService().database;
    // For web builds (like Netlify), environment variables are already available
    // For local development, load from .env file
    if (!kIsWeb) {
      try {
        await dotenv.load(fileName: ".env");
        debugPrint('✅ Environment variables loaded successfully');
        
        // Validate required environment variables
        if (!Env.validateRequiredEnvVars()) {
          debugPrint('⚠️ Some required environment variables are missing');
          debugPrint('Please check your .env file and ensure all required variables are set');
        }
      } catch (e) {
        debugPrint('⚠️ Warning: Could not load .env file: $e');
        debugPrint('Continuing with default environment configuration...');
        debugPrint('Please ensure .env file exists in project root with required variables');
      }
    } else {
      debugPrint('🌐 Running on web - using platform environment variables');
    }
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
