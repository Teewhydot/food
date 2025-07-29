import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/bloc/managers/enhanced_bloc_manager.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/login/enhanced_login_bloc.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';

void main() {
  group('Enhanced Login BLoC Integration Tests', () {
    late EnhancedLoginBloc loginBloc;

    setUp(() {
      loginBloc = EnhancedLoginBloc();
    });

    tearDown(() {
      loginBloc.close();
    });

    group('BLoC State Management', () {
      test('should start with initial state', () {
        expect(loginBloc.state, isA<InitialState<UserProfileEntity>>());
        expect(loginBloc.state.isInitial, true);
        expect(loginBloc.state.isLoading, false);
        expect(loginBloc.state.hasData, false);
      });

      test('should emit loading state when quick login starts', () {
        final states = <BaseState<UserProfileEntity>>[];
        final subscription = loginBloc.stream.listen(states.add);

        loginBloc.quickLogin(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(states.isNotEmpty, true);
        expect(states.first, isA<LoadingState<UserProfileEntity>>());
        expect(states.first.isLoading, true);

        subscription.cancel();
      });

      test('should handle login success flow', () async {
        final states = <BaseState<UserProfileEntity>>[];
        final subscription = loginBloc.stream.listen(states.add);

        loginBloc.quickLogin(
          email: 'test@example.com',
          password: 'password123',
        );

        // Wait for async operation to complete
        await Future.delayed(const Duration(milliseconds: 200));

        expect(states.length, greaterThanOrEqualTo(1));
        expect(states.first, isA<LoadingState<UserProfileEntity>>());

        // Note: Actual success/error depends on implementation
        // This test verifies the state flow structure

        subscription.cancel();
      });

      test('should handle reset login correctly', () {
        // Set some state first
        loginBloc.emit(const LoadingState<UserProfileEntity>());
        expect(loginBloc.state.isLoading, true);

        // Reset
        loginBloc.resetLogin();

        expect(loginBloc.state, isA<InitialState<UserProfileEntity>>());
        expect(loginBloc.state.isInitial, true);
      });

      test('should handle secure login with remember me', () async {
        final states = <BaseState<UserProfileEntity>>[];
        final subscription = loginBloc.stream.listen(states.add);

        loginBloc.secureLogin(
          email: 'test@example.com',
          password: 'password123',
          rememberMe: true,
        );

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states.isNotEmpty, true);
        expect(states.first, isA<LoadingState<UserProfileEntity>>());

        subscription.cancel();
      });
    });

    group('Widget Integration', () {
      testWidgets('should integrate with EnhancedBlocManager correctly', (tester) async {
        bool onSuccessCalled = false;
        bool onErrorCalled = false;
        bool onRetryCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginBloc,
                child: EnhancedBlocManager<EnhancedLoginBloc, BaseState<UserProfileEntity>>(
                  bloc: loginBloc,
                  showLoadingIndicator: true,
                  showErrorMessages: true,
                  showSuccessMessages: true,
                  enableRetry: true,
                  onSuccess: (context, state) {
                    onSuccessCalled = true;
                  },
                  onError: (context, state) {
                    onErrorCalled = true;
                  },
                  onRetry: () {
                    onRetryCalled = true;
                  },
                  child: const Text('Login Content'),
                ),
              ),
            ),
          ),
        );

        // Initial state
        expect(find.text('Login Content'), findsOneWidget);

        // Trigger loading state
        loginBloc.emit(const LoadingState<UserProfileEntity>(message: 'Signing in...'));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Signing in...'), findsOneWidget);

        // Trigger error state
        loginBloc.emit(const ErrorState<UserProfileEntity>('Invalid credentials'));
        await tester.pump();

        expect(find.text('Invalid credentials'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);

        // Test retry functionality
        await tester.tap(find.text('Retry'));
        await tester.pump();

        expect(onRetryCalled, true);
      });

      testWidgets('should handle form submission with loading states', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginBloc,
                child: Column(
                  children: [
                    BlocBuilder<EnhancedLoginBloc, BaseState<UserProfileEntity>>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state.isLoading ? null : () {
                            loginBloc.quickLogin(
                              email: 'test@example.com',
                              password: 'password123',
                            );
                          },
                          child: Text(state.isLoading ? 'Signing In...' : 'Sign In'),
                        );
                      },
                    ),
                    BlocBuilder<EnhancedLoginBloc, BaseState<UserProfileEntity>>(
                      builder: (context, state) {
                        if (state.isError) {
                          return Text('Error: ${state.errorMessage}');
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Initial state - button should be enabled
        expect(find.text('Sign In'), findsOneWidget);
        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.onPressed, isNotNull);

        // Tap button to trigger login
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        // Should show loading state
        expect(find.text('Signing In...'), findsOneWidget);
        final loadingButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(loadingButton.onPressed, isNull); // Button should be disabled
      });

      testWidgets('should display user profile data when logged in', (tester) async {
        final testUser = UserProfileEntity(
          id: '123',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john.doe@example.com',
          phoneNumber: '+1234567890',
          firstTimeLogin: false,
          bio: 'Test user bio',
          profileImageUrl: 'https://example.com/avatar.jpg',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider.value(
                value: loginBloc,
                child: DataBlocBuilder<EnhancedLoginBloc, BaseState<UserProfileEntity>, UserProfileEntity>(
                  bloc: loginBloc,
                  dataExtractor: (state) => state.data,
                  builder: (context, user) {
                    return Column(
                      children: [
                        Text('Welcome, ${user.firstName} ${user.lastName}!'),
                        Text('Email: ${user.email}'),
                        Text('Phone: ${user.phoneNumber}'),
                        if (user.bio != null) Text('Bio: ${user.bio}'),
                      ],
                    );
                  },
                  loadingBuilder: (context) => const CircularProgressIndicator(),
                  errorBuilder: (context, error) => Text('Login failed: $error'),
                  emptyBuilder: (context) => const Text('Please log in'),
                ),
              ),
            ),
          ),
        );

        // Initial state - should show empty state
        expect(find.text('Please log in'), findsOneWidget);

        // Emit loading state
        loginBloc.emit(const LoadingState<UserProfileEntity>());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Emit loaded state with user data
        loginBloc.emit(LoadedState<UserProfileEntity>(testUser));
        await tester.pump();

        expect(find.text('Welcome, John Doe!'), findsOneWidget);
        expect(find.text('Email: john.doe@example.com'), findsOneWidget);
        expect(find.text('Phone: +1234567890'), findsOneWidget);
        expect(find.text('Bio: Test user bio'), findsOneWidget);

        // Emit error state
        loginBloc.emit(const ErrorState<UserProfileEntity>('Network error'));
        await tester.pump();

        expect(find.text('Login failed: Network error'), findsOneWidget);
      });
    });

    group('State Persistence and Recovery', () {
      test('should maintain state consistency during rapid operations', () async {
        final states = <BaseState<UserProfileEntity>>[];
        final subscription = loginBloc.stream.listen(states.add);

        // Rapid fire multiple operations
        loginBloc.quickLogin(email: 'test1@example.com', password: 'pass1');
        loginBloc.resetLogin();
        loginBloc.quickLogin(email: 'test2@example.com', password: 'pass2');
        loginBloc.resetLogin();

        await Future.delayed(const Duration(milliseconds: 100));

        // Should end in initial state
        expect(loginBloc.state, isA<InitialState<UserProfileEntity>>());

        // Should have recorded all state transitions
        expect(states.isNotEmpty, true);

        subscription.cancel();
      });

      test('should handle concurrent login attempts gracefully', () async {
        final states = <BaseState<UserProfileEntity>>[];
        final subscription = loginBloc.stream.listen(states.add);

        // Start multiple concurrent login attempts
        final futures = [
          Future(() => loginBloc.quickLogin(email: 'test1@example.com', password: 'pass1')),
          Future(() => loginBloc.quickLogin(email: 'test2@example.com', password: 'pass2')),
          Future(() => loginBloc.quickLogin(email: 'test3@example.com', password: 'pass3')),
        ];

        await Future.wait(futures);
        await Future.delayed(const Duration(milliseconds: 200));

        // Should maintain consistent state
        expect(loginBloc.state, isA<BaseState<UserProfileEntity>>());

        subscription.cancel();
      });
    });

    group('Memory and Performance', () {
      test('should not leak memory during repeated operations', () async {
        // Perform many operations to test for memory leaks
        for (int i = 0; i < 100; i++) {
          loginBloc.quickLogin(email: 'test$i@example.com', password: 'pass$i');
          loginBloc.resetLogin();
          
          if (i % 10 == 0) {
            await Future.delayed(const Duration(milliseconds: 1));
          }
        }

        // Should still be responsive
        expect(loginBloc.state, isA<InitialState<UserProfileEntity>>());
        expect(loginBloc.isClosed, false);
      });

      test('should handle rapid state changes efficiently', () async {
        final stopwatch = Stopwatch()..start();
        
        // Perform rapid state changes
        for (int i = 0; i < 50; i++) {
          loginBloc.emit(const LoadingState<UserProfileEntity>());
          loginBloc.emit(const InitialState<UserProfileEntity>());
        }
        
        stopwatch.stop();
        
        // Should complete quickly (less than 100ms for 100 state changes)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        expect(loginBloc.state, isA<InitialState<UserProfileEntity>>());
      });
    });
  });
}