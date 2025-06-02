import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/helpers/extensions.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:get/get.dart';

class FoodWidget extends StatelessWidget {
  final String image, name, price, rating;
  final Function onTap;
  const FoodWidget({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130.w,
      height: 250.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              FoodContainer(width: 153, height: 130),
              FText(
                text: name,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                alignment: MainAxisAlignment.start,
              ),
              5.verticalSpace,
              FText(
                text: rating,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                alignment: MainAxisAlignment.start,
                color: kGreyColor,
              ),
              5.verticalSpace,
            ],
          ).onTap(() {
            onTap();
          }),
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
    ).paddingSymmetric(horizontal: 10);
  }
}
