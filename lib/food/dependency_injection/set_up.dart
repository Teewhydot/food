import 'package:food/food/features/auth/data/remote/data_sources/register_data_source.dart';
import 'package:get_it/get_it.dart';

import '../core/services/firebase_service.dart';
import '../core/services/navigation_service/nav_config.dart';
import '../features/auth/data/remote/data_sources/delete_user_account_data_source.dart';
import '../features/auth/data/remote/data_sources/email_verification_data_source.dart';
import '../features/auth/data/remote/data_sources/email_verification_status_data_source.dart';
import '../features/auth/data/remote/data_sources/login_data_source.dart';
import '../features/auth/data/remote/data_sources/password_reset_data_source.dart';
import '../features/auth/data/remote/data_sources/sign_out_data_source.dart';
import '../features/auth/data/remote/data_sources/user_data_source.dart';
import '../features/home/data/remote/data_sources/food_remote_data_source.dart';
import '../features/home/data/remote/data_sources/restaurant_remote_data_source.dart';
import '../features/home/data/repositories/food_repository_impl.dart';
import '../features/home/data/repositories/restaurant_repository_impl.dart';
import '../features/home/domain/repositories/food_repository.dart';
import '../features/home/domain/repositories/restaurant_repository.dart';
import '../features/home/domain/use_cases/food_usecase.dart';
import '../features/home/domain/use_cases/restaurant_usecase.dart';
import '../features/payments/data/remote/data_sources/order_remote_data_source.dart';
import '../features/payments/data/remote/data_sources/payment_remote_data_source.dart';
import '../features/payments/data/repositories/payment_repository_impl.dart';
import '../features/payments/domain/repositories/payment_repository.dart';
import '../features/payments/domain/use_cases/order_usecase.dart';
import '../features/payments/domain/use_cases/payment_usecase.dart';
import '../features/tracking/data/remote/data_sources/chat_remote_data_source.dart';
import '../features/tracking/data/remote/data_sources/notification_remote_data_source.dart';
import '../features/tracking/data/repositories/chat_repository_impl.dart';
import '../features/tracking/data/repositories/notification_repository_impl.dart';
import '../features/tracking/domain/repositories/chat_repository.dart';
import '../features/tracking/domain/repositories/notification_repository.dart';
import '../features/tracking/domain/use_cases/chat_usecase.dart';
import '../features/tracking/domain/use_cases/notification_usecase.dart';
import '../features/home/data/remote/data_sources/address_remote_data_source.dart';
import '../features/home/data/remote/data_sources/user_profile_remote_data_source.dart';
import '../features/home/data/remote/data_sources/favorites_remote_data_source.dart';
import '../features/home/data/repositories/address_repository_impl.dart';
import '../features/home/data/repositories/user_profile_repository_impl.dart';
import '../features/home/data/repositories/favorites_repository_impl.dart';
import '../features/home/domain/repositories/address_repository.dart';
import '../features/home/domain/repositories/user_profile_repository.dart';
import '../features/home/domain/repositories/favorites_repository.dart';
import '../features/home/domain/use_cases/address_usecase.dart';
import '../features/home/domain/use_cases/user_profile_usecase.dart';
import '../features/home/domain/use_cases/favorites_usecase.dart';
import '../core/services/floor_db_service/address/address_database_service.dart';
import '../core/services/floor_db_service/user_profile/user_profile_database_service.dart';

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
  getIt.registerLazySingleton<DeleteUserAccountDataSource>(
    () => FirebaseDeleteUserAccountDSI(),
  );
  getIt.registerLazySingleton<EmailVerificationStatusDataSource>(
    () => FirebaseEmailVerificationStatusDSI(),
  );
  getIt.registerLazySingleton<PasswordResetDataSource>(
    () => FirebasePasswordResetDSI(),
  );
  getIt.registerLazySingleton<SignOutDataSource>(() => FirebaseSignOutDSI());
  getIt.registerLazySingleton<UserDataSource>(() => FirebaseUserDSI());
  
  // Home feature dependencies
  getIt.registerLazySingleton<RestaurantRemoteDataSource>(
    () => FirebaseRestaurantRemoteDataSource(),
  );
  getIt.registerLazySingleton<FoodRemoteDataSource>(
    () => FirebaseFoodRemoteDataSource(),
  );
  getIt.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(
      remoteDataSource: getIt<RestaurantRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<FoodRepository>(
    () => FoodRepositoryImpl(
      remoteDataSource: getIt<FoodRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<RestaurantUseCase>(
    () => RestaurantUseCase(getIt<RestaurantRepository>()),
  );
  getIt.registerLazySingleton<FoodUseCase>(
    () => FoodUseCase(getIt<FoodRepository>()),
  );
  
  // Payment feature dependencies
  getIt.registerLazySingleton<PaymentRemoteDataSource>(
    () => FirebasePaymentRemoteDataSource(),
  );
  getIt.registerLazySingleton<OrderRemoteDataSource>(
    () => FirebaseOrderRemoteDataSource(),
  );
  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(
      paymentRemoteDataSource: getIt<PaymentRemoteDataSource>(),
      orderRemoteDataSource: getIt<OrderRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<PaymentUseCase>(
    () => PaymentUseCase(getIt<PaymentRepository>()),
  );
  getIt.registerLazySingleton<OrderUseCase>(
    () => OrderUseCase(getIt<PaymentRepository>()),
  );
  
  // Chat/Tracking feature dependencies
  getIt.registerLazySingleton<ChatRemoteDataSource>(
    () => FirebaseChatRemoteDataSource(),
  );
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: getIt<ChatRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<ChatUseCase>(
    () => ChatUseCase(getIt<ChatRepository>()),
  );
  
  // Notification dependencies
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => FirebaseNotificationRemoteDataSource(),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: getIt<NotificationRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<NotificationUseCase>(
    () => NotificationUseCase(getIt<NotificationRepository>()),
  );
  
  // Address dependencies
  getIt.registerLazySingleton<AddressRemoteDataSource>(
    () => FirebaseAddressRemoteDataSource(),
  );
  getIt.registerLazySingleton<AddressDatabaseService>(
    () => AddressDatabaseService(),
  );
  getIt.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(
      remoteDataSource: getIt<AddressRemoteDataSource>(),
      localDataSource: getIt<AddressDatabaseService>(),
    ),
  );
  getIt.registerLazySingleton<AddressUseCase>(
    () => AddressUseCase(getIt<AddressRepository>()),
  );
  
  // User Profile dependencies
  getIt.registerLazySingleton<UserProfileRemoteDataSource>(
    () => FirebaseUserProfileRemoteDataSource(),
  );
  getIt.registerLazySingleton<UserProfileDatabaseService>(
    () => UserProfileDatabaseService(),
  );
  getIt.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(
      remoteDataSource: getIt<UserProfileRemoteDataSource>(),
      localDataSource: getIt<UserProfileDatabaseService>(),
    ),
  );
  getIt.registerLazySingleton<UserProfileUseCase>(
    () => UserProfileUseCase(getIt<UserProfileRepository>()),
  );
  
  // Favorites dependencies
  getIt.registerLazySingleton<FavoritesRemoteDataSource>(
    () => FirebaseFavoritesRemoteDataSource(),
  );
  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(
      remoteDataSource: getIt<FavoritesRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<FavoritesUseCase>(
    () => FavoritesUseCase(getIt<FavoritesRepository>()),
  );
}
