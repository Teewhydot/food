import 'package:bloc/bloc.dart';
import 'package:food/food/core/bloc/app_state.dart';
import 'package:meta/meta.dart';

import '../../../../domain/use_cases/auth_usecase.dart';

part 'delete_account_event.dart';
part 'delete_account_state.dart';

class DeleteAccountBloc extends Bloc<DeleteAccountEvent, DeleteAccountState> {
  final _authUseCase = AuthUseCase();

  DeleteAccountBloc() : super(DeleteAccountInitialState()) {
    on<DeleteAccountRequestEvent>((event, emit) async {
      emit(DeleteAccountLoadingState());

      final result = await _authUseCase.deleteUserAccount();

      result.fold(
        (failure) => emit(
          DeleteAccountFailureState(errorMessage: failure.failureMessage),
        ),
        (_) => emit(
          DeleteAccountSuccessState(
            successMessage: 'Account successfully deleted',
          ),
        ),
      );
    });
  }
}
