import 'package:flutter/material.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:food/food/core/utils/precache_assets.dart';
import 'package:food/food/features/home/manager/user_profile/enhanced_user_profile_cubit.dart';
import 'package:get_it/get_it.dart';

import '../../../../../generated/assets.dart';
import '../../../../components/scaffold.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/navigation_service/nav_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final nav = GetIt.instance<NavigationService>();
  void checkLoggedIn() async {
    final userProfileCubit = EnhancedUserProfileCubit();
    userProfileCubit.loadUserProfile();
    userProfileCubit.stream.listen((state) {
      if (state.hasData) {
        final userProfile = state.data;
        if (userProfile?.firstTimeLogin == true) {
          Logger.logSuccess("First time user - redirecting to onboarding");
          nav.navigateTo(Routes.onboarding);
        } else {
          Logger.logSuccess("Welcome back - redirecting to home");
          nav.navigateTo(Routes.home);
        }
      } else if (state is ErrorState) {
        Logger.logError("Authentication error: ${state.errorMessage}");
        // Check if it's an authentication error
        if (state.errorMessage?.contains('UserNotAuthenticatedException') ==
                true ||
            state.errorMessage?.contains('No authenticated user found') ==
                true) {
          Logger.logBasic("No authenticated user - redirecting to login");
          nav.navigateTo(Routes.login);
        } else {
          Logger.logBasic("General error - redirecting to onboarding");
          nav.navigateTo(Routes.onboarding);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// Precache svg files here
      precacheAllAssets(context).then((_) {
        checkLoggedIn();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const FScaffold(
      body: Stack(
        children: [
          Center(
            child: FImage(
              assetType: FoodAssetType.svg,
              assetPath: Assets.svgsLogo,
              width: 121,
              height: 60,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: FImage(
              assetType: FoodAssetType.svg,
              assetPath: Assets.svgsSplashDesign,
              width: 295,
              height: 295,
            ),
          ),
        ],
      ),
    );
  }
}
