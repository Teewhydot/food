import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/features/auth/data/remote/data_sources/login_data_source.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_data_source_test.mocks.dart';

@GenerateMocks([FirebaseAuth, UserCredential, User])
void main() {
  late FirebaseLoginDSI loginDataSource;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    loginDataSource = FirebaseLoginDSI();
  });

  group('FirebaseLoginDSI', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    test('should return UserCredential when login is successful', () async {
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenAnswer((_) async => mockUserCredential);

      final result = await mockFirebaseAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );

      expect(result, equals(mockUserCredential));
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).called(1);
    });

    test('should throw FirebaseAuthException when login fails', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenThrow(FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found for that email.',
      ));

      expect(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('should throw FirebaseAuthException for wrong password', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: 'wrongpassword',
      )).thenThrow(FirebaseAuthException(
        code: 'wrong-password',
        message: 'Wrong password provided.',
      ));

      expect(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: testEmail,
          password: 'wrongpassword',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });
}