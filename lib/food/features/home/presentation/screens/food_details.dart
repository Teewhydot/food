import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/food/features/home/presentation/widgets/details_skeleton_widget.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';

import '../../../../../generated/assets.dart';
import '../../../../components/image.dart';
import '../../../../core/theme/colors.dart';

class FoodDetails extends StatelessWidget {
  const FoodDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailsSkeletonWidget(
      hasBottomWidget: true,
      hasIndicator: false,
      isRestaurant: false,
      icon: Icons.favorite,
      bodyWidget: Column(
        children: [
          // Add your body widget here
          FText(
            text: "Burger Bistro",
            fontSize: 20,
            fontWeight: FontWeight.w700,
            alignment: MainAxisAlignment.start,
          ),
          7.verticalSpace,
          Row(
            children: [
              FoodContainer(
                width: 22,
                height: 22,
                borderRadius: 20,
                color: Colors.red,
              ),
              10.horizontalSpace,
              FText(
                text: "Rose Garden",
                fontSize: 16,
                fontWeight: FontWeight.w400,
                alignment: MainAxisAlignment.start,
              ),
            ],
          ),
          21.verticalSpace,
          Row(
            spacing: 24,
            children: [
              Row(
                children: [
                  FImage(
                    assetPath: Assets.svgsRating,
                    assetType: FoodAssetType.svg,
                    width: 20,
                    height: 20,
                  ),
                  4.horizontalSpace,
                  FText(
                    text: "4.9",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextColorDark,
                  ),
                ],
              ),
              Row(
                children: [
                  FImage(
                    assetPath: Assets.svgsTruck,
                    assetType: FoodAssetType.svg,
                    width: 20,
                    height: 20,
                  ),
                  4.horizontalSpace,
                  FText(
                    text: "20m",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextColorDark,
                  ),
                ],
              ),
              Row(
                children: [
                  FImage(
                    assetPath: Assets.svgsClock,
                    assetType: FoodAssetType.svg,
                    width: 20,
                    height: 20,
                  ),
                  4.horizontalSpace,
                  FText(
                    text: "10",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextColorDark,
                  ),
                ],
              ),
            ],
          ),
          21.verticalSpace,
          FWrapText(
            textAlign: TextAlign.start,
            color: kContainerColor,
            text:
                "Maecenas sed diam eget risus varius blandit sit amet non magna. Integer posuere erat a ante venenatis dapibus posuere velit aliquet.",
          ),
          20.verticalSpace,
          Row(
            children: [
              FText(
                text: "Size",
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kTextColorDark,
              ),
              10.horizontalSpace,
              CircleWidget(
                radius: 24,
                color: kContainerColor,
                child: FText(
                  text: "M",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kTextColorDark,
                ),
              ),
              10.horizontalSpace,
              CircleWidget(
                radius: 24,
                color: kContainerColor,
                child: FText(
                  text: "M",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kTextColorDark,
                ),
              ),
              10.horizontalSpace,
              CircleWidget(
                radius: 24,
                color: kContainerColor,
                child: FText(
                  text: "M",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kTextColorDark,
                ),
              ),
            ],
          ),

          // Add more widgets as needed
        ],
      ),
    );
  }
}
