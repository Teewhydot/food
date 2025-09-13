import 'package:dartz/dartz.dart';
import 'package:food/food/features/home/data/local/data_source/address_local_data_source.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/utils/handle_exceptions.dart';
import '../../../../domain/failures/failures.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../remote/data_sources/address_remote_data_source.dart';

class AddressRepositoryImpl implements AddressRepository {
  final remoteDataSource = GetIt.instance<AddressRemoteDataSource>();
  final localDataSource = GetIt.instance<AddressLocalDataSource>();

  @override
  Stream<Either<Failure, List<AddressEntity>>> watchUserAddresses(
    String userId,
  ) {
    return remoteDataSource.watchUserAddresses(userId).map((addresses) {
      return Right<Failure, List<AddressEntity>>(addresses);
    }).onErrorReturnWith((error, stackTrace) {
      return Left(handleError(error));
    });
  }

  @override
  Future<Either<Failure, List<AddressEntity>>> getUserAddresses(String userId) {
    return handleExceptions(() async {
      try {
        // Try to get from remote first
        final remoteAddresses = await remoteDataSource.getUserAddresses(userId);

        // Save to local database
        for (final address in remoteAddresses) {
          await localDataSource.saveAddress(address);
        }

        return remoteAddresses;
      } catch (e) {
        // If remote fails, get from local
        return await localDataSource.loadAddresses();
      }
    });
  }

  @override
  Future<Either<Failure, AddressEntity>> saveAddress(AddressEntity address) {
    return handleExceptions(() async {
      // Save to remote first
      final savedAddress = await remoteDataSource.saveAddress(address);

      // Then save to local
      await localDataSource.saveAddress(savedAddress);

      return savedAddress;
    });
  }

  @override
  Future<Either<Failure, AddressEntity>> updateAddress(AddressEntity address) {
    return handleExceptions(() async {
      // Update remote first
      final updatedAddress = await remoteDataSource.updateAddress(address);

      // Then update local
      await localDataSource.updateAddress(updatedAddress);

      return updatedAddress;
    });
  }

  @override
  Future<Either<Failure, void>> deleteAddress(String addressId) {
    return handleExceptions(() async {
      // Delete from remote first
      await remoteDataSource.deleteAddress(addressId);

      // Get the address from local to delete it properly
      final addresses = await localDataSource.loadAddresses();
      final addressToDelete =
          addresses.where((addr) => addr.id == addressId).firstOrNull;
      if (addressToDelete != null) {
        await localDataSource.deleteAddress(addressToDelete);
      }
    });
  }

  @override
  Future<Either<Failure, AddressEntity?>> getDefaultAddress(String userId) {
    return handleExceptions(() async {
      return await remoteDataSource.getDefaultAddress(userId);
    });
  }

  @override
  Future<Either<Failure, void>> setDefaultAddress(
    String userId,
    String addressId,
  ) {
    return handleExceptions(() async {
      // Update remote first
      await remoteDataSource.setDefaultAddress(userId, addressId);
    });
  }

  @override
  Future<Either<Failure, void>> syncLocalAddresses(String userId) {
    return handleExceptions(() async {
      // Get local addresses that might not be synced
      final localAddresses = await localDataSource.loadAddresses();

      // Get remote addresses
      final remoteAddresses = await remoteDataSource.getUserAddresses(userId);
      final remoteIds = remoteAddresses.map((a) => a.id).toSet();

      // Find local addresses that are not in remote
      final unsyncedAddresses =
          localAddresses
              .where(
                (local) =>
                    !remoteIds.contains(local.id) &&
                    local.id.startsWith('local_'),
              )
              .toList();

      // Sync unsynced addresses to remote
      for (final address in unsyncedAddresses) {
        try {
          final syncedAddress = await remoteDataSource.saveAddress(address);
          // Remove the old local-only entry and add the synced one
          await localDataSource.deleteAddress(address);
          await localDataSource.saveAddress(syncedAddress);
        } catch (e) {
          // If sync fails, continue with next address
          continue;
        }
      }
    });
  }
}
