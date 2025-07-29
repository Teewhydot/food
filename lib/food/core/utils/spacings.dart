import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget horizontalSpace(double space) {
  return SizedBox(width: space.w);
}

Widget verticalSpace(double space) {
  return SizedBox(height: space.h);
}

/// Extension methods for spacing
extension SpacingExtension on int {
  Widget get verticalSpace => SizedBox(height: toDouble().h);
  Widget get horizontalSpace => SizedBox(width: toDouble().w);
}
