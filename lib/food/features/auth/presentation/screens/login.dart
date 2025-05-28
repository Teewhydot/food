import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/features/auth/presentation/widgets/auth_template.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../components/buttons/buttons.dart';
import '../../../../components/textfields.dart';
import '../../../../components/texts/texts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../onboarding/presentation/widgets/food_container.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final nav = GetIt.instance<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      title: "Login",
      subtitle: "Please sign in to your existing account",
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
          FTextField(
            height: 63,
            isPassword: true,
            hintText: "Enter your email",
            onChanged: (value) {},
            onTap: () {},
            keyboardType: TextInputType.emailAddress,
            label: 'PASSWORD',
            action: TextInputAction.next,
          ),
          24.verticalSpace,
          Row(
            children: [
              FoodContainer(
                height: 20,
                width: 20,
                borderRadius: 5,
                hasBorder: true,
                borderWidth: 2,
                borderColor: kGreyColor,
                color: kWhiteColor,
                child: Icon(Ionicons.checkbox),
              ),
              10.horizontalSpace,
              FText(
                text: "Remember me",
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: kTextColorDark,
              ),
              Spacer(),
              FText(
                text: "Forgot password?",
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: kPrimaryColor,
              ),
            ],
          ),
          31.verticalSpace,
          FButton(buttonText: "Login", width: 1.sw),
          38.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FText(
                text: "Don't have an account?",
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: kTextColorDark,
              ),
              5.horizontalSpace,
              FText(
                text: "Sign up",
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: kPrimaryColor,
              ),
            ],
          ),
          27.verticalSpace,
          FText(
            text: "Or",
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: kTextColorDark,
          ),
          17.verticalSpace,
          Row(
            spacing: 30,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FoodContainer(
                width: 62,
                height: 62,
                borderRadius: 62,
                color: kFbColor,
                child: Icon(
                  Icons.facebook_outlined,
                  color: kWhiteColor,
                  size: 25.sp,
                ),
              ),

              FoodContainer(
                width: 62,
                height: 62,
                borderRadius: 62,
                color: kTwitterColor,
                child: Icon(
                  Ionicons.logo_twitter,
                  color: kWhiteColor,
                  size: 25.sp,
                ),
              ),
              FoodContainer(
                width: 62,
                height: 62,
                borderRadius: 62,
                color: Platform.isAndroid ? kGoogleColor : kAppleColor,
                child:
                    Platform.isAndroid
                        ? Icon(
                          Ionicons.logo_google,
                          color: kWhiteColor,
                          size: 25.sp,
                        )
                        : Icon(
                          Ionicons.logo_apple,
                          color: kWhiteColor,
                          size: 25.sp,
                        ),
              ),
            ],
          ),
        ],
      ).paddingOnly(
        left: AppConstants.defaultPadding,
        top: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
      ),
    );
  }
}
