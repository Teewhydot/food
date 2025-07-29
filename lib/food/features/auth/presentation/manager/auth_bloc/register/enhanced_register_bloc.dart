import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import '../../../../../../core/bloc/base/base_bloc.dart';
import '../../../../../../core/bloc/base/base_state.dart';
import '../../../../../../core/bloc/utils/state_utils.dart';
import '../../../../../../core/utils/logger.dart';
import '../../../../../../core/utils/pretty_firebase_errors.dart';
import '../../../../../home/domain/entities/profile.dart';
import '../../../../domain/use_cases/auth_usecase.dart';

/// Enhanced Registration Events using sealed classes
@immutable
sealed class EnhancedRegisterEvent {
  const EnhancedRegisterEvent();
}

/// Event to submit registration data
@immutable
final class RegisterSubmitEvent extends EnhancedRegisterEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;

  const RegisterSubmitEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
  });

  @override
  String toString() => 'RegisterSubmitEvent(email: $email)';
}

/// Event to validate registration input
@immutable
final class RegisterValidateEvent extends EnhancedRegisterEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;

  const RegisterValidateEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
  });

  @override
  String toString() => 'RegisterValidateEvent(email: $email)';
}

/// Event to retry registration
@immutable
final class RegisterRetryEvent extends EnhancedRegisterEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;

  const RegisterRetryEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
  });

  @override
  String toString() => 'RegisterRetryEvent(email: $email)';
}

/// Event to reset registration state
@immutable
final class RegisterResetEvent extends EnhancedRegisterEvent {
  const RegisterResetEvent();

  @override
  String toString() => 'RegisterResetEvent()';
}

/// Registration data model for better organization
@immutable
class RegistrationData {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;

  const RegistrationData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
  });

  @override
  String toString() => 'RegistrationData(email: $email, name: $firstName $lastName)';
}

/// Enhanced Registration BLoC with modern state management
class EnhancedRegisterBloc extends BaseBloC<EnhancedRegisterEvent, BaseState<UserProfileEntity>> {
  final AuthUseCase _authUseCase;

  EnhancedRegisterBloc({
    AuthUseCase? authUseCase,
  }) : _authUseCase = authUseCase ?? AuthUseCase(),
       super(const InitialState<UserProfileEntity>()) {
    on<RegisterSubmitEvent>(_onRegisterSubmit);
    on<RegisterValidateEvent>(_onRegisterValidate);
    on<RegisterRetryEvent>(_onRegisterRetry);
    on<RegisterResetEvent>(_onRegisterReset);
  }

  /// Handle registration submission
  Future<void> _onRegisterSubmit(
    RegisterSubmitEvent event,
    Emitter<BaseState<UserProfileEntity>> emit,
  ) async {
    emit(const LoadingState<UserProfileEntity>(message: 'Creating your account...'));

    try {
      Logger.logBasic('Attempting registration for email: ${event.email}');
      
      // First, register the user
      final registerResult = await _authUseCase.register(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        phoneNumber: event.phoneNumber,
      );

      await registerResult.fold(
        (failure) async {
          final errorMessage = getAuthErrorMessage(failure.failureMessage);
          final errorState = ErrorState<UserProfileEntity>(
            errorMessage: errorMessage,
            errorCode: failure.failureMessage,
            isRetryable: _isRetryableError(failure.failureMessage),
          );
          
          emit(errorState);
          Logger.logError('Registration failed: $errorMessage');
        },
        (userProfile) async {
          Logger.logSuccess('Registration successful for: ${userProfile.firstName} ${userProfile.lastName}');
          
          // Update loading message for email verification
          emit(const LoadingState<UserProfileEntity>(
            message: 'Sending verification email...',
          ));

          // Send verification email
          final verificationResult = await _authUseCase.sendEmailVerification(event.email);
          
          await verificationResult.fold(
            (failure) async {
              // Registration succeeded but email verification failed
              // Still consider this a success but with a warning
              emit(StateUtils.createLoadedState(userProfile));
              
              emit(SuccessState<UserProfileEntity>(
                successMessage: 'Account created successfully! However, we couldn\'t send the verification email. You can request it again later.',
                metadata: {
                  'verification_email_failed': true,
                  'user_email': event.email,
                },
              ));
              
              Logger.logWarning('Registration successful but email verification failed: ${failure.failureMessage}');
            },
            (_) async {
              // Both registration and email verification succeeded
              emit(StateUtils.createLoadedState(userProfile));
              
              emit(SuccessState<UserProfileEntity>(
                successMessage: 'Account created successfully! Please check your email to verify your account.',
                metadata: {
                  'verification_email_sent': true,
                  'user_email': event.email,
                },
              ));
              
              Logger.logSuccess('Registration and email verification successful');
            },
          );
        },
      );
    } catch (e, stackTrace) {
      final errorState = ErrorState<UserProfileEntity>(
        errorMessage: 'An unexpected error occurred during registration. Please try again.',
        exception: Exception(e.toString()),
        stackTrace: stackTrace,
        isRetryable: true,
      );
      
      emit(errorState);
      Logger.logError('Registration exception: $e');
    }
  }

