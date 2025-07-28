import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/features/auth/data/remote/data_sources/register_data_source.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'register_data_source_test.mocks.dart';

@GenerateMocks([FirebaseAuth, UserCredential, User])
void main() {
  late FirebaseRegisterDSI registerDataSource;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    registerDataSource = FirebaseRegisterDSI();
  });

  group('FirebaseRegisterDSI', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    test('should return UserCredential when registration is successful', () async {
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenAnswer((_) async => mockUserCredential);

      final result = await mockFirebaseAuth.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );

      expect(result, equals(mockUserCredential));
      verify(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).called(1);
    });

    test('should throw FirebaseAuthException when email is already in use', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenThrow(FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'The account already exists for that email.',
      ));

      expect(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('should throw FirebaseAuthException for weak password', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: testEmail,
        password: '123',
      )).thenThrow(FirebaseAuthException(
        code: 'weak-password',
        message: 'The password provided is too weak.',
      ));

      expect(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: testEmail,
          password: '123',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('should throw FirebaseAuthException for invalid email', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'invalid-email',
        password: testPassword,
      )).thenThrow(FirebaseAuthException(
        code: 'invalid-email',
        message: 'The email address is badly formatted.',
      ));

      expect(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'invalid-email',
          password: testPassword,
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });
}