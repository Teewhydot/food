import 'package:get_it/get_it.dart';

import '../core/services/firebase_service.dart';
import '../core/services/navigation_service/nav_config.dart';

final getIt = GetIt.instance;

void setupDIService() {
  // Register your classes here
  // getIt.registerLazySingleton<AuthDataSource>(() => AuthDataSourceFirebase());
  getIt.registerLazySingleton<NavigationService>(() => GetxNavigationService());
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
}
