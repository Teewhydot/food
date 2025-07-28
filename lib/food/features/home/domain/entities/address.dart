import 'package:floor/floor.dart';

import '../../../../core/services/floor_db_service/constants.dart';

@Entity(tableName: FloorDbConstants.addressTableName)
class AddressEntity {
  @primaryKey
  final String id;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String type;
  final String address;
  final String apartment;
  final String? title;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  AddressEntity({
    required this.id,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.address,
    required this.apartment,
    this.type = 'home',
    this.title,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  String get fullAddress => '$address, $apartment, $city, $state $zipCode';

  factory AddressEntity.fromJson(Map<String, dynamic> json) {
    return AddressEntity(
      id: json['id'],
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      type: json['type'] as String? ?? 'home',
      address: json['address'] as String,
      apartment: json['apartment'] as String,
      title: json['title'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'type': type,
      'address': address,
      'apartment': apartment,
      'title': title,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }
}
