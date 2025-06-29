import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/delete_account/delete_account_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/email_verification_status/email_verification_status_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/login/login_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/otp_verification/verification_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/register/register_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/sign_out/sign_out_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/location_bloc/location_bloc.dart';
import 'package:food/food/features/home/manager/address/address_cubit.dart';
import 'package:food/food/features/home/manager/recent_keywords/recent_keywords_cubit.dart';
import 'package:food/food/features/home/manager/user_profile/user_profile_cubit.dart';
import 'package:food/food/features/payments/presentation/manager/cart/cart_cubit.dart';
import 'package:food/food/features/tracking/presentation/manager/chats_bloc/chats_cubit.dart';
import 'package:food/food/features/tracking/presentation/manager/messaging_bloc/messaging_bloc.dart';
import 'package:food/food/features/tracking/presentation/manager/notification_bloc/notification_cubit.dart';

import '../features/auth/presentation/manager/auth_bloc/email_verification/email_verification_bloc.dart';
import '../features/auth/presentation/manager/auth_bloc/forgot_password/forgot_password_bloc.dart';

final List<BlocProvider> blocs = [
  BlocProvider<LoginBloc>(create: (context) => LoginBloc()),
  BlocProvider<ForgotPasswordBloc>(create: (context) => ForgotPasswordBloc()),
  BlocProvider<RegisterBloc>(create: (context) => RegisterBloc()),
  BlocProvider<VerificationBloc>(create: (context) => VerificationBloc()),
  BlocProvider<LocationBloc>(create: (context) => LocationBloc()),
  BlocProvider<RecentKeywordsCubit>(create: (context) => RecentKeywordsCubit()),
  BlocProvider<CartCubit>(create: (context) => CartCubit()),
  BlocProvider<UserProfileCubit>(
    create: (context) => UserProfileCubit()..loadUserProfile(),
  ),
  BlocProvider<AddressCubit>(
    create: (context) => AddressCubit()..loadAddresses(),
  ),
  BlocProvider<NotificationCubit>(
    create: (context) => NotificationCubit()..loadNotifications(),
  ),
  BlocProvider<ChatsCubit>(create: (context) => ChatsCubit()..loadChats()),
  BlocProvider<MessagingBloc>(create: (context) => MessagingBloc()),
  BlocProvider<VerifyEmailBloc>(create: (context) => VerifyEmailBloc()),
  BlocProvider<DeleteAccountBloc>(create: (context) => DeleteAccountBloc()),
  BlocProvider<EmailVerificationBloc>(
    create: (context) => EmailVerificationBloc(),
  ),
  BlocProvider<ForgotPasswordBloc>(create: (context) => ForgotPasswordBloc()),
  BlocProvider<SignOutBloc>(create: (context) => SignOutBloc()),
];
