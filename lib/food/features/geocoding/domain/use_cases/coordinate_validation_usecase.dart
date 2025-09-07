import 'dart:math' as math;
import '../entities/coordinate_validation_result.dart';

/// Use case for coordinate validation operations
class CoordinateValidationUseCase {
  /// Validate if latitude and longitude are within valid ranges and return detailed result
  /// Latitude: -90 to 90 degrees
  /// Longitude: -180 to 180 degrees
  CoordinateValidationResult validateCoordinates(double latitude, double longitude) {
    if (!validateLatitude(latitude)) {
      return CoordinateValidationResult.invalid(
        'Latitude must be between -90 and 90 degrees. Got: $latitude'
      );
    }
    
    if (!validateLongitude(longitude)) {
      return CoordinateValidationResult.invalid(
        'Longitude must be between -180 and 180 degrees. Got: $longitude'
      );
    }
    
    if (!areCoordinatesMeaningful(latitude, longitude)) {
      return CoordinateValidationResult.invalid(
        'Coordinates appear to be invalid or default values: ($latitude, $longitude)'
      );
    }
    
    return const CoordinateValidationResult.valid();
  }

  /// Simple boolean validation for backwards compatibility
  /// Validate if latitude and longitude are within valid ranges
  /// Latitude: -90 to 90 degrees
  /// Longitude: -180 to 180 degrees
  bool validateCoordinatesSimple(double latitude, double longitude) {
    return validateLatitude(latitude) && validateLongitude(longitude);
  }

  /// Validate if latitude is within valid range (-90 to 90)
  bool validateLatitude(double latitude) {
    return latitude >= -90.0 && latitude <= 90.0;
  }

  /// Validate if longitude is within valid range (-180 to 180)
  bool validateLongitude(double longitude) {
    return longitude >= -180.0 && longitude <= 180.0;
  }

  /// Check if coordinates represent a meaningful location
  /// (not 0,0 which is often a default/invalid value)
  bool areCoordinatesMeaningful(double latitude, double longitude) {
    // First check if coordinates are valid
    if (!validateCoordinatesSimple(latitude, longitude)) {
      return false;
    }

    // Check if coordinates are not the default (0,0) point
    // which is in the Gulf of Guinea and often indicates invalid data
    const double tolerance = 0.0001;
    if (latitude.abs() < tolerance && longitude.abs() < tolerance) {
      return false;
    }

    return true;
  }

  /// Get validation error message for invalid coordinates
  String? getValidationError(double latitude, double longitude) {
    if (!validateLatitude(latitude)) {
      return 'Latitude must be between -90 and 90 degrees. Got: $latitude';
    }
    
    if (!validateLongitude(longitude)) {
      return 'Longitude must be between -180 and 180 degrees. Got: $longitude';
    }
    
    if (!areCoordinatesMeaningful(latitude, longitude)) {
      return 'Coordinates appear to be invalid or default values: ($latitude, $longitude)';
    }
    
    return null; // No error
  }

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    if (!validateCoordinatesSimple(lat1, lon1) || !validateCoordinatesSimple(lat2, lon2)) {
      throw ArgumentError('Invalid coordinates provided');
    }

    const double earthRadius = 6371; // Earth's radius in kilometers

    // Convert degrees to radians
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double lat1Rad = _degreesToRadians(lat1);
    final double lat2Rad = _degreesToRadians(lat2);

    // Haversine formula
    final double a = 
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.sin(dLon / 2) * math.sin(dLon / 2)) * math.cos(lat1Rad) * math.cos(lat2Rad);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Check if two coordinates are within a specified distance (in kilometers)
  bool areCoordinatesWithinDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
    required double maxDistanceKm,
  }) {
    try {
      final double distance = calculateDistance(
        lat1: lat1,
        lon1: lon1,
        lat2: lat2,
        lon2: lon2,
      );
      return distance <= maxDistanceKm;
    } catch (e) {
      return false;
    }
  }

  // Helper method for distance calculation
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}