import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/features/auth/presentation/widgets/auth_template.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:pinput/pinput.dart';

import '../../../../components/buttons/buttons.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _LoginState();
}

class _LoginState extends State<Verification> {
  final nav = GetIt.instance<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      title: "Verification",
      subtitle: "We have sent a code to your email",
      hasBackButton: true,
      hasSvg: true,
      containerTopHeight: 233,
      child: Column(
        children: [
          Row(
            children: [
              FText(text: "CODE", fontSize: 13),
              Spacer(),
              FText(
                text: "Resend in 50secs",
                fontSize: 13,
                color: kTextColorDark,
              ),
            ],
          ),
          8.verticalSpace,
          Pinput(
            length: 4,
            defaultPinTheme: PinTheme(
              width: 56,
              height: 56,
              textStyle: TextStyle(
                fontSize: 20,
                color: kTextColorDark,
                fontWeight: FontWeight.w600,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: kGreyColor,
              ),
            ),
            errorPinTheme: PinTheme(
              width: 56,
              height: 56,
              textStyle: TextStyle(
                fontSize: 20,
                color: kTextColorDark,
                fontWeight: FontWeight.w600,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.redAccent,
              ),
            ),
          ).paddingOnly(top: 8, bottom: 30),
          FButton(buttonText: "Verify", width: 1.sw),
        ],
      ).paddingOnly(
        left: AppConstants.defaultPadding,
        top: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
      ),
    );
  }
}
