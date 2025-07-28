import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/core/helpers/extensions.dart';

import '../../../../../generated/assets.dart';
import '../../../../components/image.dart';
import '../../../../components/texts.dart';
import '../../../../core/theme/colors.dart';

class SectionHead extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? action;
  final bool isActionVisible;
  const SectionHead({
    super.key,
    this.title = "All categories",
    this.actionText = "See All",
    this.action,
    this.isActionVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FText(
          text: title,
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: kTextColorDark,
        ),
        if (isActionVisible)
          Row(
            children: [
              FText(
                text: actionText,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: kTextColorDark,
              ),
              8.horizontalSpace,
              FImage(
                assetPath: Assets.svgsArrowRight,
                assetType: FoodAssetType.svg,
                width: 10,
                height: 10,
              ),
            ],
          ).onTap(() {
            if (action != null) {
              action!();
            }
          }),
      ],
    );
  }
}
