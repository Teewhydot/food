import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';
import 'package:uuid/uuid.dart';

abstract class UserDataSource {
  Future<UserProfileEntity> getCurrentUser();
}

class FirebaseUserDSI implements UserDataSource {
  final firebase = FirebaseAuth.instance;
  final database = FirebaseFirestore.instance;

  @override
  Future<UserProfileEntity> getCurrentUser() async {
    final user = firebase.currentUser;
    final userDetails = await database.collection('users').doc(user?.uid).get();
    return user != null
        ? UserProfileEntity(
          id: user.uid,
          firstName: userDetails.data()?['firstName'] ?? '',
          lastName: userDetails.data()?['lastName'] ?? '',
          email: user.email ?? '',
          profileImageUrl: userDetails.data()?['profileImageUrl'] ?? '',
          phoneNumber: user.phoneNumber ?? '',
          bio: userDetails.data()?['bio'] ?? '',
          firstTimeLogin: false,
        )
        : UserProfileEntity(
          firstName: 'John',
          lastName: 'Doe',
          email: 'johndoe@gmail.com',
          phoneNumber: '11111111111',
          bio: 'Just a cool developer',
          firstTimeLogin: false,
          profileImageUrl: '',
          id: Uuid().v4(),
        );
  }
}
