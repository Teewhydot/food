import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';

import '../../features/home/manager/user_profile/user_profile_cubit.dart';

extension UserProfileExtension on BuildContext {
  /// Get the current user ID if available
  String? get currentUserId => watchUser()?.id;

  /// Get the current user name if available
  String? get currentUserName => watchUser()?.firstName;
  String? get currentUserSurname => watchUser()?.lastName;

  /// Get the current user email if available
  String? get currentUserEmail => watchUser()?.email;

  /// Check if user is logged in
  bool get isUserLoggedIn => watchUser() != null;

  /// Watch user profile changes (use in build method)
  UserProfileEntity? watchUser() {
    final state = watch<UserProfileCubit>().state;
    if (state.hasData) {
      return state.data;
    }
    return null;
  }
}
