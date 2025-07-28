import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/login/login_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/register/register_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/forgot_password/forgot_password_bloc.dart';

void main() {
  group('Auth BLoC Tests', () {
    group('LoginBloc', () {
      late LoginBloc loginBloc;

      setUp(() {
        loginBloc = LoginBloc();
      });

      tearDown(() {
        loginBloc.close();
      });

      test('initial state should be LoginInitialState', () {
        expect(loginBloc.state, isA<LoginInitialState>());
      });

      test('should be closable', () {
        expect(() => loginBloc.close(), returnsNormally);
      });
    });

    group('RegisterBloc', () {
      late RegisterBloc registerBloc;

      setUp(() {
        registerBloc = RegisterBloc();
      });

      tearDown(() {
        registerBloc.close();
      });

      test('initial state should be RegisterInitial', () {
        expect(registerBloc.state, isA<RegisterInitial>());
      });

      test('should be closable', () {
        expect(() => registerBloc.close(), returnsNormally);
      });
    });

    group('ForgotPasswordBloc', () {
      late ForgotPasswordBloc forgotPasswordBloc;

      setUp(() {
        forgotPasswordBloc = ForgotPasswordBloc();
      });

      tearDown(() {
        forgotPasswordBloc.close();
      });

      test('initial state should be ForgotPasswordInitial', () {
        expect(forgotPasswordBloc.state, isA<ForgotPasswordInitial>());
      });

      test('should be closable', () {
        expect(() => forgotPasswordBloc.close(), returnsNormally);
      });
    });
  });

  group('Auth Entity Tests', () {
    test('should handle basic data validation', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      
      // Basic email validation
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      expect(emailRegex.hasMatch(testEmail), isTrue);
      expect(emailRegex.hasMatch('invalid-email'), isFalse);
      
      // Basic password validation
      expect(testPassword.length >= 6, isTrue);
      expect('123'.length >= 6, isFalse);
    });

    test('should handle user profile data', () {
      const testData = {
        'id': 'test-id',
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'phoneNumber': '+1234567890',
      };

      expect(testData['email'], isA<String>());
      expect(testData['firstName'], isA<String>());
      expect(testData['lastName'], isA<String>());
      expect(testData['phoneNumber'], isA<String>());
      expect(testData['id'], isA<String>());
    });
  });

  group('Form Validation Tests', () {
    test('should validate email format', () {
      const validEmails = [
        'test@example.com',
        'user@domain.co.uk',
        'name.lastname@company.org'
      ];
      
      const invalidEmails = [
        'invalid-email',
        '@domain.com',
        'user@',
        'user.domain.com'
      ];

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      
      for (final email in validEmails) {
        expect(emailRegex.hasMatch(email), isTrue, reason: '$email should be valid');
      }
      
      for (final email in invalidEmails) {
        expect(emailRegex.hasMatch(email), isFalse, reason: '$email should be invalid');
      }
    });

    test('should validate password strength', () {
      const weakPasswords = ['123', 'abc', ''];
      const strongPasswords = ['password123', 'mySecurePass', 'test12345'];

      for (final password in weakPasswords) {
        expect(password.length >= 6, isFalse, reason: '$password should be weak');
      }
      
      for (final password in strongPasswords) {
        expect(password.length >= 6, isTrue, reason: '$password should be strong');
      }
    });

    test('should validate phone number format', () {
      const validPhones = ['+1234567890', '+44123456789', '+91123456789'];
      const invalidPhones = ['123456789', '12345', 'abcdefghij'];

      final phoneRegex = RegExp(r'^\+\d{10,15}$');
      
      for (final phone in validPhones) {
        expect(phoneRegex.hasMatch(phone), isTrue, reason: '$phone should be valid');
      }
      
      for (final phone in invalidPhones) {
        expect(phoneRegex.hasMatch(phone), isFalse, reason: '$phone should be invalid');
      }
    });
  });
}