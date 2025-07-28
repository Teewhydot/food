import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/features/auth/domain/use_cases/auth_usecase.dart';
import '../../../test_setup.dart';

void main() {
  setUpAll(() async {
    await setupFirebaseForTests();
  });
  group('Simple Auth Tests', () {
    test('AuthUseCase should be instantiable', () {
      final authUseCase = AuthUseCase();
      expect(authUseCase, isNotNull);
      expect(authUseCase, isA<AuthUseCase>());
    });

    test('AuthUseCase should have all required methods', () {
      final authUseCase = AuthUseCase();
      
      // Test that methods exist
      expect(authUseCase.login, isA<Function>());
      expect(authUseCase.register, isA<Function>());
      expect(authUseCase.sendEmailVerification, isA<Function>());
      expect(authUseCase.sendPasswordResetEmail, isA<Function>());
      expect(authUseCase.signOut, isA<Function>());
      expect(authUseCase.deleteUserAccount, isA<Function>());
      expect(authUseCase.verifyEmail, isA<Function>());
      expect(authUseCase.getCurrentUser, isA<Function>());
    });
  });
}