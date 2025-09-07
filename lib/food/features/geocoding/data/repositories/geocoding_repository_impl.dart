import 'package:get_it/get_it.dart';

import '../../domain/entities/geocoding_data.dart';
import '../../domain/repositories/geocoding_repository.dart';
import '../exceptions/geocoding_exception.dart';
import '../local/data_sources/geocoding_local_data_source.dart';
import '../remote/data_sources/geocoding_datasource.dart';

/// Implementation of geocoding repository with multiple data sources and caching
class GeocodingRepositoryImpl implements GeocodingRepository {
  final _deviceDataSource = GetIt.instance<GeocodingDataSource>();
  final double _coordinateTolerance;

  GeocodingRepositoryImpl({
    GeocodingLocalDataSource? localDataSource, // Made optional
    double coordinateTolerance = 0.001,
  }) : _coordinateTolerance = coordinateTolerance;

  @override
  Future<GeocodingData> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    // Try device geocoding first (native iOS/Android geocoding)
    try {
      final deviceResult = await _deviceDataSource.getAddressFromCoordinates(
        latitude,
        longitude,
      );

      return deviceResult;
    } catch (deviceException) {
      // If device geocoding fails, try OpenWeatherMap as fallback
      try {
        final openWeatherResult = await _deviceDataSource
            .getAddressFromCoordinates(latitude, longitude);
        return openWeatherResult;
      } catch (openWeatherException) {
        // Both sources failed, throw the last exception
        throw GeocodingException(
          message:
              'Failed to get address from coordinates: Both device and OpenWeather geocoding failed',
          code: 'all_sources_failed',
          originalException: openWeatherException,
        );
      }
    }
  }

  @override
  Future<String> getFormattedLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final geocodingData = await getAddressFromCoordinates(
        latitude: latitude,
        longitude: longitude,
      );
      return geocodingData.formattedLocation;
    } catch (e) {
      throw GeocodingException(
        message: 'Failed to get formatted location',
        code: 'format_location_failed',
        originalException: e,
      );
    }
  }

  @override
  bool validateCoordinates(double latitude, double longitude) {
    return latitude >= -90.0 &&
        latitude <= 90.0 &&
        longitude >= -180.0 &&
        longitude <= 180.0;
  }

  @override
  Future<bool> isServiceAvailable() async {
    try {
      // Test with a known coordinate (San Francisco)
      await getAddressFromCoordinates(latitude: 37.7749, longitude: -122.4194);
      return true;
    } catch (e) {
      return false;
    }
  }
}
