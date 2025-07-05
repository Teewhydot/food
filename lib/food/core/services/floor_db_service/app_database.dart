import 'dart:async';

import 'package:floor/floor.dart';
import 'package:food/food/core/services/floor_db_service/permission/entities/permission_entity.dart';
import 'package:food/food/core/services/floor_db_service/permission/permission_dao.dart';
import 'package:food/food/core/services/floor_db_service/user_profile/dao.dart';
import 'package:food/food/features/home/domain/entities/address.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../../../features/home/domain/entities/profile.dart';
import '../../../features/home/domain/entities/recent_keyword.dart';
import 'address/dao.dart';
import 'recent_keywords/dao.dart';
import 'restaurant/restaurant_dao.dart';
import 'restaurant/restaurant_entity.dart';
import 'food/food_dao.dart';
import 'food/food_entity.dart';
import 'order/order_dao.dart';
import 'order/order_entity.dart';
import 'converters/string_list_converter.dart';
import 'converters/order_items_converter.dart';
import 'converters/restaurant_category_converter.dart';
import 'chat/chat_dao.dart';
import 'chat/chat_entity.dart';
import 'message/message_dao.dart';
import 'message/message_entity.dart';

part 'app_database.g.dart'; // the generated code will be there

@Database(
  version: 3,
  entities: [
    RecentKeywordEntity,
    UserProfileEntity,
    AddressEntity,
    PermissionEntity,
    RestaurantFloorEntity,
    FoodFloorEntity,
    OrderFloorEntity,
    ChatFloorEntity,
    MessageFloorEntity,
  ],
)
@TypeConverters([StringListConverter, OrderItemsConverter, RestaurantCategoryConverter])
abstract class AppDatabase extends FloorDatabase {
  RecentKeywordsDao get recentsKeywordsDao;
  UserProfileDao get userProfileDao;
  AddressDao get addressDao;
  PermissionDao get permissionDao;
  RestaurantDao get restaurantDao;
  FoodDao get foodDao;
  OrderDao get orderDao;
  ChatDao get chatDao;
  MessageDao get messageDao;
}

// flutter packages pub run build_runner build
