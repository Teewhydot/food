import 'dart:async';

import 'package:floor/floor.dart';
import 'package:food/food/core/services/floor_db_service/user_profile/dao.dart';
import 'package:food/food/features/home/domain/entities/address.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../../features/home/domain/entities/profile.dart';
import '../../../features/home/domain/entities/recent_keyword.dart';
import 'address/dao.dart';
import 'recent_keywords/dao.dart';

part 'app_database.g.dart'; // the generated code will be there

@Database(
  version: 1,
  entities: [RecentKeywordEntity, UserProfileEntity, AddressEntity],
)
abstract class AppDatabase extends FloorDatabase {
  RecentKeywordsDao get recentsKeywordsDao;
  UserProfileDao get userProfileDao;
  AddressDao get addressDao;
}

// flutter packages pub run build_runner build
