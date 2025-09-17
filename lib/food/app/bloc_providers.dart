import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/delete_account/delete_account_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/email_verification_status/email_verification_status_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/login/enhanced_login_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/otp_verification/verification_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/register/register_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/sign_out/sign_out_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/location_bloc/location_bloc.dart';
import 'package:food/food/features/home/manager/address/address_cubit.dart';
import 'package:food/food/features/home/manager/recent_keywords/recent_keywords_cubit.dart';
import 'package:food/food/features/home/manager/user_profile/enhanced_user_profile_cubit.dart';
import 'package:food/food/features/payments/presentation/manager/cart/cart_cubit.dart';
import 'package:food/food/features/tracking/presentation/manager/chats_bloc/chats_cubit.dart';
import 'package:food/food/features/tracking/presentation/manager/messaging_bloc/messaging_bloc.dart';
import 'package:food/food/features/tracking/presentation/manager/notification_bloc/notification_cubit.dart';
import 'package:get_it/get_it.dart';

import '../features/auth/presentation/manager/auth_bloc/email_verification/email_verification_bloc.dart';
import '../features/auth/presentation/manager/auth_bloc/forgot_password/forgot_password_bloc.dart';
import '../features/file_upload/presentation/manager/file_upload_bloc/file_upload_bloc.dart';
import '../features/home/domain/use_cases/food_usecase.dart';
import '../features/home/domain/use_cases/restaurant_usecase.dart';
import '../features/home/presentation/manager/food_bloc/food_bloc.dart'; // Now FoodCubit
import '../features/home/presentation/manager/restaurant_bloc/restaurant_bloc.dart'; // Now RestaurantCubit
import '../features/home/presentation/manager/search_bloc/search_bloc.dart';
import '../features/payments/domain/use_cases/order_usecase.dart';
import '../features/payments/domain/use_cases/payment_usecase.dart';
import '../features/payments/presentation/manager/order_bloc/order_bloc.dart';
import '../features/payments/presentation/manager/payment_bloc/payment_bloc.dart';
import '../features/tracking/domain/use_cases/chat_usecase.dart';

final List<BlocProvider> blocs = [
  BlocProvider<ForgotPasswordBloc>(create: (context) => ForgotPasswordBloc()),
  BlocProvider<RegisterBloc>(create: (context) => RegisterBloc()),
  BlocProvider<VerificationBloc>(create: (context) => VerificationBloc()),
  BlocProvider<LocationBloc>(create: (context) => LocationBloc()),
  BlocProvider<RecentKeywordsCubit>(create: (context) => RecentKeywordsCubit()),
  BlocProvider<EnhancedLoginBloc>(create: (context) => EnhancedLoginBloc()),

  BlocProvider<CartCubit>(create: (context) => CartCubit()),
  BlocProvider<EnhancedUserProfileCubit>(
    create: (context) => EnhancedUserProfileCubit()..loadUserProfile(),
  ),
  BlocProvider<AddressCubit>(create: (context) => AddressCubit()),
  BlocProvider<NotificationCubit>(create: (context) => NotificationCubit()),
  BlocProvider<ChatsCubit>(
    create:
        (context) =>
            ChatsCubit(chatUseCase: GetIt.instance<ChatUseCase>())..loadChats(),
  ),
  BlocProvider<MessagingBloc>(
    create:
        (context) => MessagingBloc(chatUseCase: GetIt.instance<ChatUseCase>()),
  ),
  BlocProvider<VerifyEmailBloc>(create: (context) => VerifyEmailBloc()),
  BlocProvider<DeleteAccountBloc>(create: (context) => DeleteAccountBloc()),
  BlocProvider<EmailVerificationBloc>(
    create: (context) => EmailVerificationBloc(),
  ),
  BlocProvider<ForgotPasswordBloc>(create: (context) => ForgotPasswordBloc()),
  BlocProvider<SignOutBloc>(create: (context) => SignOutBloc()),

  // Home feature Cubits (migrated from BLoCs)
  BlocProvider<RestaurantCubit>(
    create:
        (context) => RestaurantCubit(
          restaurantUseCase: GetIt.instance<RestaurantUseCase>(),
        ),
  ),
  BlocProvider<FoodCubit>(
    create: (context) => FoodCubit(foodUseCase: GetIt.instance<FoodUseCase>()),
  ),
  BlocProvider<SearchBloc>(
    create:
        (context) => SearchBloc(
          foodUseCase: GetIt.instance<FoodUseCase>(),
          restaurantUseCase: GetIt.instance<RestaurantUseCase>(),
        ),
  ),

  // Payment feature BLoCs
  BlocProvider<PaymentBloc>(
    create:
        (context) =>
            PaymentBloc(paymentUseCase: GetIt.instance<PaymentUseCase>()),
  ),
  BlocProvider<OrderBloc>(
    create:
        (context) => OrderBloc(orderUseCase: GetIt.instance<OrderUseCase>()),
  ),

  // File upload feature BLoC
  BlocProvider<FileUploadCubit>(create: (context) => FileUploadCubit()),
];
