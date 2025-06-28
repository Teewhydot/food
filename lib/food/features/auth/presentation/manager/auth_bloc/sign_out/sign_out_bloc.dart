import 'package:bloc/bloc.dart';
import 'package:food/food/core/bloc/app_state.dart';
import 'package:meta/meta.dart';

import '../../../../domain/use_cases/auth_usecase.dart';

part 'sign_out_event.dart';
part 'sign_out_state.dart';

class SignOutBloc extends Bloc<SignOutEvent, SignOutState> {
  final _authUseCase = AuthUseCase();

  SignOutBloc() : super(SignOutInitialState()) {
    on<SignOutRequestEvent>((event, emit) async {
      emit(SignOutLoadingState());

      final result = await _authUseCase.signOut();

      result.fold(
        (failure) =>
            emit(SignOutFailureState(errorMessage: failure.failureMessage)),
        (_) => emit(
          SignOutSuccessState(successMessage: 'Successfully signed out'),
        ),
      );
    });
  }
}
