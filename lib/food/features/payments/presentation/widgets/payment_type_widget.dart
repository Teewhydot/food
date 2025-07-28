import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';

class PaymentTypeWidget extends StatelessWidget {
  final String image;
  final String title;
  final bool isSelected;
  final double width, height;
  const PaymentTypeWidget({
    super.key,
    required this.image,
    required this.title,
    required this.width,
    required this.height,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FoodContainer(
          height: 82.h,
          width: 85.w,
          hasBorder: isSelected,
          borderWidth: 1,
          borderColor: kPrimaryColor,
          color: isSelected ? kWhiteColor : kGreyColor,
          child: SizedBox(
            width: width,
            height: height,
            child: FImage(
              assetPath: image,
              width: width,
              height: height,
              assetType: FoodAssetType.svg,
            ),
          ),
        ),
        5.verticalSpace,
        FText(text: title, fontWeight: FontWeight.w400, fontSize: 14),
      ],
    );
  }
}
