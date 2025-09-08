import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/utils/logger.dart';
import '../../../domain/entities/geocoding_data.dart';
import '../../../domain/entities/placemark_data.dart';
import '../../exceptions/geocoding_exception.dart';
import '../../models/openweather_geocoding_response.dart';

abstract class GeocodingDataSource {
  Future<GeocodingData> getAddressFromCoordinates(
    double latitude,
    double longitude,
  );
}

// implement geocoding functionality
class OpenWeatherMapImpl implements GeocodingDataSource {
  final http.Client httpClient;
  final String? apiKey;
  final Duration timeout;

  final String _baseUrl = 'https://api.openweathermap.org/geo/1.0';

  const OpenWeatherMapImpl({
    required this.httpClient,
    required this.apiKey,
    this.timeout = const Duration(seconds: 10),
  });

  @override
  Future<GeocodingData> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    // Validate coordinates
    if (!_areCoordinatesValid(latitude, longitude)) {
      throw InvalidCoordinatesException(
        latitude: latitude,
        longitude: longitude,
        message: 'Invalid coordinates: lat=$latitude, lon=$longitude',
      );
    }

    // Check API key availability
    if (apiKey == null || apiKey!.isEmpty) {
      throw GeocodingException(
        message: 'OpenWeatherMap API key not available',
        code: 'api_key_missing',
      );
    }

    try {
      final uri = Uri.parse('$_baseUrl/reverse').replace(
        queryParameters: {
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'limit': '1',
          'appid': apiKey!,
        },
      );

      final response = await httpClient
          .get(uri)
          .timeout(
            timeout,
            onTimeout: () {
              throw GeocodingTimeoutException(
                timeout: timeout,
                message:
                    'OpenWeatherMap API request timed out after ${timeout.inSeconds}s',
              );
            },
          );

      if (response.statusCode != 200) {
        throw GeocodingNetworkException(
          message:
              'OpenWeatherMap API error: ${response.statusCode} ${response.reasonPhrase}',
        );
      }

      return _parseResponse(response.body, latitude, longitude);
    } on GeocodingException {
      rethrow;
    } catch (e) {
      throw GeocodingException(
        message: 'OpenWeatherMap geocoding failed: ${e.toString()}',
        code: 'api_geocoding_error',
        originalException: e,
      );
    }
  }

  Future<bool> isAvailable() async {
    return apiKey != null && apiKey!.isNotEmpty;
  }

  /// Parse the API response and convert to GeocodingData
  GeocodingData _parseResponse(String responseBody, double lat, double lon) {
    try {
      final List<dynamic> jsonList = json.decode(responseBody);

      if (jsonList.isEmpty) {
        throw GeocodingException(
          message: 'No results found for coordinates: $lat, $lon',
          code: 'no_results',
        );
      }

      final responseData = OpenWeatherGeocodingResponse.fromJson(
        jsonList.first as Map<String, dynamic>,
      );

      if (!responseData.hasValidData) {
        throw GeocodingException(
          message: 'Invalid or insufficient data in API response',
          code: 'invalid_response_data',
        );
      }

      return responseData.toDomainEntity();
    } catch (e) {
      if (e is GeocodingException) rethrow;

      throw GeocodingException(
        message: 'Failed to parse OpenWeatherMap API response: ${e.toString()}',
        code: 'response_parsing_error',
        originalException: e,
      );
    }
  }

  /// Validate coordinate ranges
  bool _areCoordinatesValid(double latitude, double longitude) {
    return latitude >= -90.0 &&
        latitude <= 90.0 &&
        longitude >= -180.0 &&
        longitude <= 180.0;
  }
}

class DeviceGeocodingRemoteDataSourceImpl implements GeocodingDataSource {
  const DeviceGeocodingRemoteDataSourceImpl();

  @override
  Future<GeocodingData> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    // Validate coordinates
    if (!_areCoordinatesValid(latitude, longitude)) {
      throw InvalidCoordinatesException(
        latitude: latitude,
        longitude: longitude,
        message: 'Invalid coordinates: lat=$latitude, lon=$longitude',
      );
    }

    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        throw GeocodingException(
          message:
              'No geocoding results found for coordinates: $latitude, $longitude',
          code: 'no_results',
        );
      }

      final placemark = placemarks.first;
      final placemarkData = _convertToPlacemarkData(placemark);

      // Build address string
      final address = placemarkData.formattedAddress;
      final city = placemarkData.city;
      final country = placemark.country ?? '';

      // Validate that we got meaningful data
      if (!placemarkData.hasValidData) {
        throw GeocodingException(
          message: 'No meaningful location data found',
          code: 'insufficient_data',
        );
      }
      Logger.logSuccess(
        'Device geocoding successful: $address, $city, $country',
      );
      return GeocodingData(
        latitude: latitude,
        longitude: longitude,
        address: address,
        city: city,
        country: country,
      );
    } on GeocodingException {
      rethrow;
    } catch (e) {
      throw GeocodingException(
        message: 'Device geocoding failed: ${e.toString()}',
        code: 'device_geocoding_error',
        originalException: e,
      );
    }
  }

  Future<bool> isAvailable() async {
    try {
      // Try a basic geocoding call to test availability
      // We'll use coordinates of San Francisco as a test
      await placemarkFromCoordinates(37.7749, -122.4194);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Convert Placemark to PlacemarkData
  PlacemarkData _convertToPlacemarkData(Placemark placemark) {
    return PlacemarkData(
      street: placemark.street,
      subLocality: placemark.subLocality,
      locality: placemark.locality,
      subAdministrativeArea: placemark.subAdministrativeArea,
      administrativeArea: placemark.administrativeArea,
      country: placemark.country,
      postalCode: placemark.postalCode,
    );
  }

  /// Validate coordinate ranges
  bool _areCoordinatesValid(double latitude, double longitude) {
    return latitude >= -90.0 &&
        latitude <= 90.0 &&
        longitude >= -180.0 &&
        longitude <= 180.0;
  }
}
