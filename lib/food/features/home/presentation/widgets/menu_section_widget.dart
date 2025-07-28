import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';

class MenuSectionWidget extends StatelessWidget {
  final Widget child;
  final String title;
  final Function()? onTap;
  const MenuSectionWidget({
    super.key,
    required this.child,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              CircleWidget(radius: 20, color: kWhiteColor, child: child),
              14.horizontalSpace,
              FText(
                text: title,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: kBlackColor,
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 14),
      ],
    );
  }
}
