import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:ionicons/ionicons.dart';

import '../../../home/presentation/widgets/circle_widget.dart';

class DFoodCartWidget extends StatelessWidget {
  final String imagePath, foodName, price, size, quantity, restaurantName;
  const DFoodCartWidget({
    super.key,
    this.imagePath = "",
    this.foodName = "Pixzza Carribean",
    this.price = "\$900",
    this.size = "14",
    this.quantity = "2",
    this.restaurantName = "Restaurant Name",
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
                text: foodName,
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: kWhiteColor,
              ),
              10.verticalSpace,
              FWrapText(
                text: "Total: $price",
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
                      ),
                      17.horizontalSpace,
                      FText(
                        text: quantity,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: kWhiteColor,
                      ),
                      17.horizontalSpace,
                      CircleWidget(
                        radius: 12,
                        color: kGreyColor,
                        child: Icon(Ionicons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
