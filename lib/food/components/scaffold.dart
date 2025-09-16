import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:get/get.dart';

class FScaffold extends StatelessWidget {
  final Widget body, bottomWidget, appBarWidget;
  final double padding;
  final bool showNavBar, resizeToAvoidBottomInset, customScroll, stackLayout;
  final Color? backgroundColor, appBarColor;

  const FScaffold({
    super.key,
    required this.body,
    this.padding = 0.0,
    this.showNavBar = false,
    this.customScroll = false,
    this.stackLayout = false,
    this.resizeToAvoidBottomInset = true,
    this.bottomWidget = const SizedBox(),
    this.appBarWidget = const SizedBox(),
    this.backgroundColor,
    this.appBarColor = kWhiteColor,
  });

  @override
  Widget build(BuildContext context) {
    if (customScroll) {
      return Scaffold(
        extendBody: true,
        backgroundColor: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                floating: true,
                backgroundColor: appBarColor,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: SafeArea(child: appBarWidget.paddingOnly()),
              ),
            ];
          },
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(padding).r,
              child: body,
            ),
          ),
        ),
        bottomNavigationBar: bottomWidget,
      );
    } else if (stackLayout) {
      return Scaffold(
        extendBody: true,
        backgroundColor:
            backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: Padding(padding: EdgeInsets.all(padding).r, child: body),
        bottomNavigationBar: showNavBar ? bottomWidget : null,
      );
    } else {
      return Scaffold(
        extendBody: false,
        backgroundColor:
            backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56.h),
          child: AppBar(
            backgroundColor: appBarColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: SafeArea(child: appBarWidget.paddingOnly()),
          ),
        ),
        body: Padding(padding: EdgeInsets.all(padding).r, child: body),
        bottomNavigationBar: showNavBar ? bottomWidget : null,
      );
    }
  }
}
