import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';

import '../../../../../generated/assets.dart';
import '../../../../components/image.dart';
import '../../../../components/texts/texts.dart';

class AuthTemplate extends StatefulWidget {
  final String title, subtitle;
  final Widget? child;
  final bool hasBackButton, hasSvg;
  final Color lineDesignColor;
  final double containerTopHeight;
  const AuthTemplate({
    super.key,
    this.title = "Welcome",
    this.subtitle = "Login to your account",
    this.child,
    this.hasBackButton = true,
    this.hasSvg = true,
    this.containerTopHeight = 233,
    this.lineDesignColor = kAuthBgColor,
  });
  @override
  State<AuthTemplate> createState() => _AuthTemplateState();
}

class _AuthTemplateState extends State<AuthTemplate> {
  @override
  Widget build(BuildContext context) {
    return FScaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(width: 1.sw, color: kAuthBgColorDark),
          FImage(
            assetPath: Assets.svgsSpiralDesign,
            assetType: FoodAssetType.svg,
            width: 177,
            height: 177,
          ),
          Positioned(
            right: 0,
            child: FImage(
              assetPath: Assets.svgsLineDesign,
              assetType: FoodAssetType.svg,
              width: 201,
              height: 444,
              svgAssetColor: widget.lineDesignColor,
            ),
          ),
          if (widget.hasBackButton)
            Positioned(top: 50.h, left: 24.w, child: BackWidget()),
          Positioned(
            top: 118.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                FText(
                  text: widget.title,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: kWhiteColor,
                ),
                3.verticalSpace,
                FText(
                  text: widget.subtitle,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: kWhiteColor,
                ),
              ],
            ),
          ),
          Positioned(
            top: widget.containerTopHeight.h,
            child: Container(
              width: 1.sw,
              height: 1.sh,
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
