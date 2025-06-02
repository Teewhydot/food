import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../../../features/home/domain/entities/recent_keyword.dart';
import 'dao.dart';

part 'recent_keywords_database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [RecentKeyword])
abstract class AppDatabase extends FloorDatabase {
  RecentKeywordsDao get recentsKeywordsDao;
}

// flutter packages pub run build_runner build
