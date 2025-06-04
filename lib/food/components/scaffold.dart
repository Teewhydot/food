import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../core/constants/app_constants.dart';

class FScaffold extends StatelessWidget {
  final Widget body, bottomWidget, appBarWidget;
  final double padding;
  final bool showNavBar, resizeToAvoidBottomInset, useSafeArea;
  final Color? backgroundColor;

  const FScaffold({
    super.key,
    required this.body,
    this.padding = 0.0,
    this.showNavBar = false,
    this.useSafeArea = false,
    this.resizeToAvoidBottomInset = true,
    this.bottomWidget = const SizedBox(),
    this.appBarWidget = const SizedBox(),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child:
            useSafeArea
                ? SafeArea(
                  child: appBarWidget,
                ).paddingOnly(left: AppConstants.defaultPadding)
                : appBarWidget.paddingOnly(left: AppConstants.defaultPadding),
      ),
      body: Padding(padding: EdgeInsets.all(padding).r, child: body),
      bottomNavigationBar: bottomWidget,
    );
  }
}
