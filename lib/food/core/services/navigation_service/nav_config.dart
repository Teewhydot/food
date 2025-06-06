import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

abstract class NavigationService {
  Future<void> navigateTo(String routeName, {Object? arguments});
  Future<void> navigateAndReplace(String routeName, {Object? arguments});
  Future<void> navigateAndReplaceAll(String routeName, {Object? arguments});
  Future<void> navigateAndOffAll(
    String destinationRoute,
    conditionRoute, {
    Object? arguments,
  });
  Future<void> goBack();
  Future<void> goBackUntil(String routeName);
}

class GetxNavigationService implements NavigationService {
  @override
  Future<void> navigateTo(String routeName, {Object? arguments}) async {
    await Get.toNamed(routeName, arguments: arguments);
  }

  @override
  Future<void> navigateAndReplace(String routeName, {Object? arguments}) async {
    await Get.offNamed(routeName, arguments: arguments);
  }

  @override
  Future<void> navigateAndReplaceAll(
    String routeName, {
    Object? arguments,
  }) async {
    await Get.offAllNamed(routeName, arguments: arguments);
  }

  @override
  Future<void> goBack() async {
    Get.back();
  }

  @override
  Future<void> goBackUntil(String routeName) async {
    Get.until((route) => route.settings.name == routeName);
  }

  @override
  Future<void> navigateAndOffAll(
    String destinationRoute,
    conditionalRoute, {
    Object? arguments,
  }) async {
    await Get.offNamedUntil(
      destinationRoute,
      (route) => route.settings.name == conditionalRoute,
      arguments: arguments,
    );
  }
}

// Go router implementation

class GoRouterNavigationService implements NavigationService {
  final GoRouter _goRouter;

  GoRouterNavigationService(this._goRouter);
  @override
  Future<void> navigateTo(String routeName, {Object? arguments}) async {
    // Implement GoRouter navigation logic here
  }

  @override
  Future<void> navigateAndReplace(String routeName, {Object? arguments}) async {
    // Implement GoRouter navigation logic here
  }

  @override
  Future<void> navigateAndReplaceAll(
    String routeName, {
    Object? arguments,
  }) async {
    // Implement GoRouter navigation logic here
  }

  @override
  Future<void> goBack() async {
    // Implement GoRouter navigation logic here
    _goRouter.pop();
  }

  @override
  Future<void> goBackUntil(String routeName) async {
    // Implement GoRouter navigation logic here
  }

  @override
  Future<void> navigateAndOffAll(String routeName, sd, {Object? arguments}) {
    // TODO: implement navigateAndOffAll
    throw UnimplementedError();
  }
}
