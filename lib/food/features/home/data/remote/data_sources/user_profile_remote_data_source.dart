import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../domain/entities/profile.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfileEntity> getUserProfile(String userId);
  Future<UserProfileEntity> updateUserProfile(UserProfileEntity profile);
  Future<String> uploadProfileImage(String userId, File imageFile);
  Future<void> deleteProfileImage(String userId);
  Future<UserProfileEntity> updateProfileField(
    String userId,
    String field,
    dynamic value,
  );
  Stream<UserProfileEntity> watchUserProfile(String userId);
}

class FirebaseUserProfileRemoteDataSource
    implements UserProfileRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<UserProfileEntity> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();

    if (!doc.exists) {
      throw Exception('User profile not found');
    }

    return _profileFromFirestore(doc);
  }

  @override
  Future<UserProfileEntity> updateUserProfile(UserProfileEntity profile) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final profileData = {
      'firstName': profile.firstName,
      'lastName': profile.lastName,
      'bio': profile.bio ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(userId).update(profileData);

    // Also update Firebase Auth profile
    if (_auth.currentUser != null) {
      await _auth.currentUser!.updateDisplayName(
        '${profile.firstName} ${profile.lastName}',
      );

      if (profile.profileImageUrl != null) {
        await _auth.currentUser!.updatePhotoURL(profile.profileImageUrl);
      }
    }

    return profile;
  }

  @override
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      // Create a reference to the location you want to upload to in firebase
      final storageRef = _storage
          .ref()
          .child('profile_images')
          .child('$userId.jpg');

      // Upload the file
      final uploadTask = await storageRef.putFile(imageFile);

      // Get the download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update the user's profile with the new image URL
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update Firebase Auth profile photo
      if (_auth.currentUser != null) {
        await _auth.currentUser!.updatePhotoURL(downloadUrl);
      }

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  @override
  Future<void> deleteProfileImage(String userId) async {
    try {
      // Delete the image from Firebase Storage
      final storageRef = _storage
          .ref()
          .child('profile_images')
          .child('$userId.jpg');

      await storageRef.delete();

      // Update the user's profile to remove the image URL
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update Firebase Auth profile photo
      if (_auth.currentUser != null) {
        await _auth.currentUser!.updatePhotoURL(null);
      }
    } catch (e) {
      // If the image doesn't exist in storage, still update the profile
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<UserProfileEntity> updateProfileField(
    String userId,
    String field,
    dynamic value,
  ) async {
    await _firestore.collection('users').doc(userId).update({
      field: value,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return getUserProfile(userId);
  }

  @override
  Stream<UserProfileEntity> watchUserProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => _profileFromFirestore(doc));
  }

  UserProfileEntity _profileFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserProfileEntity(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      bio: data['bio'],
      profileImageUrl: data['profileImageUrl'],
      firstTimeLogin: data['firstTimeLogin'] ?? false,
    );
  }
}
