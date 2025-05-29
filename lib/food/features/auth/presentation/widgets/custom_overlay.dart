import 'package:flutter/material.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
      color: kPrimaryColor.withOpacity(0.5),
      progressIndicator: SpinKitFadingCircle(color: kPrimaryColor),
      child: child,
    );
  }
}
