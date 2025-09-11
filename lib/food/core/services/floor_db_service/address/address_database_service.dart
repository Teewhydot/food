import 'package:food/food/core/services/floor_db_service/app_database.dart';
import 'package:food/food/features/home/domain/entities/address.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:food/food/core/services/platform_database_path_service.dart';

class AddressDatabaseService {
  static final AddressDatabaseService _instance =
      AddressDatabaseService._internal();
  // path provider p
  AppDatabase? _database;
  factory AddressDatabaseService() => _instance;
  AddressDatabaseService._internal();

  Future<AppDatabase> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<AppDatabase> _initDatabase() async {
    final String dbPath;
    if (kIsWeb) {
      dbPath = PlatformDatabasePathService.getDbPath('addresses.db');
    } else {
      final documentsDir = await getApplicationDocumentsDirectory();
      dbPath = p.join(documentsDir.path, 'addresses.db');
    }
    return await $FloorAppDatabase.databaseBuilder(dbPath).build();
  }

  Future<void> insertAddress(AddressEntity address) async {
    final db = await database;
    await db.addressDao.insertAddress(address);
  }

  Future<List<AddressEntity>> getAllAddresses() async {
    final db = await database;
    return await db.addressDao.getAddresses();
  }

  Future<void> updateAddress(AddressEntity address) async {
    final db = await database;
    await db.addressDao.updateAddress(address);
  }

  Future<void> deleteAddress(AddressEntity address) async {
    final db = await database;
    await db.addressDao.deleteAddress(address);
  }

  Future<AddressEntity?> getDefaultAddress() async {
    final addresses = await getAllAddresses();
    return addresses.where((addr) => addr.isDefault).firstOrNull;
  }

  Future<void> setDefaultAddress(String addressId) async {
    final addresses = await getAllAddresses();
    
    // Remove default flag from all addresses
    for (final address in addresses) {
      if (address.isDefault) {
        final updatedAddress = AddressEntity(
          id: address.id,
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
          isDefault: false,
        );
        await updateAddress(updatedAddress);
      }
    }
    
    // Set the specified address as default
    final targetAddress = addresses.where((addr) => addr.id == addressId).firstOrNull;
    if (targetAddress != null) {
      final defaultAddress = AddressEntity(
        id: targetAddress.id,
        street: targetAddress.street,
        city: targetAddress.city,
        state: targetAddress.state,
        zipCode: targetAddress.zipCode,
        address: targetAddress.address,
        apartment: targetAddress.apartment,
        type: targetAddress.type,
        title: targetAddress.title,
        latitude: targetAddress.latitude,
        longitude: targetAddress.longitude,
        isDefault: true,
      );
      await updateAddress(defaultAddress);
    }
  }
}
