import 'package:food/food/features/home/domain/entities/profile.dart';

class UserProfile extends UserProfileEntity {
  UserProfile({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
    required super.firstTimeLogin,
  });
}
