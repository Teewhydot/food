import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/helpers/extensions.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:food/generated/assets.dart';

import '../../domain/entities/restaurant.dart';

class RestaurantWidget extends StatelessWidget {
  final Restaurant restaurant;
  final Function onTap;

  const RestaurantWidget({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Column(
        children: [
          FoodContainer(height: 137, width: 1.sw, child: Container()),
          8.verticalSpace,
          FText(
            text: restaurant.name,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            alignment: MainAxisAlignment.start,
          ),
          4.verticalSpace,
          Row(
            children:
                restaurant.category.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value.category;
                  return FText(
                    text:
                        index == restaurant.category.length - 1
                            ? category
                            : "$category-",
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  );
                }).toList(),
          ),
          16.verticalSpace,
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
                    text: restaurant.rating.toString(),
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
                    text: restaurant.distance.toString(),
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
                    text: restaurant.deliveryTime.toString(),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextColorDark,
                  ),
                ],
              ),
            ],
          ),
          30.verticalSpace,
        ],
      ),
    );
  }
}

class SuggestedRestaurant extends StatelessWidget {
  final Restaurant restaurant;
  final Function onTap;

  const SuggestedRestaurant({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            FoodContainer(
              width: 60,
              height: 50,
              borderRadius: 10,
              child: Container(),
            ),
            10.horizontalSpace,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FText(
                  text: restaurant.name,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: kTextColorDark,
                ),
                4.verticalSpace,
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
                      text: restaurant.rating.toString(),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kTextColorDark,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        10.verticalSpace,
        Divider(color: kGreyColor, height: 1, thickness: 1),
      ],
    ).onTap(() {
      onTap();
    });
  }
}
