import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:get/get.dart';

import '../../../../components/texts/texts.dart';
import '../../../../core/constants/app_constants.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      body: FoodContainer(width: 1.sw, height: 1.sh, color: kContainerColor),
      bottomWidget: FoodContainer(
        width: 1.sw,
        height: 377,
        color: kWhiteColor,
        child: Column(
          children: [
            CircleWidget(radius: 55, color: kContainerColor),
            10.verticalSpace,
            FText(
              text: "Robert Fox",
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
            5.verticalSpace,
            FText(
              text: "Calling...",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: kContainerColor,
            ),
            50.verticalSpace,
            Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -25,
                  left: 0,
                  right: 0,
                  child: AvatarGlow(
                    animate: false,
                    glowRadiusFactor: 0.4,
                    glowColor: kPrimaryColor.withOpacity(0.1),
                    child: CircleWidget(
                      color: kGoogleColor,
                      radius: 30,
                      child: Icon(Icons.call),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 30,
                  children: [
                    CircleWidget(
                      color: kGreyColor,
                      radius: 25,
                      child: Icon(Icons.mic_off_outlined),
                    ),

                    CircleWidget(
                      color: kGreyColor,
                      radius: 25,
                      child: Icon(Icons.volume_down),
                    ),
                  ],
                ).paddingSymmetric(horizontal: 52),
              ],
            ),
          ],
        ).paddingOnly(
          left: AppConstants.defaultPadding,
          right: AppConstants.defaultPadding,
          top: AppConstants.defaultPadding,
        ),
      ),
    );
  }
}
