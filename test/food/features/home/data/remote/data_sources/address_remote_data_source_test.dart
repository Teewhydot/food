import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food/food/features/home/data/remote/data_sources/address_remote_data_source.dart';
import 'package:food/food/features/home/domain/entities/address.dart';

import 'address_remote_data_source_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  QuerySnapshot,
  QueryDocumentSnapshot,
  DocumentSnapshot,
])
void main() {
  late FirebaseAddressRemoteDataSource dataSource;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockQueryDocumentSnapshot;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockQueryDocumentSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

    dataSource = FirebaseAddressRemoteDataSource();
  });

  group('AddressRemoteDataSource', () {
    const userId = 'test_user_id';
    const addressId = 'test_address_id';

    final testAddressData = {
      'id': addressId,
      'userId': userId,
      'type': 'home',
      'name': 'Home',
      'street': '123 Main St',
      'city': 'Test City',
      'state': 'Test State',
      'country': 'Test Country',
      'postalCode': '12345',
      'latitude': 40.7128,
      'longitude': -74.0060,
      'isDefault': true,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };

    final testAddress = AddressEntity(
      id: addressId,
      street: '123 Main St',
      city: 'Test City',
      state: 'Test State',
      zipCode: '12345',
      address: '123 Main St',
      apartment: 'Apt 1',
      type: 'home',
      title: 'Home',
      latitude: 40.7128,
      longitude: -74.0060,
      isDefault: true,
    );

    group('getUserAddresses', () {
      test('should return list of addresses when successful', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('addresses'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.orderBy('createdAt', descending: true))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs)
            .thenReturn([mockQueryDocumentSnapshot]);
        when(mockQueryDocumentSnapshot.data())
            .thenReturn(testAddressData);

        // Act
        final result = await dataSource.getUserAddresses(userId);

        // Assert
        expect(result, isA<List<AddressEntity>>());
        expect(result.length, equals(1));
        expect(result.first.id, equals(addressId));
        expect(result.first.id, equals(addressId));
        verify(mockFirestore.collection('users')).called(1);
      });

      test('should throw exception when firestore throws error', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('addresses'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.orderBy('createdAt', descending: true))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.get())
            .thenThrow(Exception('Firestore error'));

        // Act & Assert
        expect(
          () => dataSource.getUserAddresses(userId),
          throwsException,
        );
      });
    });

    group('addAddress', () {
      test('should add address successfully', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('addresses'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.add(any))
            .thenAnswer((_) async => mockDocumentReference);
        when(mockDocumentReference.id).thenReturn(addressId);

        // Act
        final result = await dataSource.saveAddress(testAddress);

        // Assert
        expect(result, isA<AddressEntity>());
        expect(result.id, equals(addressId));
        verify(mockCollectionReference.add(any)).called(1);
      });
    });

    group('updateAddress', () {
      test('should update address successfully', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('addresses'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(addressId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.update(any))
            .thenAnswer((_) async => {});

        // Act
        final result = await dataSource.updateAddress(testAddress);

        // Assert
        expect(result, isA<AddressEntity>());
        expect(result.id, equals(addressId));
        verify(mockDocumentReference.update(any)).called(1);
      });
    });

    group('deleteAddress', () {
      test('should delete address successfully', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('addresses'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(addressId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.delete())
            .thenAnswer((_) async => {});

        // Act
        await dataSource.deleteAddress(addressId);

        // Assert
        verify(mockDocumentReference.delete()).called(1);
      });
    });

    group('setDefaultAddress', () {
      test('should set default address successfully', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('addresses'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.where('isDefault', isEqualTo: true))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs)
            .thenReturn([mockQueryDocumentSnapshot]);
        when(mockQueryDocumentSnapshot.reference)
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.update({'isDefault': false}))
            .thenAnswer((_) async => {});
        when(mockCollectionReference.doc(addressId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.update({'isDefault': true}))
            .thenAnswer((_) async => {});

        // Act
        await dataSource.setDefaultAddress(userId, addressId);

        // Assert
        verify(mockDocumentReference.update({'isDefault': false})).called(1);
        verify(mockDocumentReference.update({'isDefault': true})).called(1);
      });
    });

    group('getDefaultAddress', () {
      test('should return default address when found', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('addresses'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.where('isDefault', isEqualTo: true))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.limit(1))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs)
            .thenReturn([mockQueryDocumentSnapshot]);
        when(mockQueryDocumentSnapshot.data())
            .thenReturn(testAddressData);

        // Act
        final result = await dataSource.getDefaultAddress(userId);

        // Assert
        expect(result, isA<AddressEntity>());
        expect(result!.id, equals(addressId));
        expect(result.isDefault, isTrue);
      });

      test('should return null when no default address found', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('addresses'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.where('isDefault', isEqualTo: true))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.limit(1))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.get())
            .thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs)
            .thenReturn([]);

        // Act
        final result = await dataSource.getDefaultAddress(userId);

        // Assert
        expect(result, isNull);
      });
    });

    group('watchUserAddresses', () {
      test('should return stream of addresses', () async {
        // Arrange
        when(mockFirestore.collection('users'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.doc(userId))
            .thenReturn(mockDocumentReference);
        when(mockDocumentReference.collection('addresses'))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.orderBy('createdAt', descending: true))
            .thenReturn(mockCollectionReference);
        when(mockCollectionReference.snapshots())
            .thenAnswer((_) => Stream.value(mockQuerySnapshot));
        when(mockQuerySnapshot.docs)
            .thenReturn([mockQueryDocumentSnapshot]);
        when(mockQueryDocumentSnapshot.data())
            .thenReturn(testAddressData);

        // Act
        final stream = dataSource.watchUserAddresses(userId);

        // Assert
        expect(stream, isA<Stream<List<AddressEntity>>>());
        
        final addresses = await stream.first;
        expect(addresses.length, equals(1));
        expect(addresses.first.id, equals(addressId));
      });
    });
  });
}