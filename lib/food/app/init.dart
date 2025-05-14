import 'package:flutter/cupertino.dart';

import '../dependency_injection/set_up.dart';

class AppConfig {
  static void init() async {
    // Initialize app configurations here
    // For example, setting up environment variables, logging, etc.
    WidgetsFlutterBinding.ensureInitialized();
    setupDIService();
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
  }
}
