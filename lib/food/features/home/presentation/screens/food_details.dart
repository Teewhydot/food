import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/features/home/domain/entities/food.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/food/features/home/presentation/widgets/details_skeleton_widget.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:get_it/get_it.dart';

import '../../../../../generated/assets.dart';
import '../../../../components/image.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';

class FoodDetails extends StatelessWidget {
  final FoodEntity foodEntity;
  const FoodDetails({super.key, required this.foodEntity});

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();

    return DetailsSkeletonWidget(
      hasBottomWidget: true,
      hasIndicator: false,
      isRestaurant: false,
      icon: Icons.favorite,
      bodyWidget: Column(
        children: [
          // Add your body widget here
          FText(
            text: foodEntity.name,
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
                text: foodEntity.restaurant?.name ?? "Unknown Restaurant",
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
                    text: foodEntity.rating.toString(),
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
                    text:
                        foodEntity.restaurant?.distance.toString() ??
                        "Unknown Distance",
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
                    text:
                        foodEntity.restaurant?.deliveryTime.toString() ??
                        "Unknown Delivery Time",
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
            text: foodEntity.description,
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
