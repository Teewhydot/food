import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/features/auth/presentation/widgets/auth_template.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/buttons/buttons.dart';
import '../../../../components/textfields.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _LoginState();
}

class _LoginState extends State<ForgotPassword> {
  final nav = GetIt.instance<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      title: "Forgot Password",
      subtitle: "Please enter your email to reset your password",
      hasBackButton: true,
      hasSvg: true,
      containerTopHeight: 233,
      child: Column(
        children: [
          FTextField(
            height: 63,
            hintText: "Enter your email",
            onChanged: (value) {},
            onTap: () {},
            keyboardType: TextInputType.emailAddress,
            label: 'EMAIL',
            action: TextInputAction.next,
          ),
          24.verticalSpace,
          FButton(buttonText: "Send code", width: 1.sw),
        ],
      ).paddingOnly(
        left: AppConstants.defaultPadding,
        top: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
      ),
    );
  }
}
