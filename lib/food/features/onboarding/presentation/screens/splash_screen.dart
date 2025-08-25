import 'package:flutter/material.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/utils/precache_assets.dart';
import 'package:get_it/get_it.dart';

import '../../../../../generated/assets.dart';
import '../../../../components/scaffold.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../home/manager/user_profile/user_profile_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final nav = GetIt.instance<NavigationService>();
  void checkLoggedIn() async {
    final userProfileCubit = UserProfileCubit();
    userProfileCubit.loadUserProfile();
    userProfileCubit.stream.listen((state) {
      if (state.hasData) {
        final userProfile = state.data;
        if (userProfile?.firstTimeLogin == true) {
          Logger.logSuccess("Welcome to Dfood");
          nav.navigateTo(Routes.onboarding);
        } else {
          Logger.logSuccess("Welcome back");
          nav.navigateTo(Routes.home);
        }
      } else if (state is ErrorState) {
        nav.navigateTo(Routes.onboarding);
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
