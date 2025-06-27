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

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
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
            'CREATE TABLE IF NOT EXISTS `user_profile` (`id` TEXT, `firstName` TEXT NOT NULL, `lastName` TEXT NOT NULL, `email` TEXT NOT NULL, `phoneNumber` TEXT NOT NULL, `bio` TEXT, `firstTimeLogin` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `addresses` (`id` TEXT NOT NULL, `street` TEXT NOT NULL, `city` TEXT NOT NULL, `state` TEXT NOT NULL, `zipCode` TEXT NOT NULL, `type` TEXT NOT NULL, `address` TEXT NOT NULL, `apartment` TEXT NOT NULL, PRIMARY KEY (`id`))');

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
                  'firstTimeLogin': item.firstTimeLogin ? 1 : 0
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
                  'firstTimeLogin': item.firstTimeLogin ? 1 : 0
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
