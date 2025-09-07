import 'package:equatable/equatable.dart';

/// Entity representing structured address components from geocoding services
class PlacemarkData extends Equatable {
  final String? street;
  final String? subLocality;
  final String? locality;
  final String? subAdministrativeArea;
  final String? administrativeArea;
  final String? country;
  final String? postalCode;

  const PlacemarkData({
    this.street,
    this.subLocality,
    this.locality,
    this.subAdministrativeArea,
    this.administrativeArea,
    this.country,
    this.postalCode,
  });

  /// Build a formatted address string from available components
  String get formattedAddress {
    List<String> addressParts = [];
    
    if (street != null && street!.isNotEmpty) {
      addressParts.add(street!);
    }
    if (subLocality != null && subLocality!.isNotEmpty) {
      addressParts.add(subLocality!);
    }
    if (locality != null && locality!.isNotEmpty) {
      addressParts.add(locality!);
    }
    
    return addressParts.isNotEmpty 
        ? addressParts.join(', ')
        : 'Unknown Location';
  }

  /// Get the city name - prioritize locality, fallback to subAdministrativeArea
  String get city {
    if (locality != null && locality!.isNotEmpty) {
      return locality!;
    }
    if (subAdministrativeArea != null && subAdministrativeArea!.isNotEmpty) {
      return subAdministrativeArea!;
    }
    return '';
  }

  /// Check if we have valid/meaningful placemark data
  bool get hasValidData {
    // We consider data valid if we have at least locality, street, or administrative area
    // Having only country is not considered sufficient
    return (locality != null && locality!.isNotEmpty) ||
           (street != null && street!.isNotEmpty) ||
           (subLocality != null && subLocality!.isNotEmpty) ||
           (administrativeArea != null && administrativeArea!.isNotEmpty) ||
           (subAdministrativeArea != null && subAdministrativeArea!.isNotEmpty);
  }

  /// Create a copy with updated fields
  PlacemarkData copyWith({
    String? street,
    String? subLocality,
    String? locality,
    String? subAdministrativeArea,
    String? administrativeArea,
    String? country,
    String? postalCode,
  }) {
    return PlacemarkData(
      street: street ?? this.street,
      subLocality: subLocality ?? this.subLocality,
      locality: locality ?? this.locality,
      subAdministrativeArea: subAdministrativeArea ?? this.subAdministrativeArea,
      administrativeArea: administrativeArea ?? this.administrativeArea,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
    );
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'subLocality': subLocality,
      'locality': locality,
      'subAdministrativeArea': subAdministrativeArea,
      'administrativeArea': administrativeArea,
      'country': country,
      'postalCode': postalCode,
    };
  }

  /// Create from JSON
  factory PlacemarkData.fromJson(Map<String, dynamic> json) {
    return PlacemarkData(
      street: json['street'] as String?,
      subLocality: json['subLocality'] as String?,
      locality: json['locality'] as String?,
      subAdministrativeArea: json['subAdministrativeArea'] as String?,
      administrativeArea: json['administrativeArea'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    street,
    subLocality,
    locality,
    subAdministrativeArea,
    administrativeArea,
    country,
    postalCode,
  ];

  @override
  String toString() {
    return 'PlacemarkData(street: $street, locality: $locality, country: $country)';
  }
}