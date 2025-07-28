import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/auth/domain/use_cases/auth_usecase.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/register/register_bloc.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'register_bloc_test.mocks.dart';

@GenerateMocks([AuthUseCase])
void main() {
  late RegisterBloc registerBloc;
  late MockAuthUseCase mockAuthUseCase;

  setUp(() {
    mockAuthUseCase = MockAuthUseCase();
    registerBloc = RegisterBloc();
  });

  tearDown(() {
    registerBloc.close();
  });

  group('RegisterBloc', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    const testFirstName = 'John';
    const testLastName = 'Doe';
    const testPhoneNumber = '+1234567890';

    test('initial state should be RegisterInitial', () {
      expect(registerBloc.state, isA<RegisterInitial>());
    });

    group('RegisterInitialEvent', () {
      final testUserProfile = UserProfileEntity(
        id: 'test-id',
        email: testEmail,
        firstName: testFirstName,
        lastName: testLastName,
        phoneNumber: testPhoneNumber,
        firstTimeLogin: true,
      );

      blocTest<RegisterBloc, RegisterState>(
        'emits [RegisterLoading, RegisterSuccess] when registration and email verification are successful',
        build: () {
          when(mockAuthUseCase.register(
            firstName: testFirstName,
            lastName: testLastName,
            email: testEmail,
            phoneNumber: testPhoneNumber,
            password: testPassword,
          )).thenAnswer((_) async => Right(testUserProfile));
          
          when(mockAuthUseCase.sendEmailVerification(testEmail))
              .thenAnswer((_) async => const Right(null));
          
          return registerBloc;
        },
        act: (bloc) => bloc.add(RegisterInitialEvent(
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          password: testPassword,
        )),
        expect: () => [
          isA<RegisterLoading>(),
          isA<RegisterSuccess>().having(
            (state) => state.successMessage,
            'successMessage',
            'Registration successful. Please verify your email.',
          ),
        ],
        verify: (_) {
          verify(mockAuthUseCase.register(
            firstName: testFirstName,
            lastName: testLastName,
            email: testEmail,
            phoneNumber: testPhoneNumber,
            password: testPassword,
          )).called(1);
          verify(mockAuthUseCase.sendEmailVerification(testEmail)).called(1);
        },
      );

      blocTest<RegisterBloc, RegisterState>(
        'emits [RegisterLoading, RegisterFailure] when registration fails',
        build: () {
          when(mockAuthUseCase.register(
            firstName: testFirstName,
            lastName: testLastName,
            email: testEmail,
            phoneNumber: testPhoneNumber,
            password: testPassword,
          )).thenAnswer((_) async => Left(ServerFailure(failureMessage: 'email-already-in-use')));
          
          return registerBloc;
        },
        act: (bloc) => bloc.add(RegisterInitialEvent(
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          password: testPassword,
        )),
        expect: () => [
          isA<RegisterLoading>(),
          isA<RegisterFailure>().having(
            (state) => state.errorMessage,
            'errorMessage',
            contains('email'),
          ),
        ],
        verify: (_) {
          verify(mockAuthUseCase.register(
            firstName: testFirstName,
            lastName: testLastName,
            email: testEmail,
            phoneNumber: testPhoneNumber,
            password: testPassword,
          )).called(1);
          verifyNever(mockAuthUseCase.sendEmailVerification(any));
        },
      );

      blocTest<RegisterBloc, RegisterState>(
        'emits [RegisterLoading, RegisterFailure] when registration succeeds but email verification fails',
        build: () {
          when(mockAuthUseCase.register(
            firstName: testFirstName,
            lastName: testLastName,
            email: testEmail,
            phoneNumber: testPhoneNumber,
            password: testPassword,
          )).thenAnswer((_) async => Right(testUserProfile));
          
          when(mockAuthUseCase.sendEmailVerification(testEmail))
              .thenAnswer((_) async => Left(ServerFailure(failureMessage: 'Email verification failed')));
          
          return registerBloc;
        },
        act: (bloc) => bloc.add(RegisterInitialEvent(
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          password: testPassword,
        )),
        expect: () => [
          isA<RegisterLoading>(),
          isA<RegisterFailure>().having(
            (state) => state.errorMessage,
            'errorMessage',
            contains('Email verification failed'),
          ),
        ],
        verify: (_) {
          verify(mockAuthUseCase.register(
            firstName: testFirstName,
            lastName: testLastName,
            email: testEmail,
            phoneNumber: testPhoneNumber,
            password: testPassword,
          )).called(1);
          verify(mockAuthUseCase.sendEmailVerification(testEmail)).called(1);
        },
      );

      blocTest<RegisterBloc, RegisterState>(
        'emits [RegisterLoading, RegisterFailure] for weak password',
        build: () {
          when(mockAuthUseCase.register(
            firstName: testFirstName,
            lastName: testLastName,
            email: testEmail,
            phoneNumber: testPhoneNumber,
            password: '123',
          )).thenAnswer((_) async => Left(ServerFailure(failureMessage: 'weak-password')));
          
          return registerBloc;
        },
        act: (bloc) => bloc.add(RegisterInitialEvent(
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          password: '123',
        )),
        expect: () => [
          isA<RegisterLoading>(),
          isA<RegisterFailure>().having(
            (state) => state.errorMessage,
            'errorMessage',
            contains('password'),
          ),
        ],
      );

      blocTest<RegisterBloc, RegisterState>(
        'emits [RegisterLoading, RegisterFailure] for invalid email format',
        build: () {
          when(mockAuthUseCase.register(
            firstName: testFirstName,
            lastName: testLastName,
            email: 'invalid-email',
            phoneNumber: testPhoneNumber,
            password: testPassword,
          )).thenAnswer((_) async => Left(ServerFailure(failureMessage: 'invalid-email')));
          
          return registerBloc;
        },
        act: (bloc) => bloc.add(RegisterInitialEvent(
          firstName: testFirstName,
          lastName: testLastName,
          email: 'invalid-email',
          phoneNumber: testPhoneNumber,
          password: testPassword,
        )),
        expect: () => [
          isA<RegisterLoading>(),
          isA<RegisterFailure>().having(
            (state) => state.errorMessage,
            'errorMessage',
            contains('email'),
          ),
        ],
      );
    });
  });
}