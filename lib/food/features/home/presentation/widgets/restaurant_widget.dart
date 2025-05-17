import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:food/generated/assets.dart';

class RestaurantWidget extends StatelessWidget {
  final String name, rating, distance, time;
  final List<String> categories;

  const RestaurantWidget({
    super.key,
    required this.name,
    required this.rating,
    required this.distance,
    required this.time,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FoodContainer(height: 137, width: 1.sw, child: Container()),
        8.verticalSpace,
        FText(
          text: name,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          alignment: MainAxisAlignment.start,
        ),
        4.verticalSpace,
        Row(
          children:
              categories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                return FText(
                  text:
                      index == categories.length - 1 ? category : "$category-",
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
                  text: rating,
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
                  text: distance,
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
                  text: time,
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
    );
  }
}

class SuggestedRestaurant extends StatelessWidget {
  final String name, rating;

  const SuggestedRestaurant({
    super.key,
    required this.name,
    required this.rating,
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
                  text: name,
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
                      text: rating,
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
    );
  }
}
