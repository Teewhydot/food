import 'package:dartz/dartz.dart';
import '../../../../domain/failures/failures.dart';
import '../entities/address.dart';
import '../repositories/address_repository.dart';

class AddressUseCase {
  final AddressRepository repository;

  AddressUseCase(this.repository);

  Future<Either<Failure, List<AddressEntity>>> getUserAddresses(String userId) {
    return repository.getUserAddresses(userId);
  }

  Future<Either<Failure, AddressEntity>> saveAddress(AddressEntity address) {
    if (!_validateAddress(address)) {
      return Future.value(Left(UnknownFailure(
        failureMessage: 'Invalid address data'
      )));
    }
    return repository.saveAddress(address);
  }

  Future<Either<Failure, AddressEntity>> updateAddress(AddressEntity address) {
    if (!_validateAddress(address)) {
      return Future.value(Left(UnknownFailure(
        failureMessage: 'Invalid address data'
      )));
    }
    return repository.updateAddress(address);
  }

  Future<Either<Failure, void>> deleteAddress(String addressId) {
    if (addressId.isEmpty) {
      return Future.value(Left(UnknownFailure(
        failureMessage: 'Address ID cannot be empty'
      )));
    }
    return repository.deleteAddress(addressId);
  }

  Future<Either<Failure, AddressEntity?>> getDefaultAddress(String userId) {
    return repository.getDefaultAddress(userId);
  }

  Future<Either<Failure, void>> setDefaultAddress(String userId, String addressId) {
    if (userId.isEmpty || addressId.isEmpty) {
      return Future.value(Left(UnknownFailure(
        failureMessage: 'User ID and Address ID cannot be empty'
      )));
    }
    return repository.setDefaultAddress(userId, addressId);
  }

  Stream<Either<Failure, List<AddressEntity>>> watchUserAddresses(String userId) {
    return repository.watchUserAddresses(userId);
  }

  Future<Either<Failure, void>> syncLocalAddresses(String userId) {
    return repository.syncLocalAddresses(userId);
  }

  bool _validateAddress(AddressEntity address) {
    return (address.title?.trim().isNotEmpty ?? false) &&
           address.fullAddress.trim().isNotEmpty &&
           (address.latitude != null && address.latitude != 0.0) &&
           (address.longitude != null && address.longitude != 0.0);
  }

  Future<Either<Failure, AddressEntity>> createHomeAddress({
    required String street,
    required String city,
    required String state,
    required String zipCode,
    required String address,
    required String apartment,
    required double latitude,
    required double longitude,
    bool isDefault = false,
  }) {
    final addressEntity = AddressEntity(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}', // Temporary ID
      street: street,
      city: city,
      state: state,
      zipCode: zipCode,
      address: address,
      apartment: apartment,
      type: 'home',
      title: 'Home',
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );
    
    return saveAddress(addressEntity);
  }

  Future<Either<Failure, AddressEntity>> createWorkAddress({
    required String street,
    required String city,
    required String state,
    required String zipCode,
    required String address,
    required String apartment,
    required double latitude,
    required double longitude,
    bool isDefault = false,
  }) {
    final addressEntity = AddressEntity(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}', // Temporary ID
      street: street,
      city: city,
      state: state,
      zipCode: zipCode,
      address: address,
      apartment: apartment,
      type: 'work',
      title: 'Work',
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );
    
    return saveAddress(addressEntity);
  }

  Future<Either<Failure, AddressEntity>> createCustomAddress({
    required String title,
    required String street,
    required String city,
    required String state,
    required String zipCode,
    required String address,
    required String apartment,
    required double latitude,
    required double longitude,
    String type = 'custom',
    bool isDefault = false,
  }) {
    final addressEntity = AddressEntity(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}', // Temporary ID
      street: street,
      city: city,
      state: state,
      zipCode: zipCode,
      address: address,
      apartment: apartment,
      type: type,
      title: title,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
    );
    
    return saveAddress(addressEntity);
  }
}