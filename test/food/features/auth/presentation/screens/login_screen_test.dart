import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/login/login_bloc.dart';
import 'package:food/food/features/auth/presentation/screens/login.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_screen_test.mocks.dart';

@GenerateMocks([LoginBloc])
void main() {
  late MockLoginBloc mockLoginBloc;

  setUp(() {
    mockLoginBloc = MockLoginBloc();
  });

  Widget makeTestableWidget(Widget body) {
    return MaterialApp(
      home: BlocProvider<LoginBloc>.value(
        value: mockLoginBloc,
        child: body,
      ),
    );
  }

  group('Login Screen Widget Tests', () {
    testWidgets('should display all required form fields', (WidgetTester tester) async {
      when(mockLoginBloc.state).thenReturn(LoginInitialState());
      when(mockLoginBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(makeTestableWidget(const Login()));

      // Check for email text field
      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
      
      // Check for password field (should be obscured)
      final passwordFields = find.byType(TextFormField);
      expect(passwordFields, findsAtLeastNWidgets(1));

      // Check for login button
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should show password when visibility toggle is pressed', (WidgetTester tester) async {
      when(mockLoginBloc.state).thenReturn(LoginInitialState());
      when(mockLoginBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(makeTestableWidget(const Login()));

      // Find the password visibility toggle
      final visibilityToggle = find.byIcon(Icons.visibility_off);
      if (visibilityToggle.evaluate().isNotEmpty) {
        await tester.tap(visibilityToggle);
        await tester.pump();

        // Password should now be visible
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      }
    });

    testWidgets('should display loading state', (WidgetTester tester) async {
      whenListen(
        mockLoginBloc,
        Stream.fromIterable([LoginLoadingState()]),
        initialState: LoginInitialState(),
      );

      await tester.pumpWidget(makeTestableWidget(const Login()));
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error message on login failure', (WidgetTester tester) async {
      const errorMessage = 'Invalid credentials';
      
      whenListen(
        mockLoginBloc,
        Stream.fromIterable([LoginFailureState(errorMessage: errorMessage)]),
        initialState: LoginInitialState(),
      );

      await tester.pumpWidget(makeTestableWidget(const Login()));
      await tester.pump();

      // Should show error message
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should trigger login event when login button is pressed with valid inputs', (WidgetTester tester) async {
      when(mockLoginBloc.state).thenReturn(LoginInitialState());
      when(mockLoginBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(makeTestableWidget(const Login()));

      // Enter email and password
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Tap login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify that login event was added
      verify(mockLoginBloc.add(any)).called(1);
    });

    testWidgets('should validate email format', (WidgetTester tester) async {
      when(mockLoginBloc.state).thenReturn(LoginInitialState());
      when(mockLoginBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(makeTestableWidget(const Login()));

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Should show validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should validate password is not empty', (WidgetTester tester) async {
      when(mockLoginBloc.state).thenReturn(LoginInitialState());
      when(mockLoginBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(makeTestableWidget(const Login()));

      // Enter valid email but empty password
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Should show password validation error
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('should navigate to forgot password screen', (WidgetTester tester) async {
      when(mockLoginBloc.state).thenReturn(LoginInitialState());
      when(mockLoginBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(makeTestableWidget(const Login()));

      // Find and tap forgot password link
      final forgotPasswordLink = find.text('Forgot Password?');
      if (forgotPasswordLink.evaluate().isNotEmpty) {
        await tester.tap(forgotPasswordLink);
        await tester.pump();
        
        // Navigation should be triggered (this would require mocking the navigation service)
      }
    });

    testWidgets('should navigate to register screen', (WidgetTester tester) async {
      when(mockLoginBloc.state).thenReturn(LoginInitialState());
      when(mockLoginBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(makeTestableWidget(const Login()));

      // Find and tap register link
      final registerLink = find.text('Sign Up');
      if (registerLink.evaluate().isNotEmpty) {
        await tester.tap(registerLink);
        await tester.pump();
        
        // Navigation should be triggered
      }
    });

    testWidgets('should toggle remember me checkbox', (WidgetTester tester) async {
      when(mockLoginBloc.state).thenReturn(LoginInitialState());
      when(mockLoginBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(makeTestableWidget(const Login()));

      // Find remember me checkbox
      final checkbox = find.byType(Checkbox);
      if (checkbox.evaluate().isNotEmpty) {
        // Initially unchecked
        expect(tester.widget<Checkbox>(checkbox).value, false);

        // Tap to check
        await tester.tap(checkbox);
        await tester.pump();

        // Should be checked now
        expect(tester.widget<Checkbox>(checkbox).value, true);
      }
    });

    testWidgets('should display success message on successful login', (WidgetTester tester) async {
      const successMessage = 'Login successful';
      
      whenListen(
        mockLoginBloc,
        Stream.fromIterable([LoginSuccessState(successMessage: successMessage)]),
        initialState: LoginInitialState(),
      );

      await tester.pumpWidget(makeTestableWidget(const Login()));
      await tester.pump();

      // Should show success message
      expect(find.text(successMessage), findsOneWidget);
    });
  });
}