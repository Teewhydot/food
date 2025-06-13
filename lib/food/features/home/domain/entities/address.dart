import 'package:floor/floor.dart';

import '../../../../core/services/floor_db_service/constants.dart';
import 'profile.dart';

@Entity(
  tableName: FloorDbConstants.addressTableName,
  foreignKeys: [
    ForeignKey(
      childColumns: ['userId'],
      parentColumns: ['id'],
      entity: UserProfileEntity,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class AddressEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final int userId;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String type;

  AddressEntity({
    this.id,
    this.userId = 1, // Default userId to 1
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    this.type = 'home',
  });

  factory AddressEntity.fromJson(Map<String, dynamic> json) {
    return AddressEntity(
      id: json['id'],
      userId: json['userId'] ?? 1, // Use 1 if userId is missing
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
      'userId': userId,
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'type': type,
    };
  }
}
