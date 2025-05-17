import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';

class PopularFastFood extends StatelessWidget {
  final String image, name, restaurantName, price;
  const PopularFastFood({
    super.key,
    required this.image,
    required this.name,
    required this.restaurantName,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 153.w,
      height: 250.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FoodContainer(width: 153, height: 130),
          FText(
            text: name,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            alignment: MainAxisAlignment.start,
          ),
          5.verticalSpace,
          FText(
            text: restaurantName,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            alignment: MainAxisAlignment.start,
            color: kGreyColor,
          ),
          5.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FText(
                text: price,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                alignment: MainAxisAlignment.start,
                color: kTextColorDark,
              ),
              FoodContainer(
                width: 40,
                height: 40,
                borderRadius: 20,
                color: kPrimaryColor,
                child: Icon(Icons.add, color: kWhiteColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
