import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/features/auth/presentation/widgets/auth_template.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/buttons/buttons.dart';
import '../../../../components/textfields.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _LoginState();
}

class _LoginState extends State<SignUp> {
  final nav = GetIt.instance<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      title: "Sign Up",
      subtitle: "Please sign up to get started",
      hasBackButton: true,
      hasSvg: true,
      containerTopHeight: 233,
      child: Column(
        spacing: 24,
        children: [
          FTextField(
            height: 63,
            hintText: "Enter your full name",
            onChanged: (value) {},
            onTap: () {},
            keyboardType: TextInputType.name,
            label: 'FULL NAME',
            action: TextInputAction.next,
          ),
          FTextField(
            height: 63,
            hintText: "Enter your email",
            onChanged: (value) {},
            onTap: () {},
            keyboardType: TextInputType.emailAddress,
            label: 'FULL NAME',
            action: TextInputAction.next,
          ),
          FTextField(
            height: 63,
            hintText: "Enter your password",
            onChanged: (value) {},
            onTap: () {},
            keyboardType: TextInputType.visiblePassword,
            label: 'PASSWORD',
            action: TextInputAction.next,
          ),
          FTextField(
            height: 63,
            hintText: "Enter your password",
            onChanged: (value) {},
            onTap: () {},
            keyboardType: TextInputType.visiblePassword,
            label: 'CONFIRM PASSWORD',
            action: TextInputAction.next,
          ),
          24.verticalSpace,
          FButton(buttonText: "SIGN UP", width: 1.sw),
        ],
      ).paddingOnly(
        left: AppConstants.defaultPadding,
        top: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
      ),
    );
  }
}
