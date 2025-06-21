import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/core/utils/logger.dart';

import '../utils/app_utils.dart';

class BlocManager<T extends BlocBase<S>, S> extends StatelessWidget {
  final T bloc;
  final Widget Function(BuildContext context, S state)? builder;
  final void Function(BuildContext context, S state)? listener;
  final bool Function(S state)? isError;
  final String Function(S state)? getErrorMessage;
  final Color errorColor;
  final bool Function(S state)? isSuccess;
  final void Function(BuildContext context, S state)? onSuccess;
  final Widget child;

  const BlocManager({
    super.key,
    required this.bloc,
    required this.child,
    this.builder,
    this.listener,
    this.isError,
    this.getErrorMessage,
    this.errorColor = kErrorColor,
    this.isSuccess,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<T>.value(
      value: bloc,
      child: BlocConsumer<T, S>(
        builder: builder ?? (context, state) => child,
        listener: (context, state) {
          if (isError != null && isError!(state)) {
            final message =
                getErrorMessage != null
                    ? getErrorMessage!(state)
                    : AppConstants.defaultErrorMessage;
            DFoodUtils.showSnackBar(message, errorColor);
          }
          if (isSuccess != null && isSuccess!(state)) {
            Logger.logSuccess("Success condition met in BlocManager");
            if (onSuccess != null) {
              Logger.logSuccess("Executing onSuccess callback");
              onSuccess!(context, state);
            }
          }
          if (listener != null) {
            listener!(context, state);
          }
        },
      ),
    );
  }
}
