import '../../data/exceptions/geocoding_exception.dart';
import '../entities/geocoding_data.dart';
import '../repositories/geocoding_repository.dart';

/// Use case for geocoding operations
class GeocodingUseCase {
  final GeocodingRepository _repository;

  const GeocodingUseCase(this._repository);

  /// Get address details from coordinates
  /// Returns GeocodingData with address information
  /// Throws GeocodingException if operation fails or coordinates are invalid
  Future<GeocodingData> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    // Validate coordinates first
    if (!_repository.validateCoordinates(latitude, longitude)) {
      throw GeocodingException(
        message:
            'Invalid coordinates: latitude=$latitude, longitude=$longitude',
        code: 'invalid_coordinates',
      );
    }

    try {
      final geocodingData = await _repository.getAddressFromCoordinates(
        latitude: latitude,
        longitude: longitude,
      );

      // Validate the returned data
      if (!geocodingData.isValid) {
        throw GeocodingException(
          message: 'Invalid geocoding data returned from repository',
          code: 'invalid_data',
        );
      }

      return geocodingData;
    } on GeocodingException {
      rethrow;
    } catch (e) {
      throw GeocodingException(
        message: 'Failed to get address from coordinates: ${e.toString()}',
        code: 'geocoding_failed',
        originalException: e,
      );
    }
  }

  /// Get a formatted location string from coordinates
  /// Returns a human-readable location string
  /// Format: "City, Country" or fallback text
  Future<String> getFormattedLocation({
    required double latitude,
    required double longitude,
  }) async {
    // Validate coordinates first
    if (!_repository.validateCoordinates(latitude, longitude)) {
      return 'Invalid Location';
    }

    try {
      return await _repository.getFormattedLocation(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      // Return fallback instead of throwing for formatted location
      return 'Unknown Location';
    }
  }

  /// Check if geocoding services are available
  Future<bool> isServiceAvailable() async {
    try {
      return await _repository.isServiceAvailable();
    } catch (e) {
      return false;
    }
  }
}
