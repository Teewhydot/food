import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/logger.dart';
import '../base/base_state.dart';

/// Enhanced BloC Manager with automatic state detection and advanced features
class EnhancedBlocManager<T extends BlocBase<S>, S extends BaseState>
    extends StatelessWidget {
  /// The BLoC instance to manage
  final T bloc;

  /// Custom builder for the widget tree
  final Widget Function(BuildContext context, S state)? builder;

  /// Custom listener for state changes
  final void Function(BuildContext context, S state)? listener;

  /// Child widget to display
  final Widget child;

  /// Custom error handler
  final void Function(BuildContext context, S state)? onError;

  /// Custom success handler
  final void Function(BuildContext context, S state)? onSuccess;

  /// Custom loading handler
  final void Function(BuildContext context, S state)? onLoading;

  /// Whether to show loading indicators automatically
  final bool showLoadingIndicator;

  /// Whether to show error messages automatically
  final bool showErrorMessages;

  /// Whether to show success messages automatically
  final bool showSuccessMessages;

  /// Custom error color
  final Color errorColor;

  /// Custom success color
  final Color successColor;

  /// Loading widget to display during loading states
  final Widget? loadingWidget;

  /// Error widget builder
  final Widget Function(
    BuildContext context,
    String error,
    VoidCallback? retry,
  )?
  errorWidgetBuilder;

  /// Whether to enable retry functionality for errors
  final bool enableRetry;

  /// Retry callback
  final VoidCallback? onRetry;

  /// Whether to enable pull-to-refresh
  final bool enablePullToRefresh;

  /// Pull-to-refresh callback
  final Future<void> Function()? onRefresh;

  /// Whether to log state changes
  final bool enableLogging;

  /// Whether to enable automatic error recovery
  final bool enableErrorRecovery;

  /// Error recovery delay
  final Duration errorRecoveryDelay;

  const EnhancedBlocManager({
    super.key,
    required this.bloc,
    required this.child,
    this.builder,
    this.listener,
    this.onError,
    this.onSuccess,
    this.onLoading,
    this.showLoadingIndicator = true,
    this.showErrorMessages = true,
    this.showSuccessMessages = true,
    this.errorColor = kErrorColor,
    this.successColor = Colors.green,
    this.loadingWidget,
    this.errorWidgetBuilder,
    this.enableRetry = true,
    this.onRetry,
    this.enablePullToRefresh = false,
    this.onRefresh,
    this.enableLogging = true,
    this.enableErrorRecovery = false,
    this.errorRecoveryDelay = const Duration(seconds: 3),
  });

  @override
  Widget build(BuildContext context) {
    Widget content = BlocProvider<T>.value(
      value: bloc,
      child: BlocConsumer<T, S>(
        builder: _buildContent,
        listener: _handleStateChange,
      ),
    );

    // Wrap with pull-to-refresh if enabled
    if (enablePullToRefresh && onRefresh != null) {
      content = RefreshIndicator(onRefresh: onRefresh!, child: content);
    }

    return content;
  }

  Widget _buildContent(BuildContext context, S state) {
    // Log state if enabled
    if (enableLogging) {
      Logger.logBasic('${bloc.runtimeType}: $state');
    }

    // Handle loading state
    if (state.isLoading && showLoadingIndicator) {
      return _buildLoadingWidget(context, state);
    }

    // Handle error state
    if (state.isError && errorWidgetBuilder != null) {
      return errorWidgetBuilder!(
        context,
        state.errorMessage ?? 'Unknown error',
        enableRetry && state is ErrorState && state.isRetryable
            ? onRetry
            : null,
      );
    }

    // Use custom builder or return child
    if (builder != null) {
      return builder!(context, state);
    }

    return child;
  }

  Widget _buildLoadingWidget(BuildContext context, S state) {
    if (loadingWidget != null) {
      return loadingWidget!;
    }

    // Default loading widget
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingOverlay(
            isLoading: true,
            color: kPrimaryColor.withOpacity(0.5),
            progressIndicator: SpinKitFadingCircle(color: kWhiteColor),
            child: child,
          ),
        ],
      ),
    );
  }

  void _handleStateChange(BuildContext context, S state) {
    // Handle error states
    if (state.isError) {
      _handleErrorState(context, state);
    }

    // Handle success states (SuccessState, LoadedState, EmptyState)
    if (state.isSuccess || state is LoadedState || state is EmptyState) {
      _handleSuccessState(context, state);
    }

    // Handle loading states
    if (state.isLoading) {
      _handleLoadingState(context, state);
    }

    // Call custom listener
    listener?.call(context, state);
  }

  void _handleErrorState(BuildContext context, S state) {
    final errorMessage = state.errorMessage ?? AppConstants.defaultErrorMessage;

    if (enableLogging) {
      Logger.logError('${bloc.runtimeType} Error: $errorMessage');
    }

    // Show error message if enabled
    if (showErrorMessages) {
      DFoodUtils.showSnackBar(errorMessage, errorColor);
    }

    // Call custom error handler
    onError?.call(context, state);

    // Handle automatic error recovery
    if (enableErrorRecovery && state is ErrorState && state.isRetryable) {
      _scheduleErrorRecovery();
    }
  }

  void _handleSuccessState(BuildContext context, S state) {
    final successMessage =
        state.successMessage ?? 'Operation completed successfully';

    if (enableLogging) {
      Logger.logSuccess('${bloc.runtimeType} Success: $successMessage');
    }

    // Show success message if enabled
    if (showSuccessMessages) {
      DFoodUtils.showSnackBar(successMessage, successColor);
    }

    // Call custom success handler
    onSuccess?.call(context, state);
  }

  void _handleLoadingState(BuildContext context, S state) {
    if (enableLogging) {
      final loadingMessage =
          state is LoadingState ? state.message ?? 'Loading...' : 'Loading...';
      Logger.logBasic('${bloc.runtimeType} Loading: $loadingMessage');
    }

    // Call custom loading handler
    onLoading?.call(context, state);
  }

  void _scheduleErrorRecovery() {
    Future.delayed(errorRecoveryDelay, () {
      onRetry?.call();
    });
  }
}

