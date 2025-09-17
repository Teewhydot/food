import 'package:bloc/bloc.dart';

import '../../../../../../core/bloc/base/base_bloc.dart';
import '../../../../../../core/bloc/base/base_state.dart';
import '../../../../../../core/bloc/utils/state_utils.dart';
import '../../../../../../core/utils/logger.dart';
import '../../../../../../core/utils/pretty_firebase_errors.dart';
import '../../../../../home/domain/entities/profile.dart';
import '../../../../domain/use_cases/auth_usecase.dart';
import 'login_event.dart';

/// Enhanced Login BLoC with modern state management
class EnhancedLoginBloc
    extends BaseBloC<EnhancedLoginEvent, BaseState<UserProfileEntity>> {
  final AuthUseCase _authUseCase;

  EnhancedLoginBloc({AuthUseCase? authUseCase})
    : _authUseCase = authUseCase ?? AuthUseCase(),
      super(const InitialState<UserProfileEntity>()) {
    on<LoginSubmitEvent>(_onLoginSubmit);
    // on<LoginRetryEvent>(_onLoginRetry);
    on<LoginResetEvent>(_onLoginReset);
    on<LoginValidateEvent>(_onLoginValidate);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  /// Handle login submission
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<BaseState<UserProfileEntity>> emit,
  ) async {
    emit(
      const LoadingState<UserProfileEntity>(
        message: 'Checking authentication status...',
      ),
    );
    final result = await _authUseCase.getCurrentUser();
    await result.fold(
      (failure) async {
        emit(
          ErrorState<UserProfileEntity>(
            errorMessage: getAuthErrorMessage(failure.failureMessage),
            errorCode: failure.failureMessage,
            isRetryable: false,
          ),
        );
      },
      (userProfile) async {
        // Create loaded state with user profile
        final loadedState = StateUtils.createLoadedState(
          userProfile,
          isFromCache: false,
        );

        emit(loadedState);
      },
    );
  }

  Future<void> _onLoginSubmit(
    LoginSubmitEvent event,
    Emitter<BaseState<UserProfileEntity>> emit,
  ) async {
    emit(const LoadingState<UserProfileEntity>(message: 'Signing you in...'));

    try {
      Logger.logBasic('Attempting login for email: ${event.email}');

      final result = await _authUseCase.login(event.email, event.password);

      await result.fold(
        (failure) async {
          final errorMessage = getAuthErrorMessage(failure.failureMessage);
          final errorState = ErrorState<UserProfileEntity>(
            errorMessage: errorMessage,
            errorCode: failure.failureMessage,
            isRetryable: false,
          );

          emit(errorState);
          Logger.logError('Login failed: $errorMessage');
        },
        (userProfile) async {
          // Create loaded state with user profile
          final loadedState = StateUtils.createLoadedState(
            userProfile,
            isFromCache: false,
          );

          emit(loadedState);

          // Also emit a success message
          emit(
            const SuccessState<UserProfileEntity>(
              successMessage: 'Successfully logged in! Welcome back.',
            ),
          );
          Logger.logSuccess(
            'Login successful for user: ${userProfile.firstName} ${userProfile.lastName}',
          );
        },
      );
    } catch (e, stackTrace) {
      final errorState = ErrorState<UserProfileEntity>(
        errorMessage: 'An unexpected error occurred. Please try again.',
        exception: Exception(e.toString()),
        stackTrace: stackTrace,
        isRetryable: true,
      );

      emit(errorState);
      Logger.logError('Login exception: $e');
    }
  }

  Future<void> _onLoginReset(
    LoginResetEvent event,
    Emitter<BaseState<UserProfileEntity>> emit,
  ) async {
    emit(const InitialState<UserProfileEntity>());
    Logger.logBasic('Login state reset');
  }

  /// Handle input validation
  Future<void> _onLoginValidate(
    LoginValidateEvent event,
    Emitter<BaseState<UserProfileEntity>> emit,
  ) async {
    final validationErrors = _validateLoginInput(event.email, event.password);

    if (validationErrors.isNotEmpty) {
      emit(
        ErrorState<UserProfileEntity>(
          errorMessage: validationErrors.first,
          errorCode: 'validation_error',
          isRetryable: false, // Validation errors are not retryable
        ),
      );
    } else {
      // Input is valid, proceed with login
      add(LoginSubmitEvent(email: event.email, password: event.password));
    }
  }

  /// Validate login input
  List<String> _validateLoginInput(String email, String password) {
    final errors = <String>[];

    // Email validation
    if (email.isEmpty) {
      errors.add('Email is required');
    } else if (!_isValidEmail(email)) {
      errors.add('Please enter a valid email address');
    }

    // Password validation
    if (password.isEmpty) {
      errors.add('Password is required');
    } else if (password.length < 6) {
      errors.add('Password must be at least 6 characters long');
    }

    return errors;
  }

  /// Check if email format is valid
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Quick login method for external use
  void quickLogin({required String email, required String password}) {
    add(LoginValidateEvent(email: email, password: password));
  }

  /// Reset to initial state
  void resetLogin() {
    add(const LoginResetEvent());
  }
}
