import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food/food/features/auth/domain/entities/user_profile.dart';

abstract class EmailVerificationStatusDataSource {
  Future<UserProfile> checkEmailVerification();
}

class FirebaseEmailVerificationStatusDSI
    implements EmailVerificationStatusDataSource {
  @override
  Future<UserProfile> checkEmailVerification() async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    // Get current user
    final user = auth.currentUser;

    if (user == null) {
      throw Exception('No user is currently signed in');
    }

    // Force reload user to get the latest email verification status
    await user.reload();

    // Get fresh user instance after reload
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      throw Exception('User session expired');
    }

    // Check if email is verified
    if (!currentUser.emailVerified) {
      throw Exception('Email not verified');
    }

    // Get additional user info from Firestore
    try {
      final userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }

      final userData = userDoc.data()!;

      return UserProfile(
        id: currentUser.uid,
        email: currentUser.email ?? '',
        firstName: userData['firstName'] as String? ?? '',
        lastName: userData['lastName'] as String? ?? '',
        phoneNumber: userData['phoneNumber'] as String? ?? '',
        firstTimeLogin: false,
      );
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }
}
