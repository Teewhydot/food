import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:food/firebase_options.dart';

import '../dependency_injection/set_up.dart';

class AppConfig {
  static void init() async {
    // Initialize app configurations here
    // For example, setting up environment variables, logging, etc.
    WidgetsFlutterBinding.ensureInitialized();
    setupDIService();
    // await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
