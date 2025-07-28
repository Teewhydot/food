import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/helpers/extensions.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:get/get.dart';

class KeywordWidget extends StatelessWidget {
  final String keyword;
  final Function onTap;
  const KeywordWidget({super.key, required this.keyword, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(33.r),
          border: Border.all(color: kGreyColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: kGreyColor.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FText(
          text: keyword,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: kTextColorDark,
        ).paddingSymmetric(horizontal: 20.w),
      ).onTap(() {
        onTap();
      }),
    );
  }
}
