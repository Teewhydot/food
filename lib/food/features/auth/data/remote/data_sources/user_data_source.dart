import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';
import '../../custom_exceptions/custom_exceptions.dart';

abstract class UserDataSource {
  Future<UserProfileEntity> getCurrentUser();
}

class FirebaseUserDSI implements UserDataSource {
  final firebase = FirebaseAuth.instance;
  final database = FirebaseFirestore.instance;

  @override
  Future<UserProfileEntity> getCurrentUser() async {
    final user = firebase.currentUser;
    
    if (user == null) {
      throw UserNotAuthenticatedException('No authenticated user found');
    }
    
    final userDetails = await database.collection('users').doc(user.uid).get();
    
    return UserProfileEntity(
      id: user.uid,
      firstName: userDetails.data()?['firstName'] ?? '',
      lastName: userDetails.data()?['lastName'] ?? '',
      email: user.email ?? '',
      profileImageUrl: userDetails.data()?['profileImageUrl'] ?? '',
      phoneNumber: user.phoneNumber ?? '',
      bio: userDetails.data()?['bio'] ?? '',
      firstTimeLogin: false,
    );
  }
}
