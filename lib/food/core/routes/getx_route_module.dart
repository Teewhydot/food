import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/features/onboarding/presentation/screens/food_onboarding.dart';
import 'package:food/food/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

class GetXRouteModule {
  static final List<GetPage> routes = [
    GetPage(name: Routes.onboarding, page: () => FoodOnboarding()),
    // GetPage(name: '/matched', page: () => Matched()),
    GetPage(name: Routes.initial, page: () => SplashScreen()),
    // GetPage(name: '/login', page: () => Login()),
    // // Dynamic route example
    // GetPage(
    //   name: '/user/:id',
    //   page: () => UserDetailScreen(),
    // ),
  ];
}
