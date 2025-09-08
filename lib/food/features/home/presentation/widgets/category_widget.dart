import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../components/texts.dart';
import '../../../../core/theme/colors.dart';

class CategoryWidget extends StatelessWidget {
  final String text;
  final bool isSelected, showImage;
  final VoidCallback onTap;

  const CategoryWidget({
    super.key,
    required this.text,
    this.isSelected = false,
    required this.onTap,
    this.showImage = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: IntrinsicWidth(
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? kPrimaryColor : kLightGreyColor,
              width: 1.5,
            ),
          ),
          child: FText(
            text: text,
            color: kTextColorDark,
            alignment: MainAxisAlignment.center,
          ).paddingSymmetric(horizontal: 5.w, vertical: 5.h),
        ).paddingAll(5),
      ),
    );
  }
}
