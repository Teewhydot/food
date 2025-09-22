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

/// Validates cardholder name and returns an error message if invalid, or null if valid.
String? validateCardHolderName(String value) {
  if (value.isEmpty) {
    return "Cardholder name cannot be empty";
  } else if (value.length < 2) {
    return "Cardholder name is too short";
  } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
    return "Name should only contain letters";
  }
  return null;
}

/// Validates card number and returns an error message if invalid, or null if valid.
String? validateCardNumber(String value) {
  final cardNumber = value.replaceAll(' ', '');
  if (cardNumber.isEmpty) {
    return "Card number cannot be empty";
  } else if (cardNumber.length < 13 || cardNumber.length > 19) {
    return "Invalid card number length";
  } else if (!RegExp(r'^[0-9]+$').hasMatch(cardNumber)) {
    return "Card number should only contain digits";
  }
  // Basic Luhn algorithm check
  if (!_isValidCardNumber(cardNumber)) {
    return "Invalid card number";
  }
  return null;
}

/// Validates expiry date and returns an error message if invalid, or null if valid.
String? validateExpiryDate(String value) {
  if (value.isEmpty) {
    return "Expiry date cannot be empty";
  }

  if (!RegExp(r'^[0-9]{2}/[0-9]{2}$').hasMatch(value)) {
    return "Invalid format. Use MM/YY";
  }

  final parts = value.split('/');
  final month = int.tryParse(parts[0]);
  final year = int.tryParse(parts[1]);

  if (month == null || year == null) {
    return "Invalid expiry date";
  }

  if (month < 1 || month > 12) {
    return "Invalid month";
  }

  final currentYear = DateTime.now().year % 100;
  final currentMonth = DateTime.now().month;

  if (year < currentYear || (year == currentYear && month < currentMonth)) {
    return "Card has expired";
  }

  return null;
}

/// Validates CVV and returns an error message if invalid, or null if valid.
String? validateCVV(String value) {
  if (value.isEmpty) {
    return "CVV cannot be empty";
  } else if (value.length < 3 || value.length > 4) {
    return "CVV must be 3 or 4 digits";
  } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
    return "CVV should only contain digits";
  }
  return null;
}

/// Simple Luhn algorithm implementation for card number validation
bool _isValidCardNumber(String cardNumber) {
  int sum = 0;
  bool alternate = false;

  for (int i = cardNumber.length - 1; i >= 0; i--) {
    int digit = int.parse(cardNumber[i]);

    if (alternate) {
      digit *= 2;
      if (digit > 9) {
        digit = (digit % 10) + 1;
      }
    }

    sum += digit;
    alternate = !alternate;
  }

  return sum % 10 == 0;
}
