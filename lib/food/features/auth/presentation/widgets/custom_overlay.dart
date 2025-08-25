import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:loading_overlay/loading_overlay.dart';

class CustomOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  const CustomOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      color: kPrimaryColor.withValues(alpha: 0.5),
      progressIndicator: SpinKitFadingCircle(color: kWhiteColor),
      child: child,
    );
  }
}
