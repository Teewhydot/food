import 'package:flutter/material.dart';
import 'package:food/food/core/services/auth_guard_service.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? priority = 1;

  @override
  RouteSettings? redirect(String? route) {
    if (route == null) return null;
    
    // Check if this is a protected route
    if (AuthGuardService.isProtectedRoute(route)) {
      if (!AuthGuardService.isAuthenticated) {
        // Redirect unauthenticated users to login
        return const RouteSettings(name: Routes.login);
      }
    }
    
    // Check if this is a public route but user is already authenticated
    if (route == Routes.login || route == Routes.register || route == Routes.onboarding) {
      if (AuthGuardService.isAuthenticated) {
        // Redirect authenticated users to home
        return const RouteSettings(name: Routes.home);
      }
    }
    
    return null; // No redirect needed
  }
}