import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/auth_bloc.dart';

final List<BlocProvider> blocs = [
 BlocProvider(create: (context) => AuthBloc()),
];
