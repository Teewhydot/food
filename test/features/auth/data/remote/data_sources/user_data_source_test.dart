import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/features/auth/data/custom_exceptions/custom_exceptions.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';

void main() {
  group('Authentication Components', () {
    group('UserNotAuthenticatedException', () {
      test('should have correct message and toString', () {
        final exception = UserNotAuthenticatedException('No authenticated user found');
        expect(exception.message, equals('No authenticated user found'));
        expect(exception.toString(), contains('UserNotAuthenticatedException'));
        expect(exception.toString(), contains('No authenticated user found'));
      });

      test('should be throwable', () {
        expect(
          () => throw UserNotAuthenticatedException('Test error'),
          throwsA(isA<UserNotAuthenticatedException>()),
        );
      });
    });

    group('UserProfileEntity', () {
      test('should be created with correct properties', () {
        final userProfile = UserProfileEntity(
          id: 'test-id',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          phoneNumber: '+1234567890',
          firstTimeLogin: false,
        );

        expect(userProfile.id, equals('test-id'));
        expect(userProfile.email, equals('test@example.com'));
        expect(userProfile.firstName, equals('John'));
        expect(userProfile.lastName, equals('Doe'));
        expect(userProfile.phoneNumber, equals('+1234567890'));
        expect(userProfile.firstTimeLogin, isFalse);
      });

      test('should handle firstTimeLogin flag correctly', () {
        final firstTimeUser = UserProfileEntity(
          id: 'user1',
          email: 'first@example.com',
          firstName: 'First',
          lastName: 'User',
          phoneNumber: '1234567890',
          firstTimeLogin: true,
        );

        final returningUser = UserProfileEntity(
          id: 'user2',
          email: 'returning@example.com',
          firstName: 'Returning',
          lastName: 'User',
          phoneNumber: '0987654321',
          firstTimeLogin: false,
        );

        expect(firstTimeUser.firstTimeLogin, isTrue);
        expect(returningUser.firstTimeLogin, isFalse);
      });

      test('should create different instances with different properties', () {
        final user1 = UserProfileEntity(
          id: 'id1',
          email: 'user1@test.com',
          firstName: 'User',
          lastName: 'One',
          phoneNumber: '111',
          firstTimeLogin: true,
        );

        final user2 = UserProfileEntity(
          id: 'id2',
          email: 'user2@test.com',
          firstName: 'User',
          lastName: 'Two',
          phoneNumber: '222',
          firstTimeLogin: false,
        );

        expect(user1.id, isNot(equals(user2.id)));
        expect(user1.email, isNot(equals(user2.email)));
        expect(user1.firstTimeLogin, isNot(equals(user2.firstTimeLogin)));
      });
    });
  });
}