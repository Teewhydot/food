import 'package:flutter/material.dart';
import 'package:food/food/components/image.dart';

import '../../../../../generated/assets.dart';
import '../../../../components/scaffold.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FScaffold(
      body: Stack(
        children: [
          Center(
            child: FImage(
              imageType: FoodImageType.svg,
              imagePath: Assets.svgsLogo,
              width: 121,
              height: 60,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: FImage(
              imageType: FoodImageType.svg,
              imagePath: Assets.svgsSplashDesign,
              width: 295,
              height: 295,
            ),
          ),
        ],
      ),
    );
  }
}
