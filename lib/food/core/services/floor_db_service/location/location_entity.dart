import 'package:floor/floor.dart';
import 'package:food/food/features/auth/domain/entities/location_data.dart';

@Entity(tableName: 'cached_locations')
class LocationFloorEntity {
  @PrimaryKey(autoGenerate: false)
  final int id;
  
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String country;
  final int timestamp; // Unix timestamp for cache expiry

  const LocationFloorEntity({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.country,
    required this.timestamp,
  });

  LocationData toDomain() => LocationData(
    latitude: latitude,
    longitude: longitude,
    address: address,
    city: city,
    country: country,
  );

  static LocationFloorEntity fromDomain(LocationData locationData) => LocationFloorEntity(
    id: 1, // Using single ID since we only cache current location
    latitude: locationData.latitude,
    longitude: locationData.longitude,
    address: locationData.address,
    city: locationData.city,
    country: locationData.country,
    timestamp: DateTime.now().millisecondsSinceEpoch,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'city': city,
    'country': country,
    'timestamp': timestamp,
  };

  factory LocationFloorEntity.fromJson(Map<String, dynamic> json) => LocationFloorEntity(
    id: json['id'] as int,
    latitude: json['latitude'] as double,
    longitude: json['longitude'] as double,
    address: json['address'] as String,
    city: json['city'] as String,
    country: json['country'] as String,
    timestamp: json['timestamp'] as int,
  );
}