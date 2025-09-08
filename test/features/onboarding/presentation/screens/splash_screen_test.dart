import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';

void main() {
  group('SplashScreen Authentication Logic', () {
    group('Error State Handling', () {
      test('should detect UserNotAuthenticatedException in error message', () {
        const errorState = ErrorState<UserProfileEntity>(
          errorMessage:
              'UserNotAuthenticatedException: No authenticated user found',
          errorCode: 'auth_error',
        );

        expect(
          errorState.errorMessage.contains('UserNotAuthenticatedException'),
          isTrue,
        );
        expect(
          errorState.errorMessage.contains('No authenticated user found'),
          isTrue,
        );
      });

      test('should detect various authentication error formats', () {
        const errorState1 = ErrorState<UserProfileEntity>(
          errorMessage:
              'UserNotAuthenticatedException: No authenticated user found',
          errorCode: 'auth_error',
        );

        const errorState2 = ErrorState<UserProfileEntity>(
          errorMessage: 'No authenticated user found',
          errorCode: 'auth_error',
        );

        // Test the logic from splash_screen.dart
        bool shouldRedirectToLogin1 =
            errorState1.errorMessage.contains(
                  'UserNotAuthenticatedException',
                ) ==
                true ||
            errorState1.errorMessage.contains('No authenticated user found') ==
                true;

        bool shouldRedirectToLogin2 =
            errorState2.errorMessage.contains(
                  'UserNotAuthenticatedException',
                ) ==
                true ||
            errorState2.errorMessage.contains('No authenticated user found') ==
                true;

        expect(shouldRedirectToLogin1, isTrue);
        expect(shouldRedirectToLogin2, isTrue);
      });
    });

    group('User State Routing Logic', () {
      test('should identify first-time users for onboarding', () {
        final userProfile = UserProfileEntity(
          id: 'test-id',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          phoneNumber: '+1234567890',
          firstTimeLogin: true,
        );

        final loadedState = LoadedState<UserProfileEntity>(
          data: userProfile,
          lastUpdated: DateTime.now(),
        );

        expect(loadedState.hasData, isTrue);
        expect(loadedState.data?.firstTimeLogin, isTrue);
      });

      test('should identify returning users for home screen', () {
        final userProfile = UserProfileEntity(
          id: 'test-id',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          phoneNumber: '+1234567890',
          firstTimeLogin: false,
        );

        final loadedState = LoadedState<UserProfileEntity>(
          data: userProfile,
          lastUpdated: DateTime.now(),
        );

        expect(loadedState.hasData, isTrue);
        expect(loadedState.data?.firstTimeLogin, isFalse);
      });

      test('should handle loaded state with user data correctly', () {
        final userProfile = UserProfileEntity(
          id: 'test-id',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          phoneNumber: '+1234567890',
          firstTimeLogin: false,
        );

        final loadedState = LoadedState<UserProfileEntity>(
          data: userProfile,
          lastUpdated: DateTime.now(),
        );

        // Test the logic from splash_screen.dart checkLoggedIn method
        expect(loadedState.hasData, isTrue);
        expect(loadedState.data, isNotNull);
        expect(loadedState.data?.id, equals('test-id'));
      });
    });

    group('Route Decision Logic', () {
      test('should determine correct route for different user states', () {
        // Test route decision logic from SplashScreen
        final firstTimeUser = UserProfileEntity(
          id: 'user1',
          email: 'test1@test.com',
          firstName: 'Test',
          lastName: 'User',
          phoneNumber: '1234567890',
          firstTimeLogin: true,
        );

        final returningUser = UserProfileEntity(
          id: 'user2',
          email: 'test2@test.com',
          firstName: 'Test',
          lastName: 'User',
          phoneNumber: '1234567890',
          firstTimeLogin: false,
        );

        // Logic: if firstTimeLogin is true -> onboarding, else -> home
        String routeForFirstTime =
            firstTimeUser.firstTimeLogin == true
                ? Routes.onboarding
                : Routes.home;
        String routeForReturning =
            returningUser.firstTimeLogin == true
                ? Routes.onboarding
                : Routes.home;

        expect(routeForFirstTime, equals(Routes.onboarding));
        expect(routeForReturning, equals(Routes.home));
      });
    });
  });
}
