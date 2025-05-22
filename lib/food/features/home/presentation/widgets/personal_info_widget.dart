import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../components/texts/texts.dart';
import '../../../../core/theme/colors.dart';
import 'circle_widget.dart';

class PersonalInfoWidget extends StatelessWidget {
  final String field, value;
  final Widget child;
  const PersonalInfoWidget({
    super.key,
    required this.field,
    required this.value,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleWidget(radius: 20, color: kWhiteColor, child: child),
        14.horizontalSpace,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FText(
              text: field.toUpperCase(),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: kBlackColor,
            ),
            FText(
              text: value,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: kTextColorValue,
            ),
          ],
        ),
      ],
    );
  }
}
