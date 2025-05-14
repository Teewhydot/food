import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons/buttons.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:get/get.dart';

import '../../../../../generated/assets.dart';
import '../../../../components/image.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FoodContainer(
              height: 250,
              width: 206,
              borderRadius: 90,
              hasBorder: true,
              child: Container(),
            ),
            94.verticalSpace,
            FButton(
              buttonText: "ACCESS LOCATION",
              icon: FImage(
                imageType: FoodImageType.svg,
                assetPath: Assets.svgsLocationIcon,
                width: 32,
                height: 32,
              ),
            ),
            37.verticalSpace,
            FWrapText(
              text: "DFOOD WILL ACCESS YOUR LOCATION ONLY WHILE USING THE APP",
              color: kTextColorDark,
            ).paddingOnly(left: 26.w, right: 26.w),
          ],
        ),
      ),
    );
  }
}
