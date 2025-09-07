import '../../domain/entities/geocoding_data.dart';
import '../../domain/entities/placemark_data.dart';

/// Data model for OpenWeatherMap geocoding API response
class OpenWeatherGeocodingResponse {
  final String? name;
  final String? localNames;
  final double? lat;
  final double? lon;
  final String? country;
  final String? state;

  const OpenWeatherGeocodingResponse({
    this.name,
    this.localNames,
    this.lat,
    this.lon,
    this.country,
    this.state,
  });

  /// Create from JSON response
  factory OpenWeatherGeocodingResponse.fromJson(Map<String, dynamic> json) {
    return OpenWeatherGeocodingResponse(
      name: json['name'] as String?,
      localNames: json['local_names']?.toString(),
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      country: json['country'] as String?,
      state: json['state'] as String?,
    );
  }

  /// Convert to domain entity
  GeocodingData toDomainEntity() {
    return GeocodingData(
      latitude: lat ?? 0.0,
      longitude: lon ?? 0.0,
      address: name ?? '',
      city: state ?? name ?? '',
      country: country ?? '',
    );
  }

  /// Convert to placemark data
  PlacemarkData toPlacemarkData() {
    return PlacemarkData(
      street: null,
      subLocality: null,
      locality: name,
      subAdministrativeArea: null,
      administrativeArea: state,
      country: country,
      postalCode: null,
    );
  }

  /// Check if response has valid data
  bool get hasValidData {
    return lat != null && 
           lon != null && 
           (name != null && name!.isNotEmpty || 
            country != null && country!.isNotEmpty);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'local_names': localNames,
      'lat': lat,
      'lon': lon,
      'country': country,
      'state': state,
    };
  }

  @override
  String toString() {
    return 'OpenWeatherGeocodingResponse(name: $name, lat: $lat, lon: $lon, country: $country, state: $state)';
  }
}