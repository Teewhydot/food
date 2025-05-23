import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FScaffold extends StatelessWidget {
  final Widget body, bottomWidget;
  final double padding;
  final bool showNavBar, resizeToAvoidBottomInset;

  const FScaffold({
    super.key,
    required this.body,
    this.padding = 0.0,
    this.showNavBar = false,
    this.resizeToAvoidBottomInset = true,
    this.bottomWidget = const SizedBox(),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Padding(
        padding: EdgeInsets.all(padding).r,
        child: SafeArea(child: body),
      ),
      bottomNavigationBar: bottomWidget,
    );
  }
}
