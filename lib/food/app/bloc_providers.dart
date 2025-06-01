import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/login/login_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/otp_verification/verification_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/register/register_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/location_bloc/location_bloc.dart';

import '../features/auth/presentation/manager/auth_bloc/forgot_password/forgot_password_bloc.dart';

final List<BlocProvider> blocs = [
  BlocProvider<LoginBloc>(create: (context) => LoginBloc()),
  BlocProvider<ForgotPasswordBloc>(create: (context) => ForgotPasswordBloc()),
  BlocProvider<RegisterBloc>(create: (context) => RegisterBloc()),
  BlocProvider<VerificationBloc>(create: (context) => VerificationBloc()),
  BlocProvider<LocationBloc>(create: (context) => LocationBloc()),
];
