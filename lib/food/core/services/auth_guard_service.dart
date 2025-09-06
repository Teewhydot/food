import 'package:firebase_auth/firebase_auth.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/core/services/navigation_service/nav_config.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:get_it/get_it.dart';

class AuthGuardService {
  static final _firebase = FirebaseAuth.instance;
  static final _nav = GetIt.instance<NavigationService>();

  /// Check if user is authenticated
  static bool get isAuthenticated => _firebase.currentUser != null;

  /// Require authentication for protected routes
  static bool requireAuth({String? redirectTo}) {
    if (!isAuthenticated) {
      Logger.logWarning("Access denied - user not authenticated");
      _nav.navigateTo(redirectTo ?? Routes.login);
      return false;
    }
    return true;
  }

  /// Require no authentication (redirect authenticated users)
  static bool requireNoAuth({String? redirectTo}) {
    if (isAuthenticated) {
      Logger.logBasic("User already authenticated - redirecting");
      _nav.navigateTo(redirectTo ?? Routes.home);
      return false;
    }
    return true;
  }

  /// Protected routes that require authentication
  static final List<String> protectedRoutes = [
    Routes.home,
    Routes.search,
    Routes.food,
    Routes.foodDetails,
    Routes.restaurantDetails,
    Routes.cart,
    Routes.paymentMethod,
    Routes.addCard,
    Routes.statusScreen,
    Routes.tracking,
    Routes.callScreen,
    Routes.chatScreen,
    Routes.personalInfo,
    Routes.editProfile,
    Routes.address,
    Routes.addAddress,
    Routes.notifications,
    Routes.menu,
    Routes.settings,
    Routes.orderHistory,
  ];

  /// Public routes that don't require authentication
  static final List<String> publicRoutes = [
    Routes.initial,
    Routes.onboarding,
    Routes.login,
    Routes.register,
    Routes.forgotPassword,
    Routes.emailVerification,
    Routes.firebaseTest,
  ];

  /// Check if a route requires authentication
  static bool isProtectedRoute(String route) {
    return protectedRoutes.contains(route);
  }

  /// Check if a route is public
  static bool isPublicRoute(String route) {
    return publicRoutes.contains(route);
  }
}