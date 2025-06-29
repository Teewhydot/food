import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:food/firebase_options.dart';
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
    // await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
