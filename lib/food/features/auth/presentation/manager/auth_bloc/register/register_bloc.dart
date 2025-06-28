import 'package:bloc/bloc.dart';
import 'package:food/food/core/bloc/app_state.dart';
import 'package:food/food/core/utils/pretty_firebase_errors.dart';
import 'package:meta/meta.dart';

import '../../../../domain/use_cases/auth_usecase.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final _authUseCase = AuthUseCase();
  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterInitialEvent>((event, emit) async {
      emit(RegisterLoading());
      final result = await _authUseCase.register(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        phoneNumber: event.phoneNumber,
      );

      await result.fold(
        (failure) async {
          emit(
            RegisterFailure(
              errorMessage: getAuthErrorMessage(failure.failureMessage),
            ),
          );
        },
        (userProfile) async {
          // Send verification email after successful registration
          final verificationResult = await _authUseCase.sendEmailVerification(
            event.email,
          );

          await verificationResult.fold(
            (failure) async {
              emit(
                RegisterFailure(
                  errorMessage: getAuthErrorMessage(failure.failureMessage),
                ),
              );
            },
            (_) async {
              emit(
                RegisterSuccess(
                  successMessage:
                      'Registration successful. Please verify your email.',
                ),
              );
            },
          );
        },
      );
    });
  }
}
