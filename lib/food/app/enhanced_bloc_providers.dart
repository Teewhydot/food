import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../core/bloc/factories/bloc_factory.dart';
import '../features/auth/presentation/manager/auth_bloc/delete_account/delete_account_bloc.dart';
import '../features/auth/presentation/manager/auth_bloc/email_verification/email_verification_bloc.dart';
import '../features/auth/presentation/manager/auth_bloc/email_verification_status/email_verification_status_bloc.dart';
import '../features/auth/presentation/manager/auth_bloc/forgot_password/forgot_password_bloc.dart';
import '../features/auth/presentation/manager/auth_bloc/login/login_bloc.dart';
import '../features/auth/presentation/manager/auth_bloc/otp_verification/verification_bloc.dart';
import '../features/auth/presentation/manager/auth_bloc/register/register_bloc.dart';
import '../features/auth/presentation/manager/auth_bloc/sign_out/sign_out_bloc.dart';
import '../features/auth/presentation/manager/location_bloc/location_bloc.dart';
import '../features/home/manager/address/address_cubit.dart';
import '../features/home/manager/favorites/favorites_cubit.dart';
import '../features/home/manager/recent_keywords/recent_keywords_cubit.dart';
import '../features/home/manager/user_profile/enhanced_user_profile_cubit.dart';
import '../features/home/presentation/manager/food_bloc/food_bloc.dart';
import '../features/home/presentation/manager/restaurant_bloc/restaurant_bloc.dart';
import '../features/home/presentation/manager/search_bloc/search_bloc.dart';
import '../features/payments/presentation/manager/cart/cart_cubit.dart';
import '../features/payments/presentation/manager/order_bloc/order_bloc.dart';
import '../features/payments/presentation/manager/payment_bloc/payment_bloc.dart';
import '../features/tracking/presentation/manager/chats_bloc/chats_cubit.dart';
import '../features/tracking/presentation/manager/messaging_bloc/messaging_bloc.dart';
import '../features/tracking/presentation/manager/notification_bloc/notification_cubit.dart';

/// Enhanced BloC providers setup with factory pattern and dependency injection
class EnhancedBlocProviders {
  static final BlocFactoryManager _factoryManager = BlocFactoryManager();

  /// Initialize all BLoC factories
  static void initializeFactories() {
    _registerAuthFactories();
    _registerHomeFactories();
    _registerPaymentFactories();
    _registerTrackingFactories();
  }

  /// Register authentication-related BLoC factories
  static void _registerAuthFactories() {
    // Login BLoC - per-session singleton
    _factoryManager.registerFactory<LoginBloc>(
      SingletonBlocFactory(() => LoginBloc(), factoryName: 'LoginBloc'),
    );

    // Register BLoC - new instance for each registration flow
    _factoryManager.registerFactory<RegisterBloc>(
      DefaultBlocFactory(() => RegisterBloc(), factoryName: 'RegisterBloc'),
    );

    // Forgot Password BLoC - new instance per flow
    _factoryManager.registerFactory<ForgotPasswordBloc>(
      DefaultBlocFactory(() => ForgotPasswordBloc(), factoryName: 'ForgotPasswordBloc'),
    );

    // Verification BLoC - new instance per verification
    _factoryManager.registerFactory<VerificationBloc>(
      DefaultBlocFactory(() => VerificationBloc(), factoryName: 'VerificationBloc'),
    );

    // Email Verification BLoC - new instance per verification
    _factoryManager.registerFactory<VerifyEmailBloc>(
      DefaultBlocFactory(() => VerifyEmailBloc(), factoryName: 'VerifyEmailBloc'),
    );

    // Email Verification Status BLoC
    _factoryManager.registerFactory<EmailVerificationBloc>(
      DefaultBlocFactory(() => EmailVerificationBloc(), factoryName: 'EmailVerificationBloc'),
    );

    // Delete Account BLoC - singleton for session
    _factoryManager.registerFactory<DeleteAccountBloc>(
      SingletonBlocFactory(() => DeleteAccountBloc(), factoryName: 'DeleteAccountBloc'),
    );

    // Sign Out BLoC - singleton
    _factoryManager.registerFactory<SignOutBloc>(
      SingletonBlocFactory(() => SignOutBloc(), factoryName: 'SignOutBloc'),
    );

    // Location BLoC - singleton (shared location state)
    _factoryManager.registerFactory<LocationBloc>(
      SingletonBlocFactory(() => LocationBloc(), factoryName: 'LocationBloc'),
    );
  }

