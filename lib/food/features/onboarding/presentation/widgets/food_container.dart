import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/core/theme/colors.dart';

class FoodContainer extends StatelessWidget {
  final Widget? child;
  final double height, width, borderRadius, borderWidth;
  final Color color, borderColor;
  final bool hasBorder;
  final String? networkImage;
  const FoodContainer({
    super.key,
    this.child,
    this.height = 0.0,
    this.width = 0.0,
    this.borderRadius = 10.0,
    this.borderWidth = 0.0,
    this.networkImage,
    this.color = kContainerColor,
    this.borderColor = kContainerColor,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      height: height.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius).r,
        image:
            networkImage != null
                ? DecorationImage(
                  image: NetworkImage(networkImage!),
                  fit: BoxFit.cover,
                )
                : null,
        border:
            hasBorder
                ? Border.all(color: borderColor, width: borderWidth.w)
                : null,
      ),
      child: child,
    );
  }
}
