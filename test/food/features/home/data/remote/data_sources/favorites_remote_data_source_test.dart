import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/food/features/home/data/remote/data_sources/favorites_remote_data_source.dart';
import 'package:food/food/features/home/domain/entities/food.dart';
import 'package:food/food/features/home/domain/entities/restaurant.dart';

import 'favorites_remote_data_source_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  QuerySnapshot,
  QueryDocumentSnapshot,
  DocumentSnapshot,
  WriteBatch,
])
void main() {
  late FirebaseFavoritesRemoteDataSource dataSource;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockQueryDocumentSnapshot;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;
  late MockWriteBatch mockBatch;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockQueryDocumentSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
    mockBatch = MockWriteBatch();

    dataSource = FirebaseFavoritesRemoteDataSource();
  });

  group('FavoritesRemoteDataSource', () {
    const userId = 'test_user_id';
    const foodId = 'test_food_id';
    const restaurantId = 'test_restaurant_id';

    final testFoodData = {
      'id': foodId,
      'name': 'Test Food',
      'description': 'Test Description',
      'price': 10.99,
      'imageUrl': 'https://example.com/food.jpg',
      'restaurantId': restaurantId,
      'category': 'fast_food',
      'rating': 4.5,
      'preparationTime': 30,
      'isAvailable': true,
      'ingredients': ['ingredient1', 'ingredient2'],
      'nutritionInfo': {'calories': 500, 'protein': 20},
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };

    final testRestaurantData = {
      'id': restaurantId,
      'name': 'Test Restaurant',
      'description': 'Test Description',
      'imageUrl': 'https://example.com/restaurant.jpg',
      'category': ['fast_food'],
      'rating': 4.5,
      'deliveryTime': 30,
      'deliveryFee': 2.99,
      'minimumOrder': 15.0,
      'isOpen': true,
      'latitude': 40.7128,
      'longitude': -74.0060,
      'address': '123 Main St',
      'phone': '+1234567890',
      'email': 'test@restaurant.com',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };

    group('getFavoriteFoods', () {
      test('should return list of favorite foods when successful', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('favorites'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc('foods'))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data())
            .thenReturn({'foodIds': [foodId]});

        when(mockFirestore.collection('foods'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.where('id', whereIn: [foodId]))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs)
            .thenReturn([mockQueryDocumentSnapshot]);
        when(mockQueryDocumentSnapshot.data())
            .thenReturn(testFoodData);

        // Act
        final result = await dataSource.getFavoriteFoods(userId);

        // Assert
        expect(result, isA<List<FoodEntity>>());
        expect(result.length, equals(1));
        expect(result.first.id, equals(foodId));
        verify(mockFirestore.collection('users')).called(1);
        verify(mockFirestore.collection('foods')).called(1);
      });

      test('should return empty list when no favorites found', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('favorites'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc('foods'))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(false);

        // Act
        final result = await dataSource.getFavoriteFoods(userId);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getFavoriteRestaurants', () {
      test('should return list of favorite restaurants when successful', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('favorites'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc('restaurants'))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data())
            .thenReturn({'restaurantIds': [restaurantId]});

        when(mockFirestore.collection('restaurants'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.where('id', whereIn: [restaurantId]))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs)
            .thenReturn([mockQueryDocumentSnapshot]);
        when(mockQueryDocumentSnapshot.data())
            .thenReturn(testRestaurantData);

        // Act
        final result = await dataSource.getFavoriteRestaurants(userId);

        // Assert
        expect(result, isA<List<Restaurant>>());
        expect(result.length, equals(1));
        expect(result.first.id, equals(restaurantId));
        verify(mockFirestore.collection('users')).called(1);
        verify(mockFirestore.collection('restaurants')).called(1);
      });
    });

    group('addFoodToFavorites', () {
      test('should add food to favorites successfully', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('favorites'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc('foods'))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.update(any))
            .thenAnswer((_) async => {});

        // Act
        await dataSource.addFoodToFavorites(userId, foodId);

        // Assert
        verify(mockDocumentReference.update(argThat(containsPair('foodIds', isA<FieldValue>())))).called(1);
      });
    });

    group('removeFoodFromFavorites', () {
      test('should remove food from favorites successfully', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('favorites'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc('foods'))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.update(any))
            .thenAnswer((_) async => {});

        // Act
        await dataSource.removeFoodFromFavorites(userId, foodId);

        // Assert
        verify(mockDocumentReference.update(argThat(containsPair('foodIds', isA<FieldValue>())))).called(1);
      });
    });

    group('addRestaurantToFavorites', () {
      test('should add restaurant to favorites successfully', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('favorites'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc('restaurants'))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.update(any))
            .thenAnswer((_) async => {});

        // Act
        await dataSource.addRestaurantToFavorites(userId, restaurantId);

        // Assert
        verify(mockDocumentReference.update(argThat(containsPair('restaurantIds', isA<FieldValue>())))).called(1);
      });
    });

    group('removeRestaurantFromFavorites', () {
      test('should remove restaurant from favorites successfully', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('favorites'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc('restaurants'))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.update(any))
            .thenAnswer((_) async => {});

        // Act
        await dataSource.removeRestaurantFromFavorites(userId, restaurantId);

        // Assert
        verify(mockDocumentReference.update(argThat(containsPair('restaurantIds', isA<FieldValue>())))).called(1);
      });
    });

    group('toggleFoodFavorite', () {
      test('should add food to favorites when not already favorite', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('favorites'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc('foods'))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data())
            .thenReturn({'foodIds': <String>[]});
        when(mockDocumentReference.update(any))
            .thenAnswer((_) async => {});

        // Act
        await dataSource.toggleFoodFavorite(userId, foodId);

        // Assert
        verify(mockDocumentReference.update(argThat(containsPair('foodIds', isA<FieldValue>())))).called(1);
      });

      test('should remove food from favorites when already favorite', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('favorites'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc('foods'))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data())
            .thenReturn({'foodIds': [foodId]});
        when(mockDocumentReference.update(any))
            .thenAnswer((_) async => {});

        // Act
        await dataSource.toggleFoodFavorite(userId, foodId);

        // Assert
        verify(mockDocumentReference.update(argThat(containsPair('foodIds', isA<FieldValue>())))).called(1);
      });
    });

    group('clearAllFavorites', () {
      test('should clear all favorites successfully', () async {
        // Arrange
        when(mockFirestore.batch()).thenReturn(mockBatch);
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('favorites'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc('foods'))
            .thenReturn(mockDocumentReference);
        when(mockCollectionReference.doc('restaurants'))
            .thenReturn(mockDocumentReference);
        when(mockBatch.update(any, any)).thenReturn(mockBatch);
        when(mockBatch.commit()).thenAnswer((_) async => []);

        // Act
        await dataSource.clearAllFavorites(userId);

        // Assert
        verify(mockBatch.update(any, argThat(containsPair('foodIds', [])))).called(1);
        verify(mockBatch.update(any, argThat(containsPair('restaurantIds', [])))).called(1);
        verify(mockBatch.commit()).called(1);
      });
    });

    group('watchFavoriteFoodIds', () {
      test('should return stream of favorite food IDs', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('favorites'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc('foods'))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.snapshots())
            .thenAnswer((_) => Stream.value(mockDocumentSnapshot));
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data())
            .thenReturn({'foodIds': [foodId]});

        // Act
        final stream = dataSource.watchFavoriteFoodIds(userId);

        // Assert
        expect(stream, isA<Stream<List<String>>>());
        
        final foodIds = await stream.first;
        expect(foodIds.length, equals(1));
        expect(foodIds.first, equals(foodId));
      });
    });

    group('watchFavoriteRestaurantIds', () {
      test('should return stream of favorite restaurant IDs', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('favorites'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc('restaurants'))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.snapshots())
            .thenAnswer((_) => Stream.value(mockDocumentSnapshot));
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data())
            .thenReturn({'restaurantIds': [restaurantId]});

        // Act
        final stream = dataSource.watchFavoriteRestaurantIds(userId);

        // Assert
        expect(stream, isA<Stream<List<String>>>());
        
        final restaurantIds = await stream.first;
        expect(restaurantIds.length, equals(1));
        expect(restaurantIds.first, equals(restaurantId));
      });
    });

    group('getFavoritesStats', () {
      test('should return favorites statistics', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('favorites'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc('foods'))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data())
            .thenReturn({'foodIds': [foodId]});

        when(mockCollectionReference.doc('restaurants'))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.get())
            .thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data())
            .thenReturn({'restaurantIds': [restaurantId]});

        // Act
        final result = await dataSource.getFavoritesStats(userId);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['totalFavoriteFoods'], equals(1));
        expect(result['totalFavoriteRestaurants'], equals(1));
        expect(result['totalFavorites'], equals(2));
      });
    });
  });
}