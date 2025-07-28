import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/auth/domain/use_cases/auth_usecase.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/forgot_password/forgot_password_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'forgot_password_bloc_test.mocks.dart';

@GenerateMocks([AuthUseCase])
void main() {
  late ForgotPasswordBloc forgotPasswordBloc;
  late MockAuthUseCase mockAuthUseCase;

  setUp(() {
    mockAuthUseCase = MockAuthUseCase();
    forgotPasswordBloc = ForgotPasswordBloc();
  });

  tearDown(() {
    forgotPasswordBloc.close();
  });

  group('ForgotPasswordBloc', () {
    const testEmail = 'test@example.com';

    test('initial state should be ForgotPasswordInitial', () {
      expect(forgotPasswordBloc.state, isA<ForgotPasswordInitial>());
    });

    group('ForgotPasswordSubmitEvent', () {
      blocTest<ForgotPasswordBloc, ForgotPasswordState>(
        'emits [ForgotPasswordLoading, ForgotPasswordSuccess] when password reset email is sent successfully',
        build: () {
          when(mockAuthUseCase.sendPasswordResetEmail(testEmail))
              .thenAnswer((_) async => const Right(null));
          return forgotPasswordBloc;
        },
        act: (bloc) => bloc.add(ForgotPasswordSubmitEvent(email: testEmail)),
        expect: () => [
          isA<ForgotPasswordLoading>(),
          isA<ForgotPasswordSuccess>().having(
            (state) => state.successMessage,
            'successMessage',
            'Password reset link sent to $testEmail',
          ),
        ],
        verify: (_) {
          verify(mockAuthUseCase.sendPasswordResetEmail(testEmail)).called(1);
        },
      );

      blocTest<ForgotPasswordBloc, ForgotPasswordState>(
        'emits [ForgotPasswordLoading, ForgotPasswordFailure] when sending password reset email fails',
        build: () {
          when(mockAuthUseCase.sendPasswordResetEmail(testEmail))
              .thenAnswer((_) async => Left(ServerFailure(failureMessage: 'user-not-found')));
          return forgotPasswordBloc;
        },
        act: (bloc) => bloc.add(ForgotPasswordSubmitEvent(email: testEmail)),
        expect: () => [
          isA<ForgotPasswordLoading>(),
          isA<ForgotPasswordFailure>().having(
            (state) => state.errorMessage,
            'errorMessage',
            'user-not-found',
          ),
        ],
        verify: (_) {
          verify(mockAuthUseCase.sendPasswordResetEmail(testEmail)).called(1);
        },
      );

      blocTest<ForgotPasswordBloc, ForgotPasswordState>(
        'emits [ForgotPasswordLoading, ForgotPasswordFailure] for invalid email',
        build: () {
          when(mockAuthUseCase.sendPasswordResetEmail('invalid-email'))
              .thenAnswer((_) async => Left(ServerFailure(failureMessage: 'invalid-email')));
          return forgotPasswordBloc;
        },
        act: (bloc) => bloc.add(ForgotPasswordSubmitEvent(email: 'invalid-email')),
        expect: () => [
          isA<ForgotPasswordLoading>(),
          isA<ForgotPasswordFailure>().having(
            (state) => state.errorMessage,
            'errorMessage',
            'invalid-email',
          ),
        ],
      );

      blocTest<ForgotPasswordBloc, ForgotPasswordState>(
        'emits [ForgotPasswordLoading, ForgotPasswordFailure] when network error occurs',
        build: () {
          when(mockAuthUseCase.sendPasswordResetEmail(testEmail))
              .thenAnswer((_) async => Left(ServerFailure(failureMessage: 'Network error')));
          return forgotPasswordBloc;
        },
        act: (bloc) => bloc.add(ForgotPasswordSubmitEvent(email: testEmail)),
        expect: () => [
          isA<ForgotPasswordLoading>(),
          isA<ForgotPasswordFailure>().having(
            (state) => state.errorMessage,
            'errorMessage',
            'Network error',
          ),
        ],
      );

      blocTest<ForgotPasswordBloc, ForgotPasswordState>(
        'handles multiple consecutive events correctly',
        build: () {
          when(mockAuthUseCase.sendPasswordResetEmail(any))
              .thenAnswer((_) async => const Right(null));
          return forgotPasswordBloc;
        },
        act: (bloc) {
          bloc.add(ForgotPasswordSubmitEvent(email: testEmail));
          bloc.add(ForgotPasswordSubmitEvent(email: 'another@example.com'));
        },
        expect: () => [
          isA<ForgotPasswordLoading>(),
          isA<ForgotPasswordSuccess>(),
          isA<ForgotPasswordLoading>(),
          isA<ForgotPasswordSuccess>(),
        ],
      );
    });
  });
}