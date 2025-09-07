import 'package:floor/floor.dart';
import '../../domain/entities/geocoding_data.dart';

/// Floor database entity for caching geocoding results
@entity
class GeocodingCacheModel {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  
  @ColumnInfo(name: 'latitude')
  final double latitude;
  
  @ColumnInfo(name: 'longitude')
  final double longitude;
  
  @ColumnInfo(name: 'address')
  final String address;
  
  @ColumnInfo(name: 'city')
  final String city;
  
  @ColumnInfo(name: 'country')
  final String country;
  
  @ColumnInfo(name: 'cached_at')
  final DateTime cachedAt;
  
  @ColumnInfo(name: 'expires_at')
  final DateTime expiresAt;

  const GeocodingCacheModel({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.country,
    required this.cachedAt,
    required this.expiresAt,
  });

  /// Create from domain entity
  factory GeocodingCacheModel.fromDomainEntity(
    GeocodingData geocodingData, {
    Duration cacheDuration = const Duration(hours: 24),
  }) {
    final now = DateTime.now();
    return GeocodingCacheModel(
      latitude: geocodingData.latitude,
      longitude: geocodingData.longitude,
      address: geocodingData.address,
      city: geocodingData.city,
      country: geocodingData.country,
      cachedAt: now,
      expiresAt: now.add(cacheDuration),
    );
  }

  /// Convert to domain entity
  GeocodingData toDomainEntity() {
    return GeocodingData(
      latitude: latitude,
      longitude: longitude,
      address: address,
      city: city,
      country: country,
    );
  }

  /// Check if cache entry is still valid (not expired)
  bool get isValid {
    return DateTime.now().isBefore(expiresAt);
  }

  /// Check if coordinates match within tolerance
  bool matchesCoordinates(double lat, double lon, {double tolerance = 0.001}) {
    return (latitude - lat).abs() <= tolerance && 
           (longitude - lon).abs() <= tolerance;
  }

  /// Copy with new values
  GeocodingCacheModel copyWith({
    int? id,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? country,
    DateTime? cachedAt,
    DateTime? expiresAt,
  }) {
    return GeocodingCacheModel(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      cachedAt: cachedAt ?? this.cachedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  String toString() {
    return 'GeocodingCacheModel(id: $id, lat: $latitude, lon: $longitude, city: $city, country: $country, cachedAt: $cachedAt)';
  }
}