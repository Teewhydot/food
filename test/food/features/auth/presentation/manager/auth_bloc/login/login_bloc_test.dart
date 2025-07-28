import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/auth/domain/use_cases/auth_usecase.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/login/login_bloc.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_bloc_test.mocks.dart';

@GenerateMocks([AuthUseCase])
void main() {
  late LoginBloc loginBloc;
  late MockAuthUseCase mockAuthUseCase;

  setUp(() {
    mockAuthUseCase = MockAuthUseCase();
    loginBloc = LoginBloc();
  });

  tearDown(() {
    loginBloc.close();
  });

  group('LoginBloc', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    test('initial state should be LoginInitialState', () {
      expect(loginBloc.state, isA<LoginInitialState>());
    });

    group('AuthLoginEvent', () {
      final testUserProfile = UserProfileEntity(
        id: 'test-id',
        email: testEmail,
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+1234567890',
        firstTimeLogin: false,
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginLoadingState, LoginSuccessState] when login is successful',
        build: () {
          when(mockAuthUseCase.login(testEmail, testPassword))
              .thenAnswer((_) async => Right(testUserProfile));
          return loginBloc;
        },
        act: (bloc) => bloc.add(AuthLoginEvent(
          email: testEmail,
          password: testPassword,
        )),
        expect: () => [
          isA<LoginLoadingState>(),
          isA<LoginSuccessState>().having(
            (state) => state.successMessage,
            'successMessage',
            'Successfully logged in',
          ),
        ],
        verify: (_) {
          verify(mockAuthUseCase.login(testEmail, testPassword)).called(1);
        },
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginLoadingState, LoginFailureState] when login fails',
        build: () {
          when(mockAuthUseCase.login(testEmail, testPassword))
              .thenAnswer((_) async => Left(ServerFailure(failureMessage: 'Login failed')));
          return loginBloc;
        },
        act: (bloc) => bloc.add(AuthLoginEvent(
          email: testEmail,
          password: testPassword,
        )),
        expect: () => [
          isA<LoginLoadingState>(),
          isA<LoginFailureState>().having(
            (state) => state.errorMessage,
            'errorMessage',
            contains('Login failed'),
          ),
        ],
        verify: (_) {
          verify(mockAuthUseCase.login(testEmail, testPassword)).called(1);
        },
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginLoadingState, LoginFailureState] when login throws exception',
        build: () {
          when(mockAuthUseCase.login(testEmail, testPassword))
              .thenThrow(Exception('Network error'));
          return loginBloc;
        },
        act: (bloc) => bloc.add(AuthLoginEvent(
          email: testEmail,
          password: testPassword,
        )),
        expect: () => [
          isA<LoginLoadingState>(),
          isA<LoginFailureState>(),
        ],
        verify: (_) {
          verify(mockAuthUseCase.login(testEmail, testPassword)).called(1);
        },
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginLoadingState, LoginFailureState] for invalid email',
        build: () {
          when(mockAuthUseCase.login('invalid-email', testPassword))
              .thenAnswer((_) async => Left(ServerFailure(failureMessage: 'invalid-email')));
          return loginBloc;
        },
        act: (bloc) => bloc.add(AuthLoginEvent(
          email: 'invalid-email',
          password: testPassword,
        )),
        expect: () => [
          isA<LoginLoadingState>(),
          isA<LoginFailureState>().having(
            (state) => state.errorMessage,
            'errorMessage',
            contains('email'),
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginLoadingState, LoginFailureState] for user not found',
        build: () {
          when(mockAuthUseCase.login(testEmail, testPassword))
              .thenAnswer((_) async => Left(ServerFailure(failureMessage: 'user-not-found')));
          return loginBloc;
        },
        act: (bloc) => bloc.add(AuthLoginEvent(
          email: testEmail,
          password: testPassword,
        )),
        expect: () => [
          isA<LoginLoadingState>(),
          isA<LoginFailureState>().having(
            (state) => state.errorMessage,
            'errorMessage',
            contains('user'),
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginLoadingState, LoginFailureState] for wrong password',
        build: () {
          when(mockAuthUseCase.login(testEmail, 'wrongpassword'))
              .thenAnswer((_) async => Left(ServerFailure(failureMessage: 'wrong-password')));
          return loginBloc;
        },
        act: (bloc) => bloc.add(AuthLoginEvent(
          email: testEmail,
          password: 'wrongpassword',
        )),
        expect: () => [
          isA<LoginLoadingState>(),
          isA<LoginFailureState>().having(
            (state) => state.errorMessage,
            'errorMessage',
            contains('password'),
          ),
        ],
      );
    });
  });
}