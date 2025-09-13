import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../domain/entities/address.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressEntity>> getUserAddresses(String userId);
  Future<AddressEntity> saveAddress(AddressEntity address);
  Future<AddressEntity> updateAddress(AddressEntity address);
  Future<void> deleteAddress(String addressId);
  Future<AddressEntity?> getDefaultAddress(String userId);
  Future<void> setDefaultAddress(String userId, String addressId);
}

class FirebaseAddressRemoteDataSource implements AddressRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<List<AddressEntity>> getUserAddresses(String userId) async {
    final snapshot =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .orderBy('createdAt', descending: true)
            .get();

    return snapshot.docs.map((doc) => _addressFromFirestore(doc)).toList();
  }

  @override
  Future<AddressEntity> saveAddress(AddressEntity address) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Check if this is the first address, make it default
    final existingAddresses = await getUserAddresses(userId);
    final isDefault = existingAddresses.isEmpty || address.isDefault;

    final addressData = {
      'title': address.title,
      'fullAddress': address.fullAddress,
      'latitude': address.latitude,
      'longitude': address.longitude,
      'isDefault': isDefault,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .add(addressData);

    // If this is set as default, remove default flag from other addresses
    if (isDefault) {
      await _updateOtherAddressesDefault(userId, docRef.id, false);
    }

    return AddressEntity(
      id: docRef.id,
      street: address.street,
      city: address.city,
      state: address.state,
      zipCode: address.zipCode,
      address: address.address,
      apartment: address.apartment,
      type: address.type,
      title: address.title,
      latitude: address.latitude,
      longitude: address.longitude,
      isDefault: isDefault,
    );
  }

  @override
  Future<AddressEntity> updateAddress(AddressEntity address) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final addressData = {
      'title': address.title,
      'fullAddress': address.fullAddress,
      'latitude': address.latitude,
      'longitude': address.longitude,
      'isDefault': address.isDefault,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(address.id)
        .update(addressData);

    // If this is set as default, remove default flag from other addresses
    if (address.isDefault) {
      await _updateOtherAddressesDefault(userId, address.id, false);
    }

    return address;
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Check if this is the default address
    final addressDoc =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .doc(addressId)
            .get();

    final wasDefault = addressDoc.data()?['isDefault'] == true;

    // Delete the address
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(addressId)
        .delete();

    // If it was default, set another address as default
    if (wasDefault) {
      final remainingAddresses = await getUserAddresses(userId);
      if (remainingAddresses.isNotEmpty) {
        await setDefaultAddress(userId, remainingAddresses.first.id);
      }
    }
  }

  @override
  Future<AddressEntity?> getDefaultAddress(String userId) async {
    final snapshot =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .where('isDefault', isEqualTo: true)
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) return null;

    return _addressFromFirestore(snapshot.docs.first);
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    // Remove default flag from all addresses
    await _updateOtherAddressesDefault(userId, addressId, false);

    // Set the selected address as default
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(addressId)
        .update({'isDefault': true, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> _updateOtherAddressesDefault(
    String userId,
    String excludeAddressId,
    bool isDefault,
  ) async {
    final snapshot =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('addresses')
            .where('isDefault', isEqualTo: true)
            .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      if (doc.id != excludeAddressId) {
        batch.update(doc.reference, {
          'isDefault': isDefault,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
    await batch.commit();
  }

  AddressEntity _addressFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AddressEntity(
      id: doc.id,
      street: data['street'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      zipCode: data['zipCode'] ?? '',
      address: data['address'] ?? '',
      apartment: data['apartment'] ?? '',
      type: data['type'] ?? 'home',
      title: data['title'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      isDefault: data['isDefault'] ?? false,
    );
  }
}
