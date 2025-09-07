import 'package:equatable/equatable.dart';

/// Entity representing geocoding data with coordinates and address information
class GeocodingData extends Equatable {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String country;

  const GeocodingData({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.country,
  });

  /// Check if the coordinates are within valid ranges
  bool get isValid {
    return latitude >= -90 && 
           latitude <= 90 && 
           longitude >= -180 && 
           longitude <= 180;
  }

  /// Check if we have meaningful address data
  bool get hasAddressData {
    return address.isNotEmpty;
  }

  /// Get a formatted location string for display
  String get formattedLocation {
    if (city.isNotEmpty && country.isNotEmpty && city != country) {
      return "$city, $country";
    } else if (city.isNotEmpty) {
      return city;
    } else if (country.isNotEmpty) {
      return country;
    } else if (address.isNotEmpty) {
      return address;
    } else {
      return 'Unknown Location';
    }
  }

  /// Create a copy with updated fields
  GeocodingData copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? country,
  }) {
    return GeocodingData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'country': country,
    };
  }

  /// Create from JSON
  factory GeocodingData.fromJson(Map<String, dynamic> json) {
    return GeocodingData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, address, city, country];

  @override
  String toString() {
    return 'GeocodingData(latitude: $latitude, longitude: $longitude, city: $city, country: $country)';
  }
}