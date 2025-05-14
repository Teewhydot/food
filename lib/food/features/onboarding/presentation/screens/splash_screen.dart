import 'package:flutter/material.dart';
import 'package:food/food/components/image.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      nav.navigateTo(Routes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const FScaffold(
      body: Stack(
        children: [
          Center(
            child: FImage(
              imageType: FoodImageType.svg,
              assetPath: Assets.svgsLogo,
              width: 121,
              height: 60,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: FImage(
              imageType: FoodImageType.svg,
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
