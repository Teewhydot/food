import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:food/food/components/scaffold.dart";
import "package:food/food/components/texts/texts.dart";
import "package:food/food/core/theme/colors.dart";
import "package:food/food/features/onboarding/presentation/widgets/food_container.dart";
import "package:get/get.dart";

import "../../../../core/constants/app_constants.dart";

class OnboardingWidget extends StatelessWidget {
  final String title, description, imagePath;
  final PageController controller;

  const OnboardingWidget({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      body: Column(
        children: [
          114.verticalSpace,
          FoodContainer(
            height: 292,
            width: 1.sw,
            hasUniquePadding: true,
            topPadding: 0,
            borderRadius: 12,
            leftPadding: 68,
            rightPadding: 68,
            child: Container(),
          ),
          67.verticalSpace,
          FText(
            text: title,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: kTextColorDark,
          ),
          24.verticalSpace,
          FWrapText(
            text: description,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: kGreyColor,
          ).paddingOnly(
            left: AppConstants.defaultPadding,
            right: AppConstants.defaultPadding,
          ),
        ],
      ),
    );
  }
}
