import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/core/theme/colors.dart';

class FoodContainer extends StatelessWidget {
  final Widget? child;
  final double padding,
      height,
      width,
      borderRadius,
      borderWidth,
      topPadding,
      bottomPadding,
      leftPadding,
      rightPadding;
  final Color color, borderColor;
  final bool hasBorder, hasUniquePadding;
  const FoodContainer({
    super.key,
    this.child,
    this.padding = 0.0,
    this.height = 0.0,
    this.width = 0.0,
    this.borderRadius = 10.0,
    this.borderWidth = 0.0,
    this.topPadding = 0.0,
    this.bottomPadding = 0.0,
    this.leftPadding = 0.0,
    this.rightPadding = 0.0,
    this.color = kContainerColor,
    this.borderColor = kContainerColor,
    this.hasBorder = false,
    this.hasUniquePadding = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          hasUniquePadding
              ? EdgeInsets.only(
                left: leftPadding,
                right: rightPadding,
                top: topPadding,
                bottom: bottomPadding,
              )
              : EdgeInsets.all(padding).r,
      child: Container(
        width: width.w,
        height: height.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius).r,
          border:
              hasBorder
                  ? Border.all(color: borderColor, width: borderWidth.w)
                  : null,
        ),
        child: child,
      ),
    );
  }
}
