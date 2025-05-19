import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/app/init.dart';
import 'package:food/food/core/routes/getx_route_module.dart';
import 'package:food/food/core/theme/theme.dart';
import 'package:food/food/features/payments/presentation/screens/payment_method.dart';
import 'package:get/get.dart';

void main() {
  debugPaintSizeEnabled = true;
  AppConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: GetMaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        getPages: GetXRouteModule.routes,
        theme: FoodTheme.lightTheme,
        darkTheme: FoodTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: Scaffold(body: PaymentMethod()),
      ),
    );
  }
}
