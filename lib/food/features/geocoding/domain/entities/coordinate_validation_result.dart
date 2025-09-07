import 'package:equatable/equatable.dart';

/// Result object for coordinate validation operations
class CoordinateValidationResult extends Equatable {
  final bool isValid;
  final String? errorMessage;

  const CoordinateValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  /// Create a valid result
  const CoordinateValidationResult.valid() 
    : isValid = true, 
      errorMessage = null;

  /// Create an invalid result with error message
  const CoordinateValidationResult.invalid(String errorMessage) 
    : isValid = false, 
      errorMessage = errorMessage;

  @override
  List<Object?> get props => [isValid, errorMessage];

  @override
  String toString() => 
    'CoordinateValidationResult(isValid: $isValid, error: $errorMessage)';
}