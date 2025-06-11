import 'dart:convert';

import 'package:floor/floor.dart';

import '../../../../features/home/domain/entities/address.dart';

class AddressListConverter extends TypeConverter<List<AddressEntity>, String> {
  @override
  List<AddressEntity> decode(String databaseValue) {
    final List<dynamic> jsonList = jsonDecode(databaseValue);
    return jsonList.map((e) => AddressEntity.fromJson(e)).toList();
  }

  @override
  String encode(List<AddressEntity> value) {
    return jsonEncode(value.map((e) => e.toJson()).toList());
  }
}
