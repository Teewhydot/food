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
  final String? profileImageUrl;

  UserProfileEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl,
    this.bio,
    required this.firstTimeLogin,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'firstTimeLogin': firstTimeLogin,
    };
  }

  factory UserProfileEntity.fromJson(Map<String, dynamic> json) {
    return UserProfileEntity(
      id: json['id'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      bio: json['bio'] as String?,
      firstTimeLogin: json['firstTimeLogin'] as bool,
    );
  }
}
