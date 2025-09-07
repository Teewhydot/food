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
      borderRadius: BorderRadius.circular(20),
      child: IntrinsicWidth(
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor : kWhiteColor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: kGreyColor.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Center(
            child: FText.bodySmall(
              text,
              color: isSelected ? kWhiteColor : kTextColorDark,
            ).paddingSymmetric(horizontal: 15.w, vertical: 5.h),
          ).paddingOnly(right: 15),
        ).paddingAll(5),
      ),
    );
  }
}
