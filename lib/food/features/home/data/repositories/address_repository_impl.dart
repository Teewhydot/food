import 'package:dartz/dartz.dart';
import '../../../../core/services/floor_db_service/address/address_database_service.dart';
import '../../../../core/utils/handle_exceptions.dart';
import '../../../../domain/failures/failures.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../remote/data_sources/address_remote_data_source.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;
  final AddressDatabaseService localDataSource;

  AddressRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<AddressEntity>>> getUserAddresses(String userId) {
    return handleExceptions(() async {
      try {
        // Try to get from remote first
        final remoteAddresses = await remoteDataSource.getUserAddresses(userId);
        
        // Save to local database
        for (final address in remoteAddresses) {
          await localDataSource.insertAddress(address);
        }
        
        return remoteAddresses;
      } catch (e) {
        // If remote fails, get from local
        return await localDataSource.getAllAddresses();
      }
    });
  }

  @override
  Future<Either<Failure, AddressEntity>> saveAddress(AddressEntity address) {
    return handleExceptions(() async {
      // Save to remote first
      final savedAddress = await remoteDataSource.saveAddress(address);
      
      // Then save to local
      await localDataSource.insertAddress(savedAddress);
      
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
      final addresses = await localDataSource.getAllAddresses();
      final addressToDelete = addresses.where((addr) => addr.id == addressId).firstOrNull;
      if (addressToDelete != null) {
        await localDataSource.deleteAddress(addressToDelete);
      }
    });
  }

  @override
  Future<Either<Failure, AddressEntity?>> getDefaultAddress(String userId) {
    return handleExceptions(() async {
      try {
        // Try remote first
        return await remoteDataSource.getDefaultAddress(userId);
      } catch (e) {
        // If remote fails, get from local
        return await localDataSource.getDefaultAddress();
      }
    });
  }

  @override
  Future<Either<Failure, void>> setDefaultAddress(String userId, String addressId) {
    return handleExceptions(() async {
      // Update remote first
      await remoteDataSource.setDefaultAddress(userId, addressId);
      
      // Then update local
      await localDataSource.setDefaultAddress(addressId);
    });
  }

  @override
  Stream<Either<Failure, List<AddressEntity>>> watchUserAddresses(String userId) {
    try {
      return remoteDataSource.watchUserAddresses(userId).map<Either<Failure, List<AddressEntity>>>((addresses) {
        // Update local database with the latest data
        for (final address in addresses) {
          localDataSource.insertAddress(address);
        }
        return Right(addresses);
      }).handleError((error) {
        return Stream.value(Left<Failure, List<AddressEntity>>(ServerFailure(failureMessage: error.toString())));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure(failureMessage: e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> syncLocalAddresses(String userId) {
    return handleExceptions(() async {
      // Get local addresses that might not be synced
      final localAddresses = await localDataSource.getAllAddresses();
      
      // Get remote addresses
      final remoteAddresses = await remoteDataSource.getUserAddresses(userId);
      final remoteIds = remoteAddresses.map((a) => a.id).toSet();
      
      // Find local addresses that are not in remote
      final unsyncedAddresses = localAddresses.where(
        (local) => !remoteIds.contains(local.id) && local.id.startsWith('local_')
      ).toList();
      
      // Sync unsynced addresses to remote
      for (final address in unsyncedAddresses) {
        try {
          final syncedAddress = await remoteDataSource.saveAddress(address);
          // Remove the old local-only entry and add the synced one
          await localDataSource.deleteAddress(address);
          await localDataSource.insertAddress(syncedAddress);
        } catch (e) {
          // If sync fails, continue with next address
          continue;
        }
      }
    });
  }
}