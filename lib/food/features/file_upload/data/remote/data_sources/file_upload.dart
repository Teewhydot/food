import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:food/food/features/file_upload/domain/entities/uploaded_file_entity.dart';

abstract class FileUploadDataSource {
  Future<UploadedFileEntity> uploadFile({
    required String userId,
    required File file,
  });

  Future<void> deleteFile({required String fileId});

  Future<String> generateUrl({
    required String filePath,
    List<String>? transformations,
  });
}

class FirebaseFileUploadImpl implements FileUploadDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  @override
  Future<void> deleteFile({required String fileId}) {
    // TODO: implement deleteFile
    throw UnimplementedError();
  }

  @override
  Future<String> generateUrl({
    required String filePath,
    List<String>? transformations,
  }) {
    // TODO: implement generateUrl
    throw UnimplementedError();
  }

  @override
  Future<UploadedFileEntity> uploadFile({
    required String userId,
    required File file,
  }) async {
    try {
      // Create a reference to the location you want to upload to in firebase
      final storageRef = _storage
          .ref()
          .child('profile_images')
          .child('$userId.jpg');

      // Upload the file
      final uploadTask = await storageRef.putFile(file);

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

      return UploadedFileEntity(url: downloadUrl, uploadedAt: DateTime.now());
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }
}
