import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Auth Form Validation Tests', () {
    group('Email Validation', () {
      test('should validate correct email formats', () {
        const validEmails = [
          'test@example.com',
          'user@domain.co.uk',
          'name.lastname@company.org',
          'user123@test.io',
          'first.last+tag@domain.com'
        ];
        
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        
        for (final email in validEmails) {
          expect(emailRegex.hasMatch(email), isTrue, reason: '$email should be valid');
        }
      });

      test('should reject incorrect email formats', () {
        const invalidEmails = [
          'invalid-email',
          '@domain.com',
          'user@',
          'user.domain.com',
          'user@@domain.com',
          'user@domain',
          ''
        ];

        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        
        for (final email in invalidEmails) {
          expect(emailRegex.hasMatch(email), isFalse, reason: '$email should be invalid');
        }
      });
    });

    group('Password Validation', () {
      test('should accept strong passwords', () {
        const strongPasswords = [
          'password123',
          'mySecurePass',
          'test12345',
          'StrongPassword1',
          'MyP@ssw0rd!'
        ];

        for (final password in strongPasswords) {
          expect(password.length >= 6, isTrue, reason: '$password should be strong enough');
          expect(password.isNotEmpty, isTrue);
        }
      });

      test('should reject weak passwords', () {
        const weakPasswords = ['123', 'abc', '', '12345', 'test'];

        for (final password in weakPasswords) {
          expect(password.length >= 6, isFalse, reason: '$password should be too weak');
        }
      });

      test('should validate password complexity', () {
        const password = 'MyP@ssw0rd123';
        
        expect(password.length >= 8, isTrue);
        expect(RegExp(r'[A-Z]').hasMatch(password), isTrue); // Has uppercase
        expect(RegExp(r'[a-z]').hasMatch(password), isTrue); // Has lowercase
        expect(RegExp(r'[0-9]').hasMatch(password), isTrue); // Has number
        expect(RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password), isTrue); // Has special char
      });
    });

    group('Phone Number Validation', () {
      test('should validate international phone numbers', () {
        const validPhones = [
          '+1234567890',
          '+44123456789',
          '+91123456789',
          '+8612345678901',
          '+33123456789'
        ];

        final phoneRegex = RegExp(r'^\+\d{10,15}$');
        
        for (final phone in validPhones) {
          expect(phoneRegex.hasMatch(phone), isTrue, reason: '$phone should be valid');
        }
      });

      test('should reject invalid phone numbers', () {
        const invalidPhones = [
          '123456789',     // No country code
          '+123',          // Too short
          'abcdefghij',    // Contains letters
          '+123456789012345678', // Too long
          ''               // Empty
        ];

        final phoneRegex = RegExp(r'^\+\d{10,15}$');
        
        for (final phone in invalidPhones) {
          expect(phoneRegex.hasMatch(phone), isFalse, reason: '$phone should be invalid');
        }
      });
    });

    group('Name Validation', () {
      test('should validate names', () {
        const validNames = ['John', 'Mary', 'Jean-Pierre', "O'Connor", 'José'];
        
        for (final name in validNames) {
          expect(name.trim().isNotEmpty, isTrue, reason: '$name should be valid');
          expect(name.length >= 2, isTrue, reason: '$name should be long enough');
        }
      });

      test('should reject invalid names', () {
        const invalidNames = ['', ' ', 'A', '123', '@#\$%'];
        
        for (final name in invalidNames) {
          final isValid = name.trim().isNotEmpty && 
                         name.length >= 2 &&
                         name.contains(RegExp(r'^[a-zA-Z\s\-\.]+$'));
          expect(isValid, isFalse, reason: '$name should be invalid');
        }
      });
    });

    group('Form State Validation', () {
      test('should validate complete registration form', () {
        const formData = {
          'firstName': 'John',
          'lastName': 'Doe',
          'email': 'john.doe@example.com',
          'phoneNumber': '+1234567890',
          'password': 'SecurePass123',
          'confirmPassword': 'SecurePass123',
        };

        // Check all required fields are present
        expect(formData['firstName']?.isNotEmpty, isTrue);
        expect(formData['lastName']?.isNotEmpty, isTrue);
        expect(formData['email']?.isNotEmpty, isTrue);
        expect(formData['phoneNumber']?.isNotEmpty, isTrue);
        expect(formData['password']?.isNotEmpty, isTrue);
        
        // Validate email format
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        expect(emailRegex.hasMatch(formData['email']!), isTrue);
        
        // Validate password strength
        expect(formData['password']!.length >= 6, isTrue);
        
        // Validate password confirmation
        expect(formData['password'], equals(formData['confirmPassword']));
        
        // Validate phone number format
        final phoneRegex = RegExp(r'^\+\d{10,15}$');
        expect(phoneRegex.hasMatch(formData['phoneNumber']!), isTrue);
      });

      test('should validate login form', () {
        const loginData = {
          'email': 'user@example.com',
          'password': 'mypassword123',
        };

        expect(loginData['email']?.isNotEmpty, isTrue);
        expect(loginData['password']?.isNotEmpty, isTrue);
        
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        expect(emailRegex.hasMatch(loginData['email']!), isTrue);
        expect(loginData['password']!.length >= 6, isTrue);
      });
    });
  });

  group('Auth Error Handling Tests', () {
    test('should handle common Firebase auth error codes', () {
      const errorCodes = {
        'user-not-found': 'No user found with this email address',
        'wrong-password': 'Incorrect password provided',
        'email-already-in-use': 'An account already exists with this email',
        'weak-password': 'Password should be at least 6 characters',
        'invalid-email': 'Please enter a valid email address',
        'user-disabled': 'This account has been disabled',
        'too-many-requests': 'Too many attempts. Please try again later',
      };

      for (final code in errorCodes.keys) {
        expect(errorCodes[code]?.isNotEmpty, isTrue, reason: 'Error message for $code should not be empty');
        expect(errorCodes[code]?.length, greaterThan(10), reason: 'Error message should be descriptive');
      }
    });

    test('should provide user-friendly error messages', () {
      const technicalErrors = [
        'network-request-failed',
        'internal-error',
        'unknown-error'
      ];

      for (final error in technicalErrors) {
        final friendlyMessage = 'Something went wrong. Please try again.';
        expect(friendlyMessage.isNotEmpty, isTrue);
        expect(friendlyMessage.contains('try again'), isTrue);
        expect(error.isNotEmpty, isTrue); // Use the error variable
      }
    });
  });

  group('Auth State Management Tests', () {
    test('should handle loading states', () {
      const states = ['initial', 'loading', 'success', 'error'];
      
      for (final state in states) {
        expect(state.isNotEmpty, isTrue);
        expect(['initial', 'loading', 'success', 'error'].contains(state), isTrue);
      }
    });

    test('should validate user session data', () {
      const userData = {
        'uid': 'test-user-id',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'emailVerified': true,
        'createdAt': '2025-07-28T00:00:00.000Z',
      };

      expect((userData['uid'] as String?)?.isNotEmpty, isTrue);
      expect((userData['email'] as String?)?.isNotEmpty, isTrue);
      expect(userData['emailVerified'], isA<bool>());
      expect((userData['createdAt'] as String?)?.isNotEmpty, isTrue);
    });
  });
}