import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:food/food/features/home/data/remote/data_sources/user_profile_remote_data_source.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';

import 'user_profile_remote_data_source_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  FirebaseStorage,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  Reference,
  UploadTask,
  TaskSnapshot,
])
void main() {
  late FirebaseUserProfileRemoteDataSource dataSource;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseStorage mockStorage;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;
  late MockReference mockStorageReference;
  late MockUploadTask mockUploadTask;
  late MockTaskSnapshot mockTaskSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
    mockStorageReference = MockReference();
    mockUploadTask = MockUploadTask();
    mockTaskSnapshot = MockTaskSnapshot();

    dataSource = FirebaseUserProfileRemoteDataSource();
  });

  group('UserProfileRemoteDataSource', () {
    const userId = 'test_user_id';
    const imageUrl = 'https://example.com/image.jpg';
    
    final testProfileData = {
      'id': userId,
      'firstName': 'John',
      'lastName': 'Doe',
      'email': 'john.doe@example.com',
      'phoneNumber': '+1234567890',
      'profileImageUrl': imageUrl,
      'bio': 'Test bio',
      'firstTimeLogin': false,
    };

    final testProfile = UserProfileEntity(
      id: userId,
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      phoneNumber: '+1234567890',
      profileImageUrl: imageUrl,
      bio: 'Test bio',
      firstTimeLogin: false,
    );

    group('getUserProfile', () {
      test('should return user profile when found', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data())
            .thenReturn(testProfileData);

        // Act
        final result = await dataSource.getUserProfile(userId);

        // Assert
        expect(result, isA<UserProfileEntity>());
        expect(result!.id, equals(userId));
        expect(result.firstName, equals('John'));
        expect(result.lastName, equals('Doe'));
        verify(mockFirestore.collection('users')).called(1);
      });

      test('should return null when user profile not found', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(false);

        // Act
        final result = await dataSource.getUserProfile(userId);

        // Assert
        expect(result, isNull);
      });

      test('should throw exception when firestore throws error', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.get())
            .thenThrow(Exception('Firestore error'));

        // Act & Assert
        expect(
          () => dataSource.getUserProfile(userId),
          throwsException,
        );
      });
    });


    group('updateUserProfile', () {
      test('should update user profile successfully', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.update(any))
            .thenAnswer((_) async => {});

        // Act
        final result = await dataSource.updateUserProfile(testProfile);

        // Assert
        expect(result, isA<UserProfileEntity>());
        expect(result.id, equals(userId));
        verify(mockDocumentReference.update(any)).called(1);
      });
    });


    group('uploadProfileImage', () {
      test('should upload profile image successfully', () async {
        // Arrange
        final imageFile = File('test_image.jpg');
        when(mockStorage.ref('profile_images/$userId'))
            .thenReturn(mockStorageReference);
        when(mockStorageReference.putFile(imageFile))
            .thenReturn(mockUploadTask);
        when(mockUploadTask.whenComplete(any))
            .thenAnswer((_) => Future.value(mockTaskSnapshot));
        when(mockStorageReference.getDownloadURL())
            .thenAnswer((_) async => imageUrl);

        // Act
        final result = await dataSource.uploadProfileImage(userId, imageFile);

        // Assert
        expect(result, equals(imageUrl));
        verify(mockStorageReference.putFile(imageFile)).called(1);
      });
    });


    group('deleteProfileImage', () {
      test('should delete profile image successfully', () async {
        // Arrange
        when(mockStorage.ref('profile_images/$userId'))
            .thenReturn(mockStorageReference);
        when(mockStorageReference.delete())
            .thenAnswer((_) async => {});

        // Act
        await dataSource.deleteProfileImage(userId);

        // Assert
        verify(mockStorageReference.delete()).called(1);
      });
    });


    group('watchUserProfile', () {
      test('should return stream of user profile', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.snapshots())
            .thenAnswer((_) => Stream.value(mockDocumentSnapshot));
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data())
            .thenReturn(testProfileData);

        // Act
        final stream = dataSource.watchUserProfile(userId);

        // Assert
        expect(stream, isA<Stream<UserProfileEntity?>>());
        
        final profile = await stream.first;
        expect(profile, isA<UserProfileEntity>());
        expect(profile!.id, equals(userId));
      });

      test('should return null in stream when profile does not exist', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.snapshots())
            .thenAnswer((_) => Stream.value(mockDocumentSnapshot));
        when(mockDocumentSnapshot.exists).thenReturn(false);

        // Act
        final stream = dataSource.watchUserProfile(userId);

        // Assert
        expect(stream, isA<Stream<UserProfileEntity?>>());
        
        final profile = await stream.first;
        expect(profile, isNull);
      });
    });
  });
}