  /// Handle registration validation
  Future<void> _onRegisterValidate(
    RegisterValidateEvent event,
    Emitter<BaseState<UserProfileEntity>> emit,
  ) async {
    final validationErrors = _validateRegistrationInput(
      firstName: event.firstName,
      lastName: event.lastName,
      email: event.email,
      phoneNumber: event.phoneNumber,
      password: event.password,
      confirmPassword: event.confirmPassword,
    );
    
    if (validationErrors.isNotEmpty) {
      emit(ErrorState<UserProfileEntity>(
        errorMessage: validationErrors.first,
        errorCode: 'validation_error',
        isRetryable: false, // Validation errors are not retryable
      ));
    } else {
      // Input is valid, proceed with registration
      add(RegisterSubmitEvent(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        phoneNumber: event.phoneNumber,
        password: event.password,
        confirmPassword: event.confirmPassword,
      ));
    }
  }

  /// Handle registration retry
  Future<void> _onRegisterRetry(
    RegisterRetryEvent event,
    Emitter<BaseState<UserProfileEntity>> emit,
  ) async {
    Logger.logBasic('Retrying registration attempt');
    add(RegisterSubmitEvent(
      firstName: event.firstName,
      lastName: event.lastName,
      email: event.email,
      phoneNumber: event.phoneNumber,
      password: event.password,
      confirmPassword: event.confirmPassword,
    ));
  }

  /// Handle registration reset
  Future<void> _onRegisterReset(
    RegisterResetEvent event,
    Emitter<BaseState<UserProfileEntity>> emit,
  ) async {
    emit(const InitialState<UserProfileEntity>());
    Logger.logBasic('Registration state reset');
  }

  /// Validate registration input
  List<String> _validateRegistrationInput({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) {
    final errors = <String>[];

    // First name validation
    if (firstName.trim().isEmpty) {
      errors.add('First name is required');
    } else if (firstName.trim().length < 2) {
      errors.add('First name must be at least 2 characters long');
    }

    // Last name validation
    if (lastName.trim().isEmpty) {
      errors.add('Last name is required');
    } else if (lastName.trim().length < 2) {
      errors.add('Last name must be at least 2 characters long');
    }

    // Email validation
    if (email.isEmpty) {
      errors.add('Email is required');
    } else if (!_isValidEmail(email)) {
      errors.add('Please enter a valid email address');
    }

    // Phone number validation
    if (phoneNumber.isEmpty) {
      errors.add('Phone number is required');
    } else if (!_isValidPhoneNumber(phoneNumber)) {
      errors.add('Please enter a valid phone number');
    }

    // Password validation
    if (password.isEmpty) {
      errors.add('Password is required');
    } else if (password.length < 6) {
      errors.add('Password must be at least 6 characters long');
    } else if (!_isStrongPassword(password)) {
      errors.add('Password must contain at least one uppercase letter, one lowercase letter, and one number');
    }

    // Confirm password validation
    if (confirmPassword.isEmpty) {
      errors.add('Please confirm your password');
    } else if (password != confirmPassword) {
      errors.add('Passwords do not match');
    }

    return errors;
  }

  /// Check if email format is valid
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Check if phone number format is valid
  bool _isValidPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    // Check if it has 10-15 digits (international format)
    return digitsOnly.length >= 10 && digitsOnly.length <= 15;
  }

  /// Check if password is strong enough
  bool _isStrongPassword(String password) {
    // At least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    // At least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;
    // At least one digit
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    return true;
  }

  /// Determine if an error is retryable
  bool _isRetryableError(String errorCode) {
    const nonRetryableErrors = [
      'email-already-in-use',
      'invalid-email',
      'weak-password',
    ];
    
    return !nonRetryableErrors.contains(errorCode);
  }

  /// Quick registration method for external use
  void quickRegister({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) {
    add(RegisterValidateEvent(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      confirmPassword: confirmPassword,
    ));
  }

  /// Reset to initial state
  void resetRegistration() {
    add(const RegisterResetEvent());
  }

  /// Get registration data from current input
  RegistrationData? getCurrentRegistrationData() {
    // This would be implemented if we stored current input in state
    return null;
  }
}