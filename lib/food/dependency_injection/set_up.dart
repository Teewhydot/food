import 'package:food/food/features/auth/data/remote/data_sources/register_data_source.dart';
import 'package:get_it/get_it.dart';

import '../core/services/firebase_service.dart';
import '../core/services/navigation_service/nav_config.dart';
import '../features/auth/data/remote/data_sources/email_verification_data_source.dart';
import '../features/auth/data/remote/data_sources/login_data_source.dart';

final getIt = GetIt.instance;

void setupDIService() {
  // Register your classes here
  getIt.registerLazySingleton<NavigationService>(() => GetxNavigationService());
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
  getIt.registerLazySingleton<LoginDataSource>(() => FirebaseLoginDSI());
  getIt.registerLazySingleton<RegisterDataSource>(() => FirebaseRegisterDSI());
  getIt.registerLazySingleton<EmailVerificationDataSource>(
    () => FirebaseEmailVerificationDSI(),
  );
}
