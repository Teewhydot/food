import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food/food/core/bloc/utils/migration_helper.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/logger.dart';
import '../base/base_state.dart';

/// A simplified version of EnhancedBlocManager that maintains core functionality
/// without excessive configuration options
class BlocManager<T extends BlocBase<S>, S extends BaseState>
    extends StatelessWidget {
  /// The BLoC instance to manage
  final T bloc;

  /// Child widget to display
  final Widget child;

  /// Custom builder for the widget tree
  final Widget Function(BuildContext context, S state)? builder;

  /// Custom listener for state changes
  final void Function(BuildContext context, S state)? listener;

  /// Custom error handler
  final void Function(BuildContext context, S state)? onError;

  /// Custom success handler
  final void Function(BuildContext context, S state)? onSuccess;

  /// Whether to show loading overlay during loading states
  final bool showLoadingIndicator;

  /// Whether to show success or error messages
  final bool showResultErrorNotifications;
  final bool showResultSuccessNotifications;

  /// Custom loading widget
  final Widget? loadingWidget;

  /// Whether to enable pull-to-refresh
  final bool enablePullToRefresh;

  /// Pull-to-refresh callback
  final Future<void> Function()? onRefresh;

  const BlocManager({
    super.key,
    required this.bloc,
    required this.child,
    this.builder,
    this.listener,
    this.onError,
    this.onSuccess,
    this.showLoadingIndicator = true,
    this.showResultErrorNotifications = true,
    this.showResultSuccessNotifications = false,
    this.loadingWidget,
    this.enablePullToRefresh = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<T>.value(
      value: bloc,
      child: BlocConsumer<T, S>(
        buildWhen: (previous, current) {
          // Always rebuild for initial load, loading states, errors, and empty states
          if (previous is InitialState ||
              current is InitialState ||
              current is LoadingState ||
              current is ErrorState ||
              current is EmptyState) {
            return true;
          }

          // For loaded states, check if we should rebuild
          if (current is LoadedState && previous is LoadedState) {
            // Don't rebuild if returning cached data with same content
            if (current.isFromCache == true && previous.data == current.data) {
              return false;
            }
          }

          return true;
        },
        builder: (context, state) {
          // Handle custom builder if provided
          final Widget contentWidget =
              builder != null ? builder!(context, state) : child;

          // Apply loading overlay if needed
          if (showLoadingIndicator && state.isLoading) {
            return LoadingOverlay(
              isLoading: true,
              color: kPrimaryColor.withValues(alpha: 0.5),
              progressIndicator: SpinKitCircle(color: kWhiteColor, size: 50.0),
              child: contentWidget,
            );
          }

          // Handle pull-to-refresh
          if (enablePullToRefresh && onRefresh != null) {
            return RefreshIndicator(
              onRefresh: onRefresh!,
              child: contentWidget,
            );
          }

          return contentWidget;
        },
        listener: (context, state) {
          // Handle error states
          if (state.isError) {
            final String errorMessage =
                state.errorMessage ?? AppConstants.defaultErrorMessage;
            if (showResultErrorNotifications) {
              // Use Flutter's SnackBar instead of Get.snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: kErrorColor,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
            if (onError != null) {
              onError!(context, state);
            }
          }

          // Handle success states
          if (state.isSuccess) {
            Logger.logSuccess("Success condition met in BlocManager");
            if (onSuccess != null) {
              onSuccess!(context, state);
            }
            if (showResultSuccessNotifications) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.successMessage ?? AppConstants.defaultSuccessMessage,
                  ),
                  backgroundColor: kSuccessColor,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
          //Handle loaded state
          if (state.isLoadedState) {
            Logger.logSuccess("Success condition met in BlocManager");
            if (onSuccess != null) {
              onSuccess!(context, state);
            }
            if (showResultSuccessNotifications) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.successMessage ?? AppConstants.defaultSuccessMessage,
                  ),
                  backgroundColor: kSuccessColor,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }

          // Call custom listener if provided
          if (listener != null) {
            listener!(context, state);
          }
        },
      ),
    );
  }
}
