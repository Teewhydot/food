import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/core/theme/colors.dart';

class DFoodUtils {
  static showDialogContainer({
    required BuildContext context,
    required Widget child,
    double? height,
    double width = 382,
    bool isDismissible = true,
    EdgeInsets? insetPadding,
    EdgeInsets? contentPadding,
    bool pop = false,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: isDismissible,
      barrierColor: kPrimaryColor.withOpacity(0.7),
      builder: (context) {
        return PopScope(
          canPop: pop,
          onPopInvoked: (didPop) {},
          child: Dialog(
            clipBehavior: Clip.none,
            insetPadding: insetPadding,
            backgroundColor: kWhiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35).r,
            ),
            child: Container(
              width: width.w,
              height: height,
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(35).r,
              ),
              padding:
                  contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 10).r,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
