import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../constants/env.dart';
import '../utils/logger.dart';

/// Service for handling geocoding operations (converting coordinates to addresses)
class GeocodingService {
  static final GeocodingService _instance = GeocodingService._internal();
  factory GeocodingService() => _instance;
  GeocodingService._internal();

  /// Get address details from latitude and longitude
  /// Returns a map with 'address', 'city', and 'country' keys
  Future<Map<String, String>> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // First try using the device's local geocoding service
      final addressDetails = await _getLocalGeocodingData(latitude, longitude);
      if (addressDetails != null) {
        return addressDetails;
      }

      // If local geocoding fails, try OpenWeatherMap API as fallback
      final apiAddressDetails = await _getOpenWeatherMapGeocodingData(latitude, longitude);
      if (apiAddressDetails != null) {
        return apiAddressDetails;
      }

      // If all methods fail, return default values
      return _getDefaultAddressData();
    } catch (e) {
      Logger.logError("Error in GeocodingService: ${e.toString()}");
      return _getErrorAddressData();
    }
  }

  /// Try to get address using device's local geocoding service
  Future<Map<String, String>?> _getLocalGeocodingData(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Build address string
        String address = _buildAddressString(place);
        String city = place.locality ?? place.subAdministrativeArea ?? '';
        String country = place.country ?? '';
        
        // Only return if we have meaningful data
        if (city.isNotEmpty || country.isNotEmpty) {
          return {
            'address': address,
            'city': city,
            'country': country,
          };
        }
      }
    } catch (e) {
      Logger.logError("Local geocoding failed: ${e.toString()}");
    }
    return null;
  }

  /// Try to get address using OpenWeatherMap reverse geocoding API
  Future<Map<String, String>?> _getOpenWeatherMapGeocodingData(
    double latitude,
    double longitude,
  ) async {
    try {
      final apiKey = Env.openWeatherMapKey;
      
      // Check if API key is available
      if (apiKey == null || apiKey.isEmpty) {
        Logger.logError("OpenWeatherMap API key not available for geocoding");
        return null;
      }

      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/geo/1.0/reverse?lat=$latitude&lon=$longitude&limit=1&appid=$apiKey',
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('OpenWeatherMap API timeout');
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final location = data[0];
          
          // Build address from available data
          String address = location['name'] ?? '';
          String city = location['state'] ?? location['name'] ?? '';
          String country = location['country'] ?? '';
          
          return {
            'address': address,
            'city': city,
            'country': country,
          };
        }
      } else {
        Logger.logError("OpenWeatherMap API error: ${response.statusCode}");
      }
    } catch (e) {
      Logger.logError("OpenWeatherMap geocoding failed: ${e.toString()}");
    }
    return null;
  }

  /// Build a formatted address string from Placemark data
  String _buildAddressString(Placemark place) {
    List<String> addressParts = [];
    
    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    
    return addressParts.isNotEmpty 
        ? addressParts.join(', ')
        : 'Unknown Location';
  }

  /// Return default address data when geocoding fails
  Map<String, String> _getDefaultAddressData() {
    return {
      'address': 'Unknown Address',
      'city': 'Unknown City',
      'country': 'Unknown Country',
    };
  }

  /// Return error address data when an exception occurs
  Map<String, String> _getErrorAddressData() {
    return {
      'address': 'Error getting address',
      'city': '',
      'country': '',
    };
  }

  /// Get a formatted location string from coordinates
  /// Returns format: "City, Country" or fallback text
  Future<String> getFormattedLocation({
    required double latitude,
    required double longitude,
  }) async {
    final addressData = await getAddressFromCoordinates(
      latitude: latitude,
      longitude: longitude,
    );

    final city = addressData['city'] ?? '';
    final country = addressData['country'] ?? '';

    if (city.isNotEmpty && country.isNotEmpty && city != country) {
      return "$city, $country";
    } else if (city.isNotEmpty) {
      return city;
    } else if (country.isNotEmpty) {
      return country;
    } else {
      return addressData['address'] ?? 'Unknown Location';
    }
  }

  /// Check if coordinates are valid
  bool areCoordinatesValid(double latitude, double longitude) {
    return latitude >= -90 && 
           latitude <= 90 && 
           longitude >= -180 && 
           longitude <= 180;
  }
}