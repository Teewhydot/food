import 'package:dartz/dartz.dart';

import '../../../../domain/failures/failures.dart';
import '../entities/address.dart';

abstract class AddressRepository {
  Stream<Either<Failure, List<AddressEntity>>> watchUserAddresses(
    String userId,
  );
  Future<Either<Failure, List<AddressEntity>>> getUserAddresses(String userId);
  Future<Either<Failure, AddressEntity>> saveAddress(AddressEntity address);
  Future<Either<Failure, AddressEntity>> updateAddress(AddressEntity address);
  Future<Either<Failure, void>> deleteAddress(String addressId);
  Future<Either<Failure, AddressEntity?>> getDefaultAddress(String userId);
  Future<Either<Failure, void>> setDefaultAddress(
    String userId,
    String addressId,
  );
  Future<Either<Failure, void>> syncLocalAddresses(String userId);
}
