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

  AddressEntity({
    required this.id,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    this.type = 'home',
  });

  factory AddressEntity.fromJson(Map<String, dynamic> json) {
    return AddressEntity(
      id: json['id'],
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      type: json['type'] as String,
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
    };
  }
}
