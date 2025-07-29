import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/bloc/managers/enhanced_bloc_manager.dart';

// Test Cubit for testing
class TestCubit extends Cubit<BaseState<String>> {
  TestCubit() : super(const InitialState<String>());

  void loadData() {
    emit(const LoadingState<String>(message: 'Loading test data...'));
    Future.delayed(const Duration(milliseconds: 100), () {
      emit(const LoadedState<String>(data: 'Test Data'));
    });
  }

  void loadError() {
    emit(const LoadingState<String>());
    Future.delayed(const Duration(milliseconds: 100), () {
      emit(const ErrorState<String>(errorMessage: 'Test error occurred', isRetryable: true));
    });
  }

  void loadEmpty() {
    emit(const LoadingState<String>());
    Future.delayed(const Duration(milliseconds: 100), () {
      emit(const EmptyState<String>(message: 'No data found'));
    });
  }

  void reset() {
    emit(const InitialState<String>());
  }
}

void main() {
  group('EnhancedBlocManager Tests', () {
    late TestCubit testCubit;

    setUp(() {
      testCubit = TestCubit();
    });

    tearDown(() {
      testCubit.close();
    });

    testWidgets('should display initial content correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: testCubit,
              child: EnhancedBlocManager<TestCubit, BaseState<String>>(
                bloc: testCubit,
                child: const Text('Content Widget'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Content Widget'), findsOneWidget);
    });

    testWidgets('should display loading indicator when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: testCubit,
              child: EnhancedBlocManager<TestCubit, BaseState<String>>(
                bloc: testCubit,
                showLoadingIndicator: true,
                child: const Text('Content Widget'),
              ),
            ),
          ),
        ),
      );

      // Trigger loading state
      testCubit.emit(const LoadingState<String>(message: 'Loading...'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should display custom loading widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: testCubit,
              child: EnhancedBlocManager<TestCubit, BaseState<String>>(
                bloc: testCubit,
                showLoadingIndicator: true,
                loadingWidget: const Text('Custom Loading Widget'),
                child: const Text('Content Widget'),
              ),
            ),
          ),
        ),
      );

      testCubit.emit(const LoadingState<String>());
      await tester.pump();

      expect(find.text('Custom Loading Widget'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should display error message when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: testCubit,
              child: EnhancedBlocManager<TestCubit, BaseState<String>>(
                bloc: testCubit,
                showErrorMessages: true,
                child: const Text('Content Widget'),
              ),
            ),
          ),
        ),
      );

      testCubit.emit(const ErrorState<String>(errorMessage: 'Test error message'));
      await tester.pump();

      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('should display custom error widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: testCubit,
              child: EnhancedBlocManager<TestCubit, BaseState<String>>(
                bloc: testCubit,
                errorWidgetBuilder: (context, error, retry) => 
                    Text('Custom Error: $error'),
                child: const Text('Content Widget'),
              ),
            ),
          ),
        ),
      );

      testCubit.emit(const ErrorState<String>(errorMessage: 'Custom error'));
      await tester.pump();

      expect(find.text('Custom Error: Custom error'), findsOneWidget);
    });

    testWidgets('should display retry button when enabled', (tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: testCubit,
              child: EnhancedBlocManager<TestCubit, BaseState<String>>(
                bloc: testCubit,
                showErrorMessages: true,
                enableRetry: true,
                onRetry: () {
                  retryPressed = true;
                },
                child: const Text('Content Widget'),
              ),
            ),
          ),
        ),
      );

      testCubit.emit(const ErrorState<String>(errorMessage: 'Retry test', isRetryable: true));
      await tester.pump();

      expect(find.text('Retry'), findsOneWidget);
      
      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryPressed, true);
    });

    testWidgets('should display success message when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: testCubit,
              child: EnhancedBlocManager<TestCubit, BaseState<String>>(
                bloc: testCubit,
                showSuccessMessages: true,
                child: const Text('Content Widget'),
              ),
            ),
          ),
        ),
      );

      testCubit.emit(const SuccessState<String>(successMessage: 'Success!'));
      await tester.pump();

      expect(find.text('Success!'), findsOneWidget);
    });

    testWidgets('should call onSuccess callback', (tester) async {
      BaseState<String>? capturedState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: testCubit,
              child: EnhancedBlocManager<TestCubit, BaseState<String>>(
                bloc: testCubit,
                onSuccess: (context, state) {
                  capturedState = state;
                },
                child: const Text('Content Widget'),
              ),
            ),
          ),
        ),
      );

      const successState = LoadedState<String>(data: 'Success Data');
      testCubit.emit(successState);
      await tester.pump();

      expect(capturedState, equals(successState));
    });

    testWidgets('should call onError callback', (tester) async {
      BaseState<String>? capturedState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: testCubit,
              child: EnhancedBlocManager<TestCubit, BaseState<String>>(
                bloc: testCubit,
                onError: (context, state) {
                  capturedState = state;
                },
                child: const Text('Content Widget'),
              ),
            ),
          ),
        ),
      );

      const errorState = ErrorState<String>(errorMessage: 'Error occurred');
      testCubit.emit(errorState);
      await tester.pump();

      expect(capturedState, equals(errorState));
    });

    testWidgets('should handle pull to refresh when enabled', (tester) async {
      bool refreshCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: testCubit,
              child: EnhancedBlocManager<TestCubit, BaseState<String>>(
                bloc: testCubit,
                enablePullToRefresh: true,
                onRefresh: () async {
                  refreshCalled = true;
                },
                child: const SizedBox(height: 200, child: Text('Content')),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Simulate pull to refresh
      await tester.fling(find.text('Content'), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(refreshCalled, true);
    });

    testWidgets('should enable logging when configured', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: testCubit,
              child: EnhancedBlocManager<TestCubit, BaseState<String>>(
                bloc: testCubit,
                enableLogging: true,
                child: const Text('Content Widget'),
              ),
            ),
          ),
        ),
      );

      // Change state to trigger logging
      testCubit.emit(const LoadingState<String>());
      await tester.pump();

      testCubit.emit(const LoadedState<String>(data: 'Data'));
      await tester.pump();

      // Logging should happen in the background (no visual test possible)
      expect(find.text('Content Widget'), findsOneWidget);
    });

    group('DataBlocBuilder Tests', () {
      testWidgets('should display data when available', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: testCubit,
                child: DataBlocBuilder<TestCubit, BaseState<String>, String>(
                  bloc: testCubit,
                  dataExtractor: (state) => state.data,
                  builder: (context, data) => Text('Data: $data'),
                ),
              ),
            ),
          ),
        );

        testCubit.emit(const LoadedState<String>(data: 'Test Data'));
        await tester.pump();

        expect(find.text('Data: Test Data'), findsOneWidget);
      });

      testWidgets('should display loading when data is loading', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: testCubit,
                child: DataBlocBuilder<TestCubit, BaseState<String>, String>(
                  bloc: testCubit,
                  dataExtractor: (state) => state.data,
                  builder: (context, data) => Text('Data: $data'),
                  loadingBuilder: (context) => const Text('Custom Loading'),
                ),
              ),
            ),
          ),
        );

        testCubit.emit(const LoadingState<String>());
        await tester.pump();

        expect(find.text('Custom Loading'), findsOneWidget);
      });

      testWidgets('should display error when error occurs', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: testCubit,
                child: DataBlocBuilder<TestCubit, BaseState<String>, String>(
                  bloc: testCubit,
                  dataExtractor: (state) => state.data,
                  builder: (context, data) => Text('Data: $data'),
                  errorBuilder: (context, error) => Text('Error: $error'),
                ),
              ),
            ),
          ),
        );

        testCubit.emit(const ErrorState<String>(errorMessage: 'Test Error'));
        await tester.pump();

        expect(find.text('Error: Test Error'), findsOneWidget);
      });

      testWidgets('should display empty when no data', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: testCubit,
                child: DataBlocBuilder<TestCubit, BaseState<String>, String>(
                  bloc: testCubit,
                  dataExtractor: (state) => state.data,
                  builder: (context, data) => Text('Data: $data'),
                  emptyBuilder: (context) => const Text('No Data Available'),
                ),
              ),
            ),
          ),
        );

        testCubit.emit(const EmptyState<String>());
        await tester.pump();

        expect(find.text('No Data Available'), findsOneWidget);
      });
    });

    group('Integration Tests', () {
      testWidgets('should handle complete state flow', (tester) async {
        final states = <String>[];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: testCubit,
                child: EnhancedBlocManager<TestCubit, BaseState<String>>(
                  bloc: testCubit,
                  showLoadingIndicator: true,
                  showErrorMessages: true,
                  showSuccessMessages: true,
                  enableRetry: true,
                  onRetry: () => testCubit.loadData(),
                  child: BlocBuilder<TestCubit, BaseState<String>>(
                    builder: (context, state) {
                      final stateType = state.runtimeType.toString();
                      if (!states.contains(stateType)) {
                        states.add(stateType);
                      }
                      return Text('Current: $stateType');
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        // Initial state
        expect(find.textContaining('InitialState'), findsOneWidget);

        // Loading state
        testCubit.loadData();
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Loaded state
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.textContaining('LoadedState'), findsOneWidget);

        // Error state
        testCubit.loadError();
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 150));
        expect(find.textContaining('ErrorState'), findsOneWidget);
        expect(find.text('Test error occurred'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);

        // Retry
        await tester.tap(find.text('Retry'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        expect(find.textContaining('LoadedState'), findsOneWidget);

        // Verify state flow
        expect(states, contains('InitialState'));
        expect(states, contains('LoadingState'));
        expect(states, contains('LoadedState'));
        expect(states, contains('ErrorState'));
      });
    });
  });
}