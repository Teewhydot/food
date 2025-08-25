import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:meta/meta.dart';

import '../../../../domain/use_cases/auth_usecase.dart';

part 'delete_account_event.dart';
// part 'delete_account_state.dart'; // Commented out - using BaseState now

/// Migrated DeleteAccountBloc to use BaseState<void>
class DeleteAccountBloc extends BaseBloC<DeleteAccountEvent, BaseState<void>> {
  final _authUseCase = AuthUseCase();

  DeleteAccountBloc() : super(const InitialState<void>()) {
    on<DeleteAccountRequestEvent>((event, emit) async {
      emit(const LoadingState<void>(message: 'Deleting your account...'));

      final result = await _authUseCase.deleteUserAccount();

      result.fold(
        (failure) => emit(
          ErrorState<void>(
            errorMessage: failure.failureMessage,
            errorCode: 'delete_account_failed',
            isRetryable: false, // Account deletion should not be retryable
          ),
        ),
        (_) => emit(
          const SuccessState<void>(
            successMessage: 'Account successfully deleted',
          ),
        ),
      );
    });
  }
}
