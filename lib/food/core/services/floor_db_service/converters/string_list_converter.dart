import 'dart:convert';
import 'package:floor/floor.dart';

class StringListConverter extends TypeConverter<List<String>, String> {
  @override
  List<String> decode(String databaseValue) {
    return List<String>.from(json.decode(databaseValue));
  }

  @override
  String encode(List<String> value) {
    return json.encode(value);
  }
}