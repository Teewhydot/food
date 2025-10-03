import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';
import 'package:food/food/features/home/manager/user_profile/enhanced_user_profile_cubit.dart';

extension UserProfileExtension on BuildContext {
  /// Get the current user ID if available (for use in build methods)
  String? get currentUserId => watchUser()?.id;

  /// Get the current user ID without listening (for use in event handlers)
  String? get readCurrentUserId => readUser()?.id;

  /// Get the current user name if available (for use in build methods)
  String? get currentUserName => watchUser()?.firstName;
  String? get currentUserSurname => watchUser()?.lastName;

  /// Get the current user email if available (for use in build methods)
  String? get currentUserEmail => watchUser()?.email;

  /// Check if user is logged in (for use in build methods)
  bool get isUserLoggedIn => watchUser() != null;

  /// Watch user profile changes (use in build method)
  UserProfileEntity? watchUser() {
    final state = watch<UserProfileCubit>().state;
    if (state.hasData) {
      return state.data;
    }
    return null;
  }

  /// Read user profile once (use outside build method)
  UserProfileEntity? readUser() {
    final state = read<UserProfileCubit>().state;
    if (state.hasData) {
      print("Reading user: ${state.data}");
      return state.data;
    }
    return null;
  }
}
