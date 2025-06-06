import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/app/bloc_providers.dart';
import 'package:food/food/app/init.dart';
import 'package:food/food/core/routes/getx_route_module.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/core/theme/theme.dart';
import 'package:get/get.dart';

void main() {
  AppConfig.init();
  runApp(MultiBlocProvider(providers: blocs, child: const MyApp()));
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
        initialRoute: Routes.initial,
      ),
    );
  }
}