  /// Register home feature BLoC factories
  static void _registerHomeFactories() {
    // User Profile Cubit - singleton (user data is shared)
    _factoryManager.registerFactory<EnhancedUserProfileCubit>(
      SingletonBlocFactory(
        () => EnhancedUserProfileCubit()..initialize(),
        factoryName: 'EnhancedUserProfileCubit',
      ),
    );

    // Address Cubit - singleton (address data is shared)
    _factoryManager.registerFactory<AddressCubit>(
      SingletonBlocFactory(
        () => AddressCubit()..loadAddresses(),
        factoryName: 'AddressCubit',
      ),
    );

    // Recent Keywords Cubit - singleton
    _factoryManager.registerFactory<RecentKeywordsCubit>(
      SingletonBlocFactory(() => RecentKeywordsCubit(), factoryName: 'RecentKeywordsCubit'),
    );

    // Favorites Cubit - singleton
    _factoryManager.registerFactory<FavoritesCubit>(
      SingletonBlocFactory(
        () => GetIt.instance.isRegistered<FavoritesCubit>()
            ? GetIt.instance<FavoritesCubit>()
            : FavoritesCubit(GetIt.instance()),
        factoryName: 'FavoritesCubit',
      ),
    );

    // Restaurant BLoC - scoped to home feature
    _factoryManager.registerFactory<RestaurantBloc>(
      ScopedBlocFactory(
        () => RestaurantBloc(restaurantUseCase: GetIt.instance()),
        'home',
        factoryName: 'RestaurantBloc',
      ),
    );

    // Food BLoC - scoped to home feature
    _factoryManager.registerFactory<FoodBloc>(
      ScopedBlocFactory(
        () => FoodBloc(foodUseCase: GetIt.instance()),
        'home',
        factoryName: 'FoodBloc',
      ),
    );

    // Search BLoC - new instance per search session
    _factoryManager.registerFactory<SearchBloc>(
      DefaultBlocFactory(
        () => SearchBloc(
          foodUseCase: GetIt.instance(),
          restaurantUseCase: GetIt.instance(),
        ),
        factoryName: 'SearchBloc',
      ),
    );
  }

  /// Register payment feature BLoC factories
  static void _registerPaymentFactories() {
    // Cart Cubit - singleton (cart is shared across app)
    _factoryManager.registerFactory<CartCubit>(
      SingletonBlocFactory(() => CartCubit(), factoryName: 'CartCubit'),
    );

    // Payment BLoC - new instance per payment flow
    _factoryManager.registerFactory<PaymentBloc>(
      DefaultBlocFactory(
        () => PaymentBloc(paymentUseCase: GetIt.instance()),
        factoryName: 'PaymentBloc',
      ),
    );

    // Order BLoC - scoped to payment feature
    _factoryManager.registerFactory<OrderBloc>(
      ScopedBlocFactory(
        () => OrderBloc(orderUseCase: GetIt.instance()),
        'payment',
        factoryName: 'OrderBloc',
      ),
    );
  }

  /// Register tracking feature BLoC factories
  static void _registerTrackingFactories() {
    // Notification Cubit - singleton
    _factoryManager.registerFactory<NotificationCubit>(
      SingletonBlocFactory(
        () => NotificationCubit()..loadNotifications(),
        factoryName: 'NotificationCubit',
      ),
    );

    // Chats Cubit - singleton (chat list is shared)
    _factoryManager.registerFactory<ChatsCubit>(
      SingletonBlocFactory(
        () => ChatsCubit(chatUseCase: GetIt.instance())..loadChats(),
        factoryName: 'ChatsCubit',
      ),
    );

    // Messaging BLoC - new instance per chat session
    _factoryManager.registerFactory<MessagingBloc>(
      DefaultBlocFactory(
        () => MessagingBloc(chatUseCase: GetIt.instance()),
        factoryName: 'MessagingBloc',
      ),
    );
  }

