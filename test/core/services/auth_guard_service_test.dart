import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/core/services/auth_guard_service.dart';

void main() {
  group('AuthGuardService', () {
    test('should identify protected routes correctly', () {
      expect(AuthGuardService.isProtectedRoute(Routes.home), isTrue);
      expect(AuthGuardService.isProtectedRoute(Routes.search), isTrue);
      expect(AuthGuardService.isProtectedRoute(Routes.cart), isTrue);
      expect(AuthGuardService.isProtectedRoute(Routes.personalInfo), isTrue);
      
      expect(AuthGuardService.isProtectedRoute(Routes.login), isFalse);
      expect(AuthGuardService.isProtectedRoute(Routes.register), isFalse);
      expect(AuthGuardService.isProtectedRoute(Routes.onboarding), isFalse);
    });

    test('should identify public routes correctly', () {
      expect(AuthGuardService.isPublicRoute(Routes.login), isTrue);
      expect(AuthGuardService.isPublicRoute(Routes.register), isTrue);
      expect(AuthGuardService.isPublicRoute(Routes.onboarding), isTrue);
      expect(AuthGuardService.isPublicRoute(Routes.initial), isTrue);
      
      expect(AuthGuardService.isPublicRoute(Routes.home), isFalse);
      expect(AuthGuardService.isPublicRoute(Routes.search), isFalse);
      expect(AuthGuardService.isPublicRoute(Routes.cart), isFalse);
    });

    test('should have all important routes categorized', () {
      final allRoutes = [
        Routes.initial,
        Routes.onboarding,
        Routes.login,
        Routes.register,
        Routes.forgotPassword,
        Routes.home,
        Routes.search,
        Routes.cart,
        Routes.personalInfo,
        Routes.address,
        Routes.notifications,
      ];

      for (final route in allRoutes) {
        final isProtected = AuthGuardService.isProtectedRoute(route);
        final isPublic = AuthGuardService.isPublicRoute(route);
        
        // Each route should be either protected or public, not both
        expect(isProtected && isPublic, isFalse, 
          reason: 'Route $route should not be both protected and public');
        expect(isProtected || isPublic, isTrue,
          reason: 'Route $route should be either protected or public');
      }
    });
  });
}