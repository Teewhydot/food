import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../../../home/domain/entities/food.dart';
import '../../../home/presentation/widgets/circle_widget.dart';

class DFoodCartWidget extends StatelessWidget {
  final FoodEntity foodEntity;
  final int size;
  const DFoodCartWidget({
    super.key,
    required this.foodEntity,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FoodContainer(
          width: 140,
          height: 120,
          color: kContainerColor,
          child: Container(),
        ),
        20.horizontalSpace,
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FWrapText(
                text: foodEntity.name,
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: kWhiteColor,
              ),
              10.verticalSpace,
              FWrapText(
                text: "Total: ${foodEntity.price * foodEntity.quantity}",
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: kWhiteColor,
              ),
              17.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FText(
                    text: "$size``",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: kWhiteColor,
                  ),
                  Row(
                    children: [
                      CircleWidget(
                        radius: 12,
                        color: kGreyColor,
                        child: Icon(Ionicons.remove),
                        onTap: () {},
                      ),
                      17.horizontalSpace,
                      FText(
                        text: foodEntity.quantity.toString(),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: kWhiteColor,
                      ),
                      17.horizontalSpace,
                      CircleWidget(
                        radius: 12,
                        color: kGreyColor,
                        child: Icon(Ionicons.add),
                        onTap: () {
                          // Add logic to increase quantity
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ).paddingOnly(bottom: 20);
  }
}
