import 'package:food/food/core/utils/validators.dart';
import 'package:get/get.dart';

/// Validates a password and returns an error message if invalid, or null if valid.
String? validatePassword(String value) {
  if (value.isEmpty) {
    return "Password cannot be empty";
  } else if (value.length < 6) {
    return "Password must be at least 6 characters";
  } else if (passwordValidator.call(value) != null) {
    return "Password must contain a mix of characters";
  }
  return null;
}

/// Validates an email and returns an error message if invalid, or null if valid.
String? validateEmail(String value) {
  if (value.isEmpty) {
    return "Email cannot be empty";
  } else if (!GetUtils.isEmail(value)) {
    return "Please enter a valid email";
  }
  return null;
}

/// Validates a name field and returns an error message if invalid, or null if valid.
String? validateName(String value) {
  if (value.isEmpty) {
    return "Name cannot be empty";
  } else if (value.length < 2) {
    return "Name is too short";
  } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
    return "Name should only contain letters";
  }
  return null;
}

/// Function to validate a password and update an error state through a callback
typedef ErrorSetter = void Function(String? error);

/// Validates a password and updates the error state through the provided callback
void validatePasswordWithCallback(String value, ErrorSetter setError) {
  setError(validatePassword(value));
}

/// Validates an email and updates the error state through the provided callback
void validateEmailWithCallback(String value, ErrorSetter setError) {
  setError(validateEmail(value));
}

/// Validates a name and updates the error state through the provided callback
void validateNameWithCallback(String value, ErrorSetter setError) {
  setError(validateName(value));
}
