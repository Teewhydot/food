import '../entities/geocoding_data.dart';

/// Abstract repository interface for geocoding operations
abstract class GeocodingRepository {
  /// Get address details from coordinates
  /// Returns GeocodingData with address information
  /// Throws GeocodingException if operation fails
  Future<GeocodingData> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  });

  /// Get a formatted location string from coordinates
  /// Returns a human-readable location string
  /// Format: "City, Country" or fallback text
  Future<String> getFormattedLocation({
    required double latitude,
    required double longitude,
  });

  /// Validate if coordinates are within valid ranges
  /// Returns true if coordinates are valid
  bool validateCoordinates(double latitude, double longitude);

  /// Check if geocoding services are available
  /// Returns true if at least one geocoding service is functional
  Future<bool> isServiceAvailable();
}