  /// Create MultiBlocProvider with all registered factories
  static MultiBlocProvider createAppBlocProvider({required Widget child}) {
    return MultiBlocProviderBuilder()
        // Auth BLoCs
        .addFromRegistry<LoginBloc, dynamic>()
        .addFromRegistry<RegisterBloc, dynamic>()
        .addFromRegistry<ForgotPasswordBloc, dynamic>()
        .addFromRegistry<VerificationBloc, dynamic>()
        .addFromRegistry<VerifyEmailBloc, dynamic>()
        .addFromRegistry<EmailVerificationBloc, dynamic>()
        .addFromRegistry<DeleteAccountBloc, dynamic>()
        .addFromRegistry<SignOutBloc, dynamic>()
        .addFromRegistry<LocationBloc, dynamic>()
        // Home BLoCs
        .addFromRegistry<EnhancedUserProfileCubit, dynamic>()
        .addFromRegistry<AddressCubit, dynamic>()
        .addFromRegistry<RecentKeywordsCubit, dynamic>()
        .addFromRegistry<FavoritesCubit, dynamic>()
        .addFromRegistry<RestaurantBloc, dynamic>()
        .addFromRegistry<FoodBloc, dynamic>()
        .addFromRegistry<SearchBloc, dynamic>()
        // Payment BLoCs
        .addFromRegistry<CartCubit, dynamic>()
        .addFromRegistry<PaymentBloc, dynamic>()
        .addFromRegistry<OrderBloc, dynamic>()
        // Tracking BLoCs
        .addFromRegistry<NotificationCubit, dynamic>()
        .addFromRegistry<ChatsCubit, dynamic>()
        .addFromRegistry<MessagingBloc, dynamic>()
        .build(child: child);
  }

  /// Create feature-specific BlocProvider
  static MultiBlocProvider createFeatureBlocProvider({
    required String feature,
    required Widget child,
  }) {
    final builder = MultiBlocProviderBuilder();

    switch (feature) {
      case 'auth':
        return builder
            .addFromRegistry<LoginBloc, dynamic>()
            .addFromRegistry<RegisterBloc, dynamic>()
            .addFromRegistry<ForgotPasswordBloc, dynamic>()
            .addFromRegistry<VerificationBloc, dynamic>()
            .addFromRegistry<LocationBloc, dynamic>()
            .build(child: child);

      case 'home':
        return builder
            .addFromRegistry<EnhancedUserProfileCubit, dynamic>()
            .addFromRegistry<AddressCubit, dynamic>()
            .addFromRegistry<FavoritesCubit, dynamic>()
            .addFromRegistry<RestaurantBloc, dynamic>()
            .addFromRegistry<FoodBloc, dynamic>()
            .addFromRegistry<SearchBloc, dynamic>()
            .build(child: child);

      case 'payment':
        return builder
            .addFromRegistry<CartCubit, dynamic>()
            .addFromRegistry<PaymentBloc, dynamic>()
            .addFromRegistry<OrderBloc, dynamic>()
            .build(child: child);

      case 'tracking':
        return builder
            .addFromRegistry<NotificationCubit, dynamic>()
            .addFromRegistry<ChatsCubit, dynamic>()
            .addFromRegistry<MessagingBloc, dynamic>()
            .build(child: child);

      default:
        throw ArgumentError('Unknown feature: $feature');
    }
  }

  /// Lazy load BLoCs for specific screens
  static Future<MultiBlocProvider> createLazyBlocProvider({
    required List<String> blocTypes,
    required Widget child,
  }) async {
    final builder = MultiBlocProviderBuilder();

    for (final blocType in blocTypes) {
      // Add BLoCs based on type string
      switch (blocType) {
        case 'search':
          builder.addFromRegistry<SearchBloc, dynamic>();
          break;
        case 'payment':
          builder.addFromRegistry<PaymentBloc, dynamic>();
          break;
        case 'messaging':
          builder.addFromRegistry<MessagingBloc, dynamic>();
          break;
        // Add more as needed
      }
    }

    return builder.build(child: child);
  }

  /// Dispose feature-specific BLoCs
  static Future<void> disposeFeatureBloCs(String feature) async {
    final factory = _factoryManager.getNamedFactory(feature);
    if (factory is ScopedBlocFactory) {
      await factory.disposeScope(feature);
    }
  }

  /// Dispose all singleton BLoCs (for app shutdown)
  static Future<void> disposeAllSingletons() async {
    await _factoryManager.disposeAllSingletons();
  }

  /// Get factory manager instance for advanced usage
  static BlocFactoryManager get factoryManager => _factoryManager;
}