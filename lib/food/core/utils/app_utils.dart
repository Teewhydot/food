import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:get/get.dart';

class DFoodUtils {
  static showSnackBar(String message, Color color) {
    Get.snackbar(
      color == kSuccessColor ? "Success" : "Error",
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color,
      colorText: kWhiteColor,
    );
  }

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
      barrierColor: kPrimaryColor.withValues(alpha: 0.7),
      builder: (context) {
        return PopScope(
          canPop: pop,
          onPopInvoked: (didPop) {},
          child: Dialog(
            clipBehavior: Clip.none,
            insetPadding: insetPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35).r,
            ),
            child: Container(
              width: width.w,
              height: height,
              decoration: BoxDecoration(
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
