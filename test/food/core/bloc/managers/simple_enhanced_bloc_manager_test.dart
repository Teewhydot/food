import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/bloc/managers/enhanced_bloc_manager.dart';

// Simple test cubit for basic testing
class SimpleCubit extends Cubit<BaseState<String>> {
  SimpleCubit() : super(const InitialState<String>());

  void emitLoading() => emit(const LoadingState<String>(message: 'Loading...'));
  void emitLoaded(String data) => emit(LoadedState<String>(data: data));
  void emitError(String message) => emit(ErrorState<String>(errorMessage: message));
  void emitEmpty() => emit(const EmptyState<String>());
  void reset() => emit(const InitialState<String>());
}

void main() {
  group('Simple EnhancedBlocManager Tests', () {
    late SimpleCubit cubit;

    setUp(() {
      cubit = SimpleCubit();
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('should display loading indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: EnhancedBlocManager<SimpleCubit, BaseState<String>>(
                bloc: cubit,
                showLoadingIndicator: true,
                showErrorMessages: false, // Disable to avoid GetX dependency
                showSuccessMessages: false,
                child: const Text('Content'),
              ),
            ),
          ),
        ),
      );

      // Should show content initially
      expect(find.text('Content'), findsOneWidget);

      // Emit loading state
      cubit.emitLoading();
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should handle state transitions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: EnhancedBlocManager<SimpleCubit, BaseState<String>>(
                bloc: cubit,
                showLoadingIndicator: true,
                showErrorMessages: false,
                showSuccessMessages: false,
                child: BlocBuilder<SimpleCubit, BaseState<String>>(
                  builder: (context, state) {
                    return Text('State: ${state.runtimeType}');
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Initial state
      expect(find.text('State: InitialState'), findsOneWidget);

      // Loading state
      cubit.emitLoading();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Loaded state
      cubit.emitLoaded('Test Data');
      await tester.pump();
      expect(find.text('State: LoadedState'), findsOneWidget);

      // Error state
      cubit.emitError('Test Error');
      await tester.pump();
      expect(find.text('State: ErrorState'), findsOneWidget);

      // Empty state
      cubit.emitEmpty();
      await tester.pump();
      expect(find.text('State: EmptyState'), findsOneWidget);
    });

    testWidgets('should call callbacks correctly', (tester) async {
      BaseState<String>? onSuccessState;
      BaseState<String>? onErrorState;
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: EnhancedBlocManager<SimpleCubit, BaseState<String>>(
                bloc: cubit,
                showErrorMessages: false,
                showSuccessMessages: false,
                enableRetry: true,
                onSuccess: (context, state) {
                  onSuccessState = state;
                },
                onError: (context, state) {
                  onErrorState = state;
                },
                onRetry: () {
                  retryPressed = true;
                },
                child: const Text('Content'),
              ),
            ),
          ),
        ),
      );

      // Test success callback with LoadedState
      cubit.emitLoaded('Success Data');
      await tester.pump();
      expect(onSuccessState, isA<LoadedState<String>>());
      expect(onSuccessState?.data, 'Success Data');

      // Test error callback
      cubit.emitError('Error Message');
      await tester.pump();
      expect(onErrorState, isA<ErrorState<String>>());
      expect(onErrorState?.errorMessage, 'Error Message');

      // Reset callbacks
      onSuccessState = null;
      onErrorState = null;

      // Test with EmptyState (should also trigger success callback)
      cubit.emitEmpty();
      await tester.pump();
      expect(onSuccessState, isA<EmptyState<String>>());
    });

    testWidgets('should use custom builders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: EnhancedBlocManager<SimpleCubit, BaseState<String>>(
                bloc: cubit,
                showErrorMessages: false,
                loadingWidget: const Text('Custom Loading'),
                errorWidgetBuilder: (context, error, retry) => 
                    Text('Custom Error: $error'),
                child: const Text('Content'),
              ),
            ),
          ),
        ),
      );

      // Test custom loading widget
      cubit.emitLoading();
      await tester.pump();
      expect(find.text('Custom Loading'), findsOneWidget);

      // Test custom error widget
      cubit.emitError('Test Error');
      await tester.pump();
      expect(find.text('Custom Error: Test Error'), findsOneWidget);
    });

    group('DataBlocBuilder Tests', () {
      testWidgets('should extract and display data correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: cubit,
                child: DataBlocBuilder<SimpleCubit, BaseState<String>, String>(
                  bloc: cubit,
                  dataExtractor: (state) => state.data,
                  builder: (context, data) => Text('Data: $data'),
                  loadingBuilder: (context) => const Text('Loading...'),
                  errorBuilder: (context, error) => Text('Error: $error'),
                  emptyBuilder: (context) => const Text('No Data'),
                ),
              ),
            ),
          ),
        );

        // Initial state - should show empty
        expect(find.text('No Data'), findsOneWidget);

        // Loading state
        cubit.emitLoading();
        await tester.pump();
        expect(find.text('Loading...'), findsOneWidget);

        // Loaded state
        cubit.emitLoaded('Test Data');
        await tester.pump();
        expect(find.text('Data: Test Data'), findsOneWidget);

        // Error state
        cubit.emitError('Test Error');
        await tester.pump();
        expect(find.text('Error: Test Error'), findsOneWidget);

        // Empty state
        cubit.emitEmpty();
        await tester.pump();
        expect(find.text('No Data'), findsOneWidget);
      });

      testWidgets('should handle data transformation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: cubit,
                child: DataBlocBuilder<SimpleCubit, BaseState<String>, int>(
                  bloc: cubit,
                  dataExtractor: (state) => state.data?.length,
                  builder: (context, length) => Text('Length: $length'),
                  emptyBuilder: (context) => const Text('No Length'),
                ),
              ),
            ),
          ),
        );

        // No data initially
        expect(find.text('No Length'), findsOneWidget);

        // Load data and transform to length
        cubit.emitLoaded('Hello');
        await tester.pump();
        expect(find.text('Length: 5'), findsOneWidget);

        // Different data
        cubit.emitLoaded('Test');
        await tester.pump();
        expect(find.text('Length: 4'), findsOneWidget);
      });
    });
  });
}