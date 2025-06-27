import 'package:floor/floor.dart';

import '../../../../core/services/floor_db_service/constants.dart';

@Entity(tableName: FloorDbConstants.userProfileTableName)
class UserProfileEntity {
  @PrimaryKey()
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? bio;
  final bool firstTimeLogin;

  UserProfileEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.bio,
    required this.firstTimeLogin,
  });
}
