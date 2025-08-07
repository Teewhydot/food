import 'package:meta/meta.dart';

/// Enhanced Login Events using sealed classes
@immutable
sealed class EnhancedLoginEvent {
  const EnhancedLoginEvent();
}

/// Event to submit login credentials
@immutable
final class LoginSubmitEvent extends EnhancedLoginEvent {
  final String email;
  final String password;

  const LoginSubmitEvent({required this.email, required this.password});

  @override
  String toString() => 'LoginSubmitEvent(email: $email)';
}

/// Event to retry login with same credentials
@immutable
final class LoginRetryEvent extends EnhancedLoginEvent {
  final String email;
  final String password;

  const LoginRetryEvent({required this.email, required this.password});

  @override
  String toString() => 'LoginRetryEvent(email: $email)';
}

/// Event to reset login state
@immutable
final class LoginResetEvent extends EnhancedLoginEvent {
  const LoginResetEvent();

  @override
  String toString() => 'LoginResetEvent()';
}

/// Event to validate input before login
@immutable
final class LoginValidateEvent extends EnhancedLoginEvent {
  final String email;
  final String password;

  const LoginValidateEvent({required this.email, required this.password});

  @override
  String toString() => 'LoginValidateEvent(email: $email)';
}
