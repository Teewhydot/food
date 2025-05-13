import 'package:flutter/material.dart';
import 'package:food/food/core/theme/colors.dart';

class FoodTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
    brightness: Brightness.light,
    scaffoldBackgroundColor: kWhiteColor,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimaryColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: kBlackColor,
  );
}