/// Convenient wrapper for data-driven widgets
class DataBlocBuilder<T extends BlocBase<S>, S extends BaseState, D>
    extends StatelessWidget {
  final T bloc;
  final Widget Function(BuildContext context, D data) builder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final D? Function(S state) dataExtractor;

  const DataBlocBuilder({
    super.key,
    required this.bloc,
    required this.builder,
    required this.dataExtractor,
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<T, S>(
      bloc: bloc,
      builder: (context, state) {
        // Handle loading
        if (state.isLoading) {
          return loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        }

        // Handle error
        if (state.isError) {
          return errorBuilder?.call(context, state.errorMessage ?? 'Error') ??
              Center(child: Text('Error: ${state.errorMessage}'));
        }

        // Extract data
        final data = dataExtractor(state);

        // Handle empty data
        if (data == null) {
          return emptyBuilder?.call(context) ??
              const Center(child: Text('No data available'));
        }

        // Build with data
        return builder(context, data);
      },
    );
  }
}

/// Convenient wrapper for list-driven widgets with pagination support
class ListBlocBuilder<T extends BlocBase<S>, S extends BaseState, I>
    extends StatelessWidget {
  final T bloc;
  final Widget Function(BuildContext context, List<I> items)? builder;
  final Widget Function(BuildContext context, int index, I item)? itemBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final List<I>? Function(S state) itemsExtractor;
  final Future<void> Function()? onLoadMore;
  final bool enableLoadMore;

  const ListBlocBuilder({
    super.key,
    required this.bloc,
    required this.itemsExtractor,
    this.builder,
    this.itemBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.onLoadMore,
    this.enableLoadMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<T, S>(
      bloc: bloc,
      builder: (context, state) {
        // Handle loading (only for initial load)
        if (state.isLoading && !state.hasData) {
          return loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        }

        // Handle error (only if no data exists)
        if (state.isError && !state.hasData) {
          return errorBuilder?.call(context, state.errorMessage ?? 'Error') ??
              Center(child: Text('Error: ${state.errorMessage}'));
        }

        // Extract items
        final items = itemsExtractor(state) ?? <I>[];

        // Handle empty list
        if (items.isEmpty) {
          return emptyBuilder?.call(context) ??
              const Center(child: Text('No items available'));
        }

        // Use custom builder if provided
        if (builder != null) {
          return builder!(context, items);
        }

        // Build list with item builder
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            // Handle load more
            if (enableLoadMore &&
                index == items.length - 1 &&
                onLoadMore != null) {
              Future.microtask(() => onLoadMore!());
            }

            return itemBuilder!(context, index, items[index]);
          },
        );
      },
    );
  }
}
