// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  RecentKeywordsDao? _recentsKeywordsDaoInstance;

  UserProfileDao? _userProfileDaoInstance;

  AddressDao? _addressDaoInstance;

  PermissionDao? _permissionDaoInstance;

  RestaurantDao? _restaurantDaoInstance;

  FoodDao? _foodDaoInstance;

  OrderDao? _orderDaoInstance;

  ChatDao? _chatDaoInstance;

  MessageDao? _messageDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 3,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `recent_keywords` (`keyword` TEXT NOT NULL, PRIMARY KEY (`keyword`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `user_profile` (`id` TEXT, `firstName` TEXT NOT NULL, `lastName` TEXT NOT NULL, `email` TEXT NOT NULL, `phoneNumber` TEXT NOT NULL, `bio` TEXT, `firstTimeLogin` INTEGER NOT NULL, `profileImageUrl` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `addresses` (`id` TEXT NOT NULL, `street` TEXT NOT NULL, `city` TEXT NOT NULL, `state` TEXT NOT NULL, `zipCode` TEXT NOT NULL, `type` TEXT NOT NULL, `address` TEXT NOT NULL, `apartment` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `PermissionEntity` (`permissionName` TEXT NOT NULL, `isGranted` INTEGER NOT NULL, `lastUpdated` TEXT NOT NULL, PRIMARY KEY (`permissionName`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `restaurants` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `description` TEXT NOT NULL, `location` TEXT NOT NULL, `distance` REAL NOT NULL, `rating` REAL NOT NULL, `deliveryTime` TEXT NOT NULL, `deliveryFee` REAL NOT NULL, `imageUrl` TEXT NOT NULL, `category` TEXT NOT NULL, `isOpen` INTEGER NOT NULL, `latitude` REAL NOT NULL, `longitude` REAL NOT NULL, `lastUpdated` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `foods` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, `description` TEXT NOT NULL, `price` REAL NOT NULL, `rating` REAL NOT NULL, `imageUrl` TEXT NOT NULL, `category` TEXT NOT NULL, `restaurantId` TEXT NOT NULL, `restaurantName` TEXT NOT NULL, `ingredients` TEXT NOT NULL, `isAvailable` INTEGER NOT NULL, `preparationTime` TEXT NOT NULL, `calories` INTEGER NOT NULL, `quantity` INTEGER NOT NULL, `isVegetarian` INTEGER NOT NULL, `isVegan` INTEGER NOT NULL, `isGlutenFree` INTEGER NOT NULL, `lastUpdated` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `orders` (`id` TEXT NOT NULL, `userId` TEXT NOT NULL, `restaurantId` TEXT NOT NULL, `restaurantName` TEXT NOT NULL, `items` TEXT NOT NULL, `subtotal` REAL NOT NULL, `deliveryFee` REAL NOT NULL, `tax` REAL NOT NULL, `total` REAL NOT NULL, `deliveryAddress` TEXT NOT NULL, `paymentMethod` TEXT NOT NULL, `status` TEXT NOT NULL, `createdAt` INTEGER NOT NULL, `deliveredAt` INTEGER, `deliveryPersonName` TEXT, `deliveryPersonPhone` TEXT, `trackingUrl` TEXT, `notes` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `chats` (`id` TEXT NOT NULL, `senderID` TEXT NOT NULL, `receiverID` TEXT NOT NULL, `name` TEXT NOT NULL, `lastMessage` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, `lastMessageTime` INTEGER NOT NULL, `orderId` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `messages` (`id` TEXT NOT NULL, `chatId` TEXT NOT NULL, `content` TEXT NOT NULL, `senderId` TEXT NOT NULL, `receiverId` TEXT NOT NULL, `timestamp` INTEGER NOT NULL, `isRead` INTEGER NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  RecentKeywordsDao get recentsKeywordsDao {
    return _recentsKeywordsDaoInstance ??=
        _$RecentKeywordsDao(database, changeListener);
  }

  @override
  UserProfileDao get userProfileDao {
    return _userProfileDaoInstance ??=
        _$UserProfileDao(database, changeListener);
  }

  @override
  AddressDao get addressDao {
    return _addressDaoInstance ??= _$AddressDao(database, changeListener);
  }

  @override
  PermissionDao get permissionDao {
    return _permissionDaoInstance ??= _$PermissionDao(database, changeListener);
  }

  @override
  RestaurantDao get restaurantDao {
    return _restaurantDaoInstance ??= _$RestaurantDao(database, changeListener);
  }

  @override
  FoodDao get foodDao {
    return _foodDaoInstance ??= _$FoodDao(database, changeListener);
  }

  @override
  OrderDao get orderDao {
    return _orderDaoInstance ??= _$OrderDao(database, changeListener);
  }

  @override
  ChatDao get chatDao {
    return _chatDaoInstance ??= _$ChatDao(database, changeListener);
  }

  @override
  MessageDao get messageDao {
    return _messageDaoInstance ??= _$MessageDao(database, changeListener);
  }
}

class _$RecentKeywordsDao extends RecentKeywordsDao {
  _$RecentKeywordsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _recentKeywordEntityInsertionAdapter = InsertionAdapter(
            database,
            'recent_keywords',
            (RecentKeywordEntity item) =>
                <String, Object?>{'keyword': item.keyword}),
        _recentKeywordEntityDeletionAdapter = DeletionAdapter(
            database,
            'recent_keywords',
            ['keyword'],
            (RecentKeywordEntity item) =>
                <String, Object?>{'keyword': item.keyword});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<RecentKeywordEntity>
      _recentKeywordEntityInsertionAdapter;

  final DeletionAdapter<RecentKeywordEntity>
      _recentKeywordEntityDeletionAdapter;

  @override
  Future<List<RecentKeywordEntity>> getAllRecentKeywords() async {
    return _queryAdapter.queryList('SELECT * FROM recent_keywords',
        mapper: (Map<String, Object?> row) =>
            RecentKeywordEntity(row['keyword'] as String));
  }

  @override
  Future<void> clearRecentKeywords() async {
    await _queryAdapter.queryNoReturn('DELETE FROM recent_keywords');
  }

  @override
  Future<void> insertKeyword(RecentKeywordEntity keyword) async {
    await _recentKeywordEntityInsertionAdapter.insert(
        keyword, OnConflictStrategy.replace);
  }

  @override
  Future<void> deleteKeyword(RecentKeywordEntity keyword) async {
    await _recentKeywordEntityDeletionAdapter.delete(keyword);
  }
}

class _$UserProfileDao extends UserProfileDao {
  _$UserProfileDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _userProfileEntityInsertionAdapter = InsertionAdapter(
            database,
            'user_profile',
            (UserProfileEntity item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'email': item.email,
                  'phoneNumber': item.phoneNumber,
                  'bio': item.bio,
                  'firstTimeLogin': item.firstTimeLogin ? 1 : 0,
                  'profileImageUrl': item.profileImageUrl
                }),
        _userProfileEntityUpdateAdapter = UpdateAdapter(
            database,
            'user_profile',
            ['id'],
            (UserProfileEntity item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'email': item.email,
                  'phoneNumber': item.phoneNumber,
                  'bio': item.bio,
                  'firstTimeLogin': item.firstTimeLogin ? 1 : 0,
                  'profileImageUrl': item.profileImageUrl
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<UserProfileEntity> _userProfileEntityInsertionAdapter;

  final UpdateAdapter<UserProfileEntity> _userProfileEntityUpdateAdapter;

  @override
  Future<List<UserProfileEntity>> getUserProfile() async {
    return _queryAdapter.queryList('SELECT * FROM user_profile',
        mapper: (Map<String, Object?> row) => UserProfileEntity(
            id: row['id'] as String?,
            firstName: row['firstName'] as String,
            lastName: row['lastName'] as String,
            email: row['email'] as String,
            phoneNumber: row['phoneNumber'] as String,
            profileImageUrl: row['profileImageUrl'] as String?,
            bio: row['bio'] as String?,
            firstTimeLogin: (row['firstTimeLogin'] as int) != 0));
  }

  @override
  Future<void> deleteUserProfile() async {
    await _queryAdapter.queryNoReturn('DELETE FROM user_profile');
  }

  @override
  Future<void> saveUserProfile(UserProfileEntity userProfile) async {
    await _userProfileEntityInsertionAdapter.insert(
        userProfile, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateUserProfile(UserProfileEntity userProfile) async {
    await _userProfileEntityUpdateAdapter.update(
        userProfile, OnConflictStrategy.replace);
  }
}

class _$AddressDao extends AddressDao {
  _$AddressDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _addressEntityInsertionAdapter = InsertionAdapter(
            database,
            'addresses',
            (AddressEntity item) => <String, Object?>{
                  'id': item.id,
                  'street': item.street,
                  'city': item.city,
                  'state': item.state,
                  'zipCode': item.zipCode,
                  'type': item.type,
                  'address': item.address,
                  'apartment': item.apartment
                }),
        _addressEntityUpdateAdapter = UpdateAdapter(
            database,
            'addresses',
            ['id'],
            (AddressEntity item) => <String, Object?>{
                  'id': item.id,
                  'street': item.street,
                  'city': item.city,
                  'state': item.state,
                  'zipCode': item.zipCode,
                  'type': item.type,
                  'address': item.address,
                  'apartment': item.apartment
                }),
        _addressEntityDeletionAdapter = DeletionAdapter(
            database,
            'addresses',
            ['id'],
            (AddressEntity item) => <String, Object?>{
                  'id': item.id,
                  'street': item.street,
                  'city': item.city,
                  'state': item.state,
                  'zipCode': item.zipCode,
                  'type': item.type,
                  'address': item.address,
                  'apartment': item.apartment
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AddressEntity> _addressEntityInsertionAdapter;

  final UpdateAdapter<AddressEntity> _addressEntityUpdateAdapter;

  final DeletionAdapter<AddressEntity> _addressEntityDeletionAdapter;

  @override
  Future<List<AddressEntity>> getAddresses() async {
    return _queryAdapter.queryList('SELECT * FROM addresses',
        mapper: (Map<String, Object?> row) => AddressEntity(
            id: row['id'] as String,
            street: row['street'] as String,
            city: row['city'] as String,
            state: row['state'] as String,
            zipCode: row['zipCode'] as String,
            address: row['address'] as String,
            apartment: row['apartment'] as String,
            type: row['type'] as String));
  }

  @override
  Future<void> deleteAllAddresses() async {
    await _queryAdapter.queryNoReturn('DELETE FROM addresses');
  }

  @override
  Future<void> insertAddress(AddressEntity address) async {
    await _addressEntityInsertionAdapter.insert(
        address, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateAddress(AddressEntity updatedAddress) async {
    await _addressEntityUpdateAdapter.update(
        updatedAddress, OnConflictStrategy.replace);
  }

  @override
  Future<void> deleteAddress(AddressEntity address) async {
    await _addressEntityDeletionAdapter.delete(address);
  }
}

class _$PermissionDao extends PermissionDao {
  _$PermissionDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _permissionEntityInsertionAdapter = InsertionAdapter(
            database,
            'PermissionEntity',
            (PermissionEntity item) => <String, Object?>{
                  'permissionName': item.permissionName,
                  'isGranted': item.isGranted ? 1 : 0,
                  'lastUpdated': item.lastUpdated
                }),
        _permissionEntityUpdateAdapter = UpdateAdapter(
            database,
            'PermissionEntity',
            ['permissionName'],
            (PermissionEntity item) => <String, Object?>{
                  'permissionName': item.permissionName,
                  'isGranted': item.isGranted ? 1 : 0,
                  'lastUpdated': item.lastUpdated
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PermissionEntity> _permissionEntityInsertionAdapter;

  final UpdateAdapter<PermissionEntity> _permissionEntityUpdateAdapter;

  @override
  Future<PermissionEntity?> getPermissionByName(String name) async {
    return _queryAdapter.query(
        'SELECT * FROM PermissionEntity WHERE permissionName = ?1',
        mapper: (Map<String, Object?> row) => PermissionEntity(
            permissionName: row['permissionName'] as String,
            isGranted: (row['isGranted'] as int) != 0,
            lastUpdated: row['lastUpdated'] as String),
        arguments: [name]);
  }

  @override
  Future<List<PermissionEntity>> getAllPermissions() async {
    return _queryAdapter.queryList('SELECT * FROM PermissionEntity',
        mapper: (Map<String, Object?> row) => PermissionEntity(
            permissionName: row['permissionName'] as String,
            isGranted: (row['isGranted'] as int) != 0,
            lastUpdated: row['lastUpdated'] as String));
  }

  @override
  Future<void> deletePermission(String name) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM PermissionEntity WHERE permissionName = ?1',
        arguments: [name]);
  }

  @override
  Future<void> insertPermission(PermissionEntity permission) async {
    await _permissionEntityInsertionAdapter.insert(
        permission, OnConflictStrategy.abort);
  }

  @override
  Future<void> updatePermission(PermissionEntity permission) async {
    await _permissionEntityUpdateAdapter.update(
        permission, OnConflictStrategy.abort);
  }
}

class _$RestaurantDao extends RestaurantDao {
  _$RestaurantDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _restaurantFloorEntityInsertionAdapter = InsertionAdapter(
            database,
            'restaurants',
            (RestaurantFloorEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'description': item.description,
                  'location': item.location,
                  'distance': item.distance,
                  'rating': item.rating,
                  'deliveryTime': item.deliveryTime,
                  'deliveryFee': item.deliveryFee,
                  'imageUrl': item.imageUrl,
                  'category':
                      _restaurantCategoryConverter.encode(item.category),
                  'isOpen': item.isOpen ? 1 : 0,
                  'latitude': item.latitude,
                  'longitude': item.longitude,
                  'lastUpdated': item.lastUpdated
                }),
        _restaurantFloorEntityUpdateAdapter = UpdateAdapter(
            database,
            'restaurants',
            ['id'],
            (RestaurantFloorEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'description': item.description,
                  'location': item.location,
                  'distance': item.distance,
                  'rating': item.rating,
                  'deliveryTime': item.deliveryTime,
                  'deliveryFee': item.deliveryFee,
                  'imageUrl': item.imageUrl,
                  'category':
                      _restaurantCategoryConverter.encode(item.category),
                  'isOpen': item.isOpen ? 1 : 0,
                  'latitude': item.latitude,
                  'longitude': item.longitude,
                  'lastUpdated': item.lastUpdated
                }),
        _restaurantFloorEntityDeletionAdapter = DeletionAdapter(
            database,
            'restaurants',
            ['id'],
            (RestaurantFloorEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'description': item.description,
                  'location': item.location,
                  'distance': item.distance,
                  'rating': item.rating,
                  'deliveryTime': item.deliveryTime,
                  'deliveryFee': item.deliveryFee,
                  'imageUrl': item.imageUrl,
                  'category':
                      _restaurantCategoryConverter.encode(item.category),
                  'isOpen': item.isOpen ? 1 : 0,
                  'latitude': item.latitude,
                  'longitude': item.longitude,
                  'lastUpdated': item.lastUpdated
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<RestaurantFloorEntity>
      _restaurantFloorEntityInsertionAdapter;

  final UpdateAdapter<RestaurantFloorEntity>
      _restaurantFloorEntityUpdateAdapter;

  final DeletionAdapter<RestaurantFloorEntity>
      _restaurantFloorEntityDeletionAdapter;

  @override
  Future<List<RestaurantFloorEntity>> getAllRestaurants() async {
    return _queryAdapter.queryList('SELECT * FROM restaurants',
        mapper: (Map<String, Object?> row) => RestaurantFloorEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            description: row['description'] as String,
            location: row['location'] as String,
            distance: row['distance'] as double,
            rating: row['rating'] as double,
            deliveryTime: row['deliveryTime'] as String,
            deliveryFee: row['deliveryFee'] as double,
            imageUrl: row['imageUrl'] as String,
            category:
                _restaurantCategoryConverter.decode(row['category'] as String),
            isOpen: (row['isOpen'] as int) != 0,
            latitude: row['latitude'] as double,
            longitude: row['longitude'] as double,
            lastUpdated: row['lastUpdated'] as int));
  }

  @override
  Future<RestaurantFloorEntity?> getRestaurantById(String id) async {
    return _queryAdapter.query('SELECT * FROM restaurants WHERE id = ?1',
        mapper: (Map<String, Object?> row) => RestaurantFloorEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            description: row['description'] as String,
            location: row['location'] as String,
            distance: row['distance'] as double,
            rating: row['rating'] as double,
            deliveryTime: row['deliveryTime'] as String,
            deliveryFee: row['deliveryFee'] as double,
            imageUrl: row['imageUrl'] as String,
            category:
                _restaurantCategoryConverter.decode(row['category'] as String),
            isOpen: (row['isOpen'] as int) != 0,
            latitude: row['latitude'] as double,
            longitude: row['longitude'] as double,
            lastUpdated: row['lastUpdated'] as int),
        arguments: [id]);
  }

  @override
  Future<List<RestaurantFloorEntity>> getRestaurantsByCategory(
      String category) async {
    return _queryAdapter.queryList(
        'SELECT * FROM restaurants WHERE category = ?1',
        mapper: (Map<String, Object?> row) => RestaurantFloorEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            description: row['description'] as String,
            location: row['location'] as String,
            distance: row['distance'] as double,
            rating: row['rating'] as double,
            deliveryTime: row['deliveryTime'] as String,
            deliveryFee: row['deliveryFee'] as double,
            imageUrl: row['imageUrl'] as String,
            category:
                _restaurantCategoryConverter.decode(row['category'] as String),
            isOpen: (row['isOpen'] as int) != 0,
            latitude: row['latitude'] as double,
            longitude: row['longitude'] as double,
            lastUpdated: row['lastUpdated'] as int),
        arguments: [category]);
  }

  @override
  Future<List<RestaurantFloorEntity>> getPopularRestaurants(
      double minRating) async {
    return _queryAdapter.queryList(
        'SELECT * FROM restaurants WHERE rating >= ?1 ORDER BY rating DESC',
        mapper: (Map<String, Object?> row) => RestaurantFloorEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            description: row['description'] as String,
            location: row['location'] as String,
            distance: row['distance'] as double,
            rating: row['rating'] as double,
            deliveryTime: row['deliveryTime'] as String,
            deliveryFee: row['deliveryFee'] as double,
            imageUrl: row['imageUrl'] as String,
            category:
                _restaurantCategoryConverter.decode(row['category'] as String),
            isOpen: (row['isOpen'] as int) != 0,
            latitude: row['latitude'] as double,
            longitude: row['longitude'] as double,
            lastUpdated: row['lastUpdated'] as int),
        arguments: [minRating]);
  }

  @override
  Future<List<RestaurantFloorEntity>> searchRestaurants(String query) async {
    return _queryAdapter.queryList(
        'SELECT * FROM restaurants WHERE name LIKE ?1 OR description LIKE ?1 OR category LIKE ?1',
        mapper: (Map<String, Object?> row) => RestaurantFloorEntity(id: row['id'] as String, name: row['name'] as String, description: row['description'] as String, location: row['location'] as String, distance: row['distance'] as double, rating: row['rating'] as double, deliveryTime: row['deliveryTime'] as String, deliveryFee: row['deliveryFee'] as double, imageUrl: row['imageUrl'] as String, category: _restaurantCategoryConverter.decode(row['category'] as String), isOpen: (row['isOpen'] as int) != 0, latitude: row['latitude'] as double, longitude: row['longitude'] as double, lastUpdated: row['lastUpdated'] as int),
        arguments: [query]);
  }

  @override
  Future<void> deleteAllRestaurants() async {
    await _queryAdapter.queryNoReturn('DELETE FROM restaurants');
  }

  @override
  Future<void> deleteOldRestaurants(int timestamp) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM restaurants WHERE lastUpdated < ?1',
        arguments: [timestamp]);
  }

  @override
  Future<void> insertRestaurant(RestaurantFloorEntity restaurant) async {
    await _restaurantFloorEntityInsertionAdapter.insert(
        restaurant, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertRestaurants(
      List<RestaurantFloorEntity> restaurants) async {
    await _restaurantFloorEntityInsertionAdapter.insertList(
        restaurants, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateRestaurant(RestaurantFloorEntity restaurant) async {
    await _restaurantFloorEntityUpdateAdapter.update(
        restaurant, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteRestaurant(RestaurantFloorEntity restaurant) async {
    await _restaurantFloorEntityDeletionAdapter.delete(restaurant);
  }
}

class _$FoodDao extends FoodDao {
  _$FoodDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _foodFloorEntityInsertionAdapter = InsertionAdapter(
            database,
            'foods',
            (FoodFloorEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'description': item.description,
                  'price': item.price,
                  'rating': item.rating,
                  'imageUrl': item.imageUrl,
                  'category': item.category,
                  'restaurantId': item.restaurantId,
                  'restaurantName': item.restaurantName,
                  'ingredients': _stringListConverter.encode(item.ingredients),
                  'isAvailable': item.isAvailable ? 1 : 0,
                  'preparationTime': item.preparationTime,
                  'calories': item.calories,
                  'quantity': item.quantity,
                  'isVegetarian': item.isVegetarian ? 1 : 0,
                  'isVegan': item.isVegan ? 1 : 0,
                  'isGlutenFree': item.isGlutenFree ? 1 : 0,
                  'lastUpdated': item.lastUpdated
                }),
        _foodFloorEntityUpdateAdapter = UpdateAdapter(
            database,
            'foods',
            ['id'],
            (FoodFloorEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'description': item.description,
                  'price': item.price,
                  'rating': item.rating,
                  'imageUrl': item.imageUrl,
                  'category': item.category,
                  'restaurantId': item.restaurantId,
                  'restaurantName': item.restaurantName,
                  'ingredients': _stringListConverter.encode(item.ingredients),
                  'isAvailable': item.isAvailable ? 1 : 0,
                  'preparationTime': item.preparationTime,
                  'calories': item.calories,
                  'quantity': item.quantity,
                  'isVegetarian': item.isVegetarian ? 1 : 0,
                  'isVegan': item.isVegan ? 1 : 0,
                  'isGlutenFree': item.isGlutenFree ? 1 : 0,
                  'lastUpdated': item.lastUpdated
                }),
        _foodFloorEntityDeletionAdapter = DeletionAdapter(
            database,
            'foods',
            ['id'],
            (FoodFloorEntity item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'description': item.description,
                  'price': item.price,
                  'rating': item.rating,
                  'imageUrl': item.imageUrl,
                  'category': item.category,
                  'restaurantId': item.restaurantId,
                  'restaurantName': item.restaurantName,
                  'ingredients': _stringListConverter.encode(item.ingredients),
                  'isAvailable': item.isAvailable ? 1 : 0,
                  'preparationTime': item.preparationTime,
                  'calories': item.calories,
                  'quantity': item.quantity,
                  'isVegetarian': item.isVegetarian ? 1 : 0,
                  'isVegan': item.isVegan ? 1 : 0,
                  'isGlutenFree': item.isGlutenFree ? 1 : 0,
                  'lastUpdated': item.lastUpdated
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<FoodFloorEntity> _foodFloorEntityInsertionAdapter;

  final UpdateAdapter<FoodFloorEntity> _foodFloorEntityUpdateAdapter;

  final DeletionAdapter<FoodFloorEntity> _foodFloorEntityDeletionAdapter;

  @override
  Future<List<FoodFloorEntity>> getAllFoods() async {
    return _queryAdapter.queryList('SELECT * FROM foods',
        mapper: (Map<String, Object?> row) => FoodFloorEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            description: row['description'] as String,
            price: row['price'] as double,
            rating: row['rating'] as double,
            imageUrl: row['imageUrl'] as String,
            category: row['category'] as String,
            restaurantId: row['restaurantId'] as String,
            restaurantName: row['restaurantName'] as String,
            ingredients:
                _stringListConverter.decode(row['ingredients'] as String),
            isAvailable: (row['isAvailable'] as int) != 0,
            preparationTime: row['preparationTime'] as String,
            calories: row['calories'] as int,
            quantity: row['quantity'] as int,
            isVegetarian: (row['isVegetarian'] as int) != 0,
            isVegan: (row['isVegan'] as int) != 0,
            isGlutenFree: (row['isGlutenFree'] as int) != 0,
            lastUpdated: row['lastUpdated'] as int));
  }

  @override
  Future<FoodFloorEntity?> getFoodById(String id) async {
    return _queryAdapter.query('SELECT * FROM foods WHERE id = ?1',
        mapper: (Map<String, Object?> row) => FoodFloorEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            description: row['description'] as String,
            price: row['price'] as double,
            rating: row['rating'] as double,
            imageUrl: row['imageUrl'] as String,
            category: row['category'] as String,
            restaurantId: row['restaurantId'] as String,
            restaurantName: row['restaurantName'] as String,
            ingredients:
                _stringListConverter.decode(row['ingredients'] as String),
            isAvailable: (row['isAvailable'] as int) != 0,
            preparationTime: row['preparationTime'] as String,
            calories: row['calories'] as int,
            quantity: row['quantity'] as int,
            isVegetarian: (row['isVegetarian'] as int) != 0,
            isVegan: (row['isVegan'] as int) != 0,
            isGlutenFree: (row['isGlutenFree'] as int) != 0,
            lastUpdated: row['lastUpdated'] as int),
        arguments: [id]);
  }

  @override
  Future<List<FoodFloorEntity>> getFoodsByCategory(String category) async {
    return _queryAdapter.queryList('SELECT * FROM foods WHERE category = ?1',
        mapper: (Map<String, Object?> row) => FoodFloorEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            description: row['description'] as String,
            price: row['price'] as double,
            rating: row['rating'] as double,
            imageUrl: row['imageUrl'] as String,
            category: row['category'] as String,
            restaurantId: row['restaurantId'] as String,
            restaurantName: row['restaurantName'] as String,
            ingredients:
                _stringListConverter.decode(row['ingredients'] as String),
            isAvailable: (row['isAvailable'] as int) != 0,
            preparationTime: row['preparationTime'] as String,
            calories: row['calories'] as int,
            quantity: row['quantity'] as int,
            isVegetarian: (row['isVegetarian'] as int) != 0,
            isVegan: (row['isVegan'] as int) != 0,
            isGlutenFree: (row['isGlutenFree'] as int) != 0,
            lastUpdated: row['lastUpdated'] as int),
        arguments: [category]);
  }

  @override
  Future<List<FoodFloorEntity>> getFoodsByRestaurant(
      String restaurantId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM foods WHERE restaurantId = ?1',
        mapper: (Map<String, Object?> row) => FoodFloorEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            description: row['description'] as String,
            price: row['price'] as double,
            rating: row['rating'] as double,
            imageUrl: row['imageUrl'] as String,
            category: row['category'] as String,
            restaurantId: row['restaurantId'] as String,
            restaurantName: row['restaurantName'] as String,
            ingredients:
                _stringListConverter.decode(row['ingredients'] as String),
            isAvailable: (row['isAvailable'] as int) != 0,
            preparationTime: row['preparationTime'] as String,
            calories: row['calories'] as int,
            quantity: row['quantity'] as int,
            isVegetarian: (row['isVegetarian'] as int) != 0,
            isVegan: (row['isVegan'] as int) != 0,
            isGlutenFree: (row['isGlutenFree'] as int) != 0,
            lastUpdated: row['lastUpdated'] as int),
        arguments: [restaurantId]);
  }

  @override
  Future<List<FoodFloorEntity>> getPopularFoods(double minRating) async {
    return _queryAdapter.queryList(
        'SELECT * FROM foods WHERE rating >= ?1 ORDER BY rating DESC',
        mapper: (Map<String, Object?> row) => FoodFloorEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            description: row['description'] as String,
            price: row['price'] as double,
            rating: row['rating'] as double,
            imageUrl: row['imageUrl'] as String,
            category: row['category'] as String,
            restaurantId: row['restaurantId'] as String,
            restaurantName: row['restaurantName'] as String,
            ingredients:
                _stringListConverter.decode(row['ingredients'] as String),
            isAvailable: (row['isAvailable'] as int) != 0,
            preparationTime: row['preparationTime'] as String,
            calories: row['calories'] as int,
            quantity: row['quantity'] as int,
            isVegetarian: (row['isVegetarian'] as int) != 0,
            isVegan: (row['isVegan'] as int) != 0,
            isGlutenFree: (row['isGlutenFree'] as int) != 0,
            lastUpdated: row['lastUpdated'] as int),
        arguments: [minRating]);
  }

  @override
  Future<List<FoodFloorEntity>> searchFoods(String query) async {
    return _queryAdapter.queryList(
        'SELECT * FROM foods WHERE name LIKE ?1 OR description LIKE ?1 OR category LIKE ?1 OR restaurantName LIKE ?1',
        mapper: (Map<String, Object?> row) => FoodFloorEntity(id: row['id'] as String, name: row['name'] as String, description: row['description'] as String, price: row['price'] as double, rating: row['rating'] as double, imageUrl: row['imageUrl'] as String, category: row['category'] as String, restaurantId: row['restaurantId'] as String, restaurantName: row['restaurantName'] as String, ingredients: _stringListConverter.decode(row['ingredients'] as String), isAvailable: (row['isAvailable'] as int) != 0, preparationTime: row['preparationTime'] as String, calories: row['calories'] as int, quantity: row['quantity'] as int, isVegetarian: (row['isVegetarian'] as int) != 0, isVegan: (row['isVegan'] as int) != 0, isGlutenFree: (row['isGlutenFree'] as int) != 0, lastUpdated: row['lastUpdated'] as int),
        arguments: [query]);
  }

  @override
  Future<List<FoodFloorEntity>> getVegetarianFoods() async {
    return _queryAdapter.queryList('SELECT * FROM foods WHERE isVegetarian = 1',
        mapper: (Map<String, Object?> row) => FoodFloorEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            description: row['description'] as String,
            price: row['price'] as double,
            rating: row['rating'] as double,
            imageUrl: row['imageUrl'] as String,
            category: row['category'] as String,
            restaurantId: row['restaurantId'] as String,
            restaurantName: row['restaurantName'] as String,
            ingredients:
                _stringListConverter.decode(row['ingredients'] as String),
            isAvailable: (row['isAvailable'] as int) != 0,
            preparationTime: row['preparationTime'] as String,
            calories: row['calories'] as int,
            quantity: row['quantity'] as int,
            isVegetarian: (row['isVegetarian'] as int) != 0,
            isVegan: (row['isVegan'] as int) != 0,
            isGlutenFree: (row['isGlutenFree'] as int) != 0,
            lastUpdated: row['lastUpdated'] as int));
  }

  @override
  Future<List<FoodFloorEntity>> getVeganFoods() async {
    return _queryAdapter.queryList('SELECT * FROM foods WHERE isVegan = 1',
        mapper: (Map<String, Object?> row) => FoodFloorEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            description: row['description'] as String,
            price: row['price'] as double,
            rating: row['rating'] as double,
            imageUrl: row['imageUrl'] as String,
            category: row['category'] as String,
            restaurantId: row['restaurantId'] as String,
            restaurantName: row['restaurantName'] as String,
            ingredients:
                _stringListConverter.decode(row['ingredients'] as String),
            isAvailable: (row['isAvailable'] as int) != 0,
            preparationTime: row['preparationTime'] as String,
            calories: row['calories'] as int,
            quantity: row['quantity'] as int,
            isVegetarian: (row['isVegetarian'] as int) != 0,
            isVegan: (row['isVegan'] as int) != 0,
            isGlutenFree: (row['isGlutenFree'] as int) != 0,
            lastUpdated: row['lastUpdated'] as int));
  }

  @override
  Future<List<FoodFloorEntity>> getGlutenFreeFoods() async {
    return _queryAdapter.queryList('SELECT * FROM foods WHERE isGlutenFree = 1',
        mapper: (Map<String, Object?> row) => FoodFloorEntity(
            id: row['id'] as String,
            name: row['name'] as String,
            description: row['description'] as String,
            price: row['price'] as double,
            rating: row['rating'] as double,
            imageUrl: row['imageUrl'] as String,
            category: row['category'] as String,
            restaurantId: row['restaurantId'] as String,
            restaurantName: row['restaurantName'] as String,
            ingredients:
                _stringListConverter.decode(row['ingredients'] as String),
            isAvailable: (row['isAvailable'] as int) != 0,
            preparationTime: row['preparationTime'] as String,
            calories: row['calories'] as int,
            quantity: row['quantity'] as int,
            isVegetarian: (row['isVegetarian'] as int) != 0,
            isVegan: (row['isVegan'] as int) != 0,
            isGlutenFree: (row['isGlutenFree'] as int) != 0,
            lastUpdated: row['lastUpdated'] as int));
  }

  @override
  Future<void> deleteAllFoods() async {
    await _queryAdapter.queryNoReturn('DELETE FROM foods');
  }

  @override
  Future<void> deleteOldFoods(int timestamp) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM foods WHERE lastUpdated < ?1',
        arguments: [timestamp]);
  }

  @override
  Future<void> insertFood(FoodFloorEntity food) async {
    await _foodFloorEntityInsertionAdapter.insert(
        food, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertFoods(List<FoodFloorEntity> foods) async {
    await _foodFloorEntityInsertionAdapter.insertList(
        foods, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateFood(FoodFloorEntity food) async {
    await _foodFloorEntityUpdateAdapter.update(food, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteFood(FoodFloorEntity food) async {
    await _foodFloorEntityDeletionAdapter.delete(food);
  }
}

class _$OrderDao extends OrderDao {
  _$OrderDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _orderFloorEntityInsertionAdapter = InsertionAdapter(
            database,
            'orders',
            (OrderFloorEntity item) => <String, Object?>{
                  'id': item.id,
                  'userId': item.userId,
                  'restaurantId': item.restaurantId,
                  'restaurantName': item.restaurantName,
                  'items': item.items,
                  'subtotal': item.subtotal,
                  'deliveryFee': item.deliveryFee,
                  'tax': item.tax,
                  'total': item.total,
                  'deliveryAddress': item.deliveryAddress,
                  'paymentMethod': item.paymentMethod,
                  'status': item.status,
                  'createdAt': item.createdAt,
                  'deliveredAt': item.deliveredAt,
                  'deliveryPersonName': item.deliveryPersonName,
                  'deliveryPersonPhone': item.deliveryPersonPhone,
                  'trackingUrl': item.trackingUrl,
                  'notes': item.notes
                }),
        _orderFloorEntityUpdateAdapter = UpdateAdapter(
            database,
            'orders',
            ['id'],
            (OrderFloorEntity item) => <String, Object?>{
                  'id': item.id,
                  'userId': item.userId,
                  'restaurantId': item.restaurantId,
                  'restaurantName': item.restaurantName,
                  'items': item.items,
                  'subtotal': item.subtotal,
                  'deliveryFee': item.deliveryFee,
                  'tax': item.tax,
                  'total': item.total,
                  'deliveryAddress': item.deliveryAddress,
                  'paymentMethod': item.paymentMethod,
                  'status': item.status,
                  'createdAt': item.createdAt,
                  'deliveredAt': item.deliveredAt,
                  'deliveryPersonName': item.deliveryPersonName,
                  'deliveryPersonPhone': item.deliveryPersonPhone,
                  'trackingUrl': item.trackingUrl,
                  'notes': item.notes
                }),
        _orderFloorEntityDeletionAdapter = DeletionAdapter(
            database,
            'orders',
            ['id'],
            (OrderFloorEntity item) => <String, Object?>{
                  'id': item.id,
                  'userId': item.userId,
                  'restaurantId': item.restaurantId,
                  'restaurantName': item.restaurantName,
                  'items': item.items,
                  'subtotal': item.subtotal,
                  'deliveryFee': item.deliveryFee,
                  'tax': item.tax,
                  'total': item.total,
                  'deliveryAddress': item.deliveryAddress,
                  'paymentMethod': item.paymentMethod,
                  'status': item.status,
                  'createdAt': item.createdAt,
                  'deliveredAt': item.deliveredAt,
                  'deliveryPersonName': item.deliveryPersonName,
                  'deliveryPersonPhone': item.deliveryPersonPhone,
                  'trackingUrl': item.trackingUrl,
                  'notes': item.notes
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<OrderFloorEntity> _orderFloorEntityInsertionAdapter;

  final UpdateAdapter<OrderFloorEntity> _orderFloorEntityUpdateAdapter;

  final DeletionAdapter<OrderFloorEntity> _orderFloorEntityDeletionAdapter;

  @override
  Future<List<OrderFloorEntity>> getUserOrders(String userId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM orders WHERE userId = ?1 ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => OrderFloorEntity(
            id: row['id'] as String,
            userId: row['userId'] as String,
            restaurantId: row['restaurantId'] as String,
            restaurantName: row['restaurantName'] as String,
            items: row['items'] as String,
            subtotal: row['subtotal'] as double,
            deliveryFee: row['deliveryFee'] as double,
            tax: row['tax'] as double,
            total: row['total'] as double,
            deliveryAddress: row['deliveryAddress'] as String,
            paymentMethod: row['paymentMethod'] as String,
            status: row['status'] as String,
            createdAt: row['createdAt'] as int,
            deliveredAt: row['deliveredAt'] as int?,
            deliveryPersonName: row['deliveryPersonName'] as String?,
            deliveryPersonPhone: row['deliveryPersonPhone'] as String?,
            trackingUrl: row['trackingUrl'] as String?,
            notes: row['notes'] as String?),
        arguments: [userId]);
  }

  @override
  Future<OrderFloorEntity?> getOrderById(String id) async {
    return _queryAdapter.query('SELECT * FROM orders WHERE id = ?1',
        mapper: (Map<String, Object?> row) => OrderFloorEntity(
            id: row['id'] as String,
            userId: row['userId'] as String,
            restaurantId: row['restaurantId'] as String,
            restaurantName: row['restaurantName'] as String,
            items: row['items'] as String,
            subtotal: row['subtotal'] as double,
            deliveryFee: row['deliveryFee'] as double,
            tax: row['tax'] as double,
            total: row['total'] as double,
            deliveryAddress: row['deliveryAddress'] as String,
            paymentMethod: row['paymentMethod'] as String,
            status: row['status'] as String,
            createdAt: row['createdAt'] as int,
            deliveredAt: row['deliveredAt'] as int?,
            deliveryPersonName: row['deliveryPersonName'] as String?,
            deliveryPersonPhone: row['deliveryPersonPhone'] as String?,
            trackingUrl: row['trackingUrl'] as String?,
            notes: row['notes'] as String?),
        arguments: [id]);
  }

  @override
  Future<List<OrderFloorEntity>> getUserOrdersByStatus(
    String userId,
    String status,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM orders WHERE userId = ?1 AND status = ?2',
        mapper: (Map<String, Object?> row) => OrderFloorEntity(
            id: row['id'] as String,
            userId: row['userId'] as String,
            restaurantId: row['restaurantId'] as String,
            restaurantName: row['restaurantName'] as String,
            items: row['items'] as String,
            subtotal: row['subtotal'] as double,
            deliveryFee: row['deliveryFee'] as double,
            tax: row['tax'] as double,
            total: row['total'] as double,
            deliveryAddress: row['deliveryAddress'] as String,
            paymentMethod: row['paymentMethod'] as String,
            status: row['status'] as String,
            createdAt: row['createdAt'] as int,
            deliveredAt: row['deliveredAt'] as int?,
            deliveryPersonName: row['deliveryPersonName'] as String?,
            deliveryPersonPhone: row['deliveryPersonPhone'] as String?,
            trackingUrl: row['trackingUrl'] as String?,
            notes: row['notes'] as String?),
        arguments: [userId, status]);
  }

  @override
  Future<List<OrderFloorEntity>> getRecentOrders(String userId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM orders WHERE userId = ?1 ORDER BY createdAt DESC LIMIT 10',
        mapper: (Map<String, Object?> row) => OrderFloorEntity(id: row['id'] as String, userId: row['userId'] as String, restaurantId: row['restaurantId'] as String, restaurantName: row['restaurantName'] as String, items: row['items'] as String, subtotal: row['subtotal'] as double, deliveryFee: row['deliveryFee'] as double, tax: row['tax'] as double, total: row['total'] as double, deliveryAddress: row['deliveryAddress'] as String, paymentMethod: row['paymentMethod'] as String, status: row['status'] as String, createdAt: row['createdAt'] as int, deliveredAt: row['deliveredAt'] as int?, deliveryPersonName: row['deliveryPersonName'] as String?, deliveryPersonPhone: row['deliveryPersonPhone'] as String?, trackingUrl: row['trackingUrl'] as String?, notes: row['notes'] as String?),
        arguments: [userId]);
  }

  @override
  Future<List<OrderFloorEntity>> getActiveOrders(String userId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM orders WHERE userId = ?1 AND status IN (\"pending\", \"confirmed\", \"preparing\", \"onTheWay\")',
        mapper: (Map<String, Object?> row) => OrderFloorEntity(id: row['id'] as String, userId: row['userId'] as String, restaurantId: row['restaurantId'] as String, restaurantName: row['restaurantName'] as String, items: row['items'] as String, subtotal: row['subtotal'] as double, deliveryFee: row['deliveryFee'] as double, tax: row['tax'] as double, total: row['total'] as double, deliveryAddress: row['deliveryAddress'] as String, paymentMethod: row['paymentMethod'] as String, status: row['status'] as String, createdAt: row['createdAt'] as int, deliveredAt: row['deliveredAt'] as int?, deliveryPersonName: row['deliveryPersonName'] as String?, deliveryPersonPhone: row['deliveryPersonPhone'] as String?, trackingUrl: row['trackingUrl'] as String?, notes: row['notes'] as String?),
        arguments: [userId]);
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE orders SET status = ?2 WHERE id = ?1',
        arguments: [orderId, status]);
  }

  @override
  Future<void> deleteUserOrders(String userId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM orders WHERE userId = ?1',
        arguments: [userId]);
  }

  @override
  Future<void> deleteOldOrders(int timestamp) async {
    await _queryAdapter.queryNoReturn('DELETE FROM orders WHERE createdAt < ?1',
        arguments: [timestamp]);
  }

  @override
  Future<void> insertOrder(OrderFloorEntity order) async {
    await _orderFloorEntityInsertionAdapter.insert(
        order, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertOrders(List<OrderFloorEntity> orders) async {
    await _orderFloorEntityInsertionAdapter.insertList(
        orders, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateOrder(OrderFloorEntity order) async {
    await _orderFloorEntityUpdateAdapter.update(
        order, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteOrder(OrderFloorEntity order) async {
    await _orderFloorEntityDeletionAdapter.delete(order);
  }
}

class _$ChatDao extends ChatDao {
  _$ChatDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _chatFloorEntityInsertionAdapter = InsertionAdapter(
            database,
            'chats',
            (ChatFloorEntity item) => <String, Object?>{
                  'id': item.id,
                  'senderID': item.senderID,
                  'receiverID': item.receiverID,
                  'name': item.name,
                  'lastMessage': item.lastMessage,
                  'imageUrl': item.imageUrl,
                  'lastMessageTime': item.lastMessageTime,
                  'orderId': item.orderId
                }),
        _chatFloorEntityUpdateAdapter = UpdateAdapter(
            database,
            'chats',
            ['id'],
            (ChatFloorEntity item) => <String, Object?>{
                  'id': item.id,
                  'senderID': item.senderID,
                  'receiverID': item.receiverID,
                  'name': item.name,
                  'lastMessage': item.lastMessage,
                  'imageUrl': item.imageUrl,
                  'lastMessageTime': item.lastMessageTime,
                  'orderId': item.orderId
                }),
        _chatFloorEntityDeletionAdapter = DeletionAdapter(
            database,
            'chats',
            ['id'],
            (ChatFloorEntity item) => <String, Object?>{
                  'id': item.id,
                  'senderID': item.senderID,
                  'receiverID': item.receiverID,
                  'name': item.name,
                  'lastMessage': item.lastMessage,
                  'imageUrl': item.imageUrl,
                  'lastMessageTime': item.lastMessageTime,
                  'orderId': item.orderId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ChatFloorEntity> _chatFloorEntityInsertionAdapter;

  final UpdateAdapter<ChatFloorEntity> _chatFloorEntityUpdateAdapter;

  final DeletionAdapter<ChatFloorEntity> _chatFloorEntityDeletionAdapter;

  @override
  Future<List<ChatFloorEntity>> getUserChats(String userId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM chats WHERE senderID = ?1 OR receiverID = ?1 ORDER BY lastMessageTime DESC',
        mapper: (Map<String, Object?> row) => ChatFloorEntity(id: row['id'] as String, senderID: row['senderID'] as String, receiverID: row['receiverID'] as String, name: row['name'] as String, lastMessage: row['lastMessage'] as String, imageUrl: row['imageUrl'] as String, lastMessageTime: row['lastMessageTime'] as int, orderId: row['orderId'] as String),
        arguments: [userId]);
  }

  @override
  Future<ChatFloorEntity?> getChatById(String chatId) async {
    return _queryAdapter.query('SELECT * FROM chats WHERE id = ?1',
        mapper: (Map<String, Object?> row) => ChatFloorEntity(
            id: row['id'] as String,
            senderID: row['senderID'] as String,
            receiverID: row['receiverID'] as String,
            name: row['name'] as String,
            lastMessage: row['lastMessage'] as String,
            imageUrl: row['imageUrl'] as String,
            lastMessageTime: row['lastMessageTime'] as int,
            orderId: row['orderId'] as String),
        arguments: [chatId]);
  }

  @override
  Future<ChatFloorEntity?> getChatByOrderId(String orderId) async {
    return _queryAdapter.query('SELECT * FROM chats WHERE orderId = ?1',
        mapper: (Map<String, Object?> row) => ChatFloorEntity(
            id: row['id'] as String,
            senderID: row['senderID'] as String,
            receiverID: row['receiverID'] as String,
            name: row['name'] as String,
            lastMessage: row['lastMessage'] as String,
            imageUrl: row['imageUrl'] as String,
            lastMessageTime: row['lastMessageTime'] as int,
            orderId: row['orderId'] as String),
        arguments: [orderId]);
  }

  @override
  Future<void> updateLastMessage(
    String chatId,
    String lastMessage,
    int timestamp,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE chats SET lastMessage = ?2, lastMessageTime = ?3 WHERE id = ?1',
        arguments: [chatId, lastMessage, timestamp]);
  }

  @override
  Future<void> deleteAllChats() async {
    await _queryAdapter.queryNoReturn('DELETE FROM chats');
  }

  @override
  Future<void> insertChat(ChatFloorEntity chat) async {
    await _chatFloorEntityInsertionAdapter.insert(
        chat, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertChats(List<ChatFloorEntity> chats) async {
    await _chatFloorEntityInsertionAdapter.insertList(
        chats, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateChat(ChatFloorEntity chat) async {
    await _chatFloorEntityUpdateAdapter.update(chat, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteChat(ChatFloorEntity chat) async {
    await _chatFloorEntityDeletionAdapter.delete(chat);
  }
}

class _$MessageDao extends MessageDao {
  _$MessageDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _messageFloorEntityInsertionAdapter = InsertionAdapter(
            database,
            'messages',
            (MessageFloorEntity item) => <String, Object?>{
                  'id': item.id,
                  'chatId': item.chatId,
                  'content': item.content,
                  'senderId': item.senderId,
                  'receiverId': item.receiverId,
                  'timestamp': item.timestamp,
                  'isRead': item.isRead ? 1 : 0
                }),
        _messageFloorEntityUpdateAdapter = UpdateAdapter(
            database,
            'messages',
            ['id'],
            (MessageFloorEntity item) => <String, Object?>{
                  'id': item.id,
                  'chatId': item.chatId,
                  'content': item.content,
                  'senderId': item.senderId,
                  'receiverId': item.receiverId,
                  'timestamp': item.timestamp,
                  'isRead': item.isRead ? 1 : 0
                }),
        _messageFloorEntityDeletionAdapter = DeletionAdapter(
            database,
            'messages',
            ['id'],
            (MessageFloorEntity item) => <String, Object?>{
                  'id': item.id,
                  'chatId': item.chatId,
                  'content': item.content,
                  'senderId': item.senderId,
                  'receiverId': item.receiverId,
                  'timestamp': item.timestamp,
                  'isRead': item.isRead ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MessageFloorEntity>
      _messageFloorEntityInsertionAdapter;

  final UpdateAdapter<MessageFloorEntity> _messageFloorEntityUpdateAdapter;

  final DeletionAdapter<MessageFloorEntity> _messageFloorEntityDeletionAdapter;

  @override
  Future<List<MessageFloorEntity>> getChatMessages(String chatId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM messages WHERE chatId = ?1 ORDER BY timestamp ASC',
        mapper: (Map<String, Object?> row) => MessageFloorEntity(
            id: row['id'] as String,
            chatId: row['chatId'] as String,
            content: row['content'] as String,
            senderId: row['senderId'] as String,
            receiverId: row['receiverId'] as String,
            timestamp: row['timestamp'] as int,
            isRead: (row['isRead'] as int) != 0),
        arguments: [chatId]);
  }

  @override
  Future<MessageFloorEntity?> getMessageById(String messageId) async {
    return _queryAdapter.query('SELECT * FROM messages WHERE id = ?1',
        mapper: (Map<String, Object?> row) => MessageFloorEntity(
            id: row['id'] as String,
            chatId: row['chatId'] as String,
            content: row['content'] as String,
            senderId: row['senderId'] as String,
            receiverId: row['receiverId'] as String,
            timestamp: row['timestamp'] as int,
            isRead: (row['isRead'] as int) != 0),
        arguments: [messageId]);
  }

  @override
  Future<MessageFloorEntity?> getLastMessage(String chatId) async {
    return _queryAdapter.query(
        'SELECT * FROM messages WHERE chatId = ?1 ORDER BY timestamp DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => MessageFloorEntity(id: row['id'] as String, chatId: row['chatId'] as String, content: row['content'] as String, senderId: row['senderId'] as String, receiverId: row['receiverId'] as String, timestamp: row['timestamp'] as int, isRead: (row['isRead'] as int) != 0),
        arguments: [chatId]);
  }

  @override
  Future<List<MessageFloorEntity>> getUnreadMessages(String userId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM messages WHERE receiverId = ?1 AND isRead = 0',
        mapper: (Map<String, Object?> row) => MessageFloorEntity(
            id: row['id'] as String,
            chatId: row['chatId'] as String,
            content: row['content'] as String,
            senderId: row['senderId'] as String,
            receiverId: row['receiverId'] as String,
            timestamp: row['timestamp'] as int,
            isRead: (row['isRead'] as int) != 0),
        arguments: [userId]);
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE messages SET isRead = 1 WHERE id = ?1',
        arguments: [messageId]);
  }

  @override
  Future<void> markChatMessagesAsRead(
    String chatId,
    String userId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE messages SET isRead = 1 WHERE chatId = ?1 AND receiverId = ?2',
        arguments: [chatId, userId]);
  }

  @override
  Future<void> deleteChatMessages(String chatId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM messages WHERE chatId = ?1',
        arguments: [chatId]);
  }

  @override
  Future<void> deleteAllMessages() async {
    await _queryAdapter.queryNoReturn('DELETE FROM messages');
  }

  @override
  Future<void> insertMessage(MessageFloorEntity message) async {
    await _messageFloorEntityInsertionAdapter.insert(
        message, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertMessages(List<MessageFloorEntity> messages) async {
    await _messageFloorEntityInsertionAdapter.insertList(
        messages, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateMessage(MessageFloorEntity message) async {
    await _messageFloorEntityUpdateAdapter.update(
        message, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteMessage(MessageFloorEntity message) async {
    await _messageFloorEntityDeletionAdapter.delete(message);
  }
}

// ignore_for_file: unused_element
final _stringListConverter = StringListConverter();
final _orderItemsConverter = OrderItemsConverter();
final _restaurantCategoryConverter = RestaurantCategoryConverter();
