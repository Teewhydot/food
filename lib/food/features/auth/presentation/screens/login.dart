import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/core/bloc/bloc_manager.dart';
import 'package:food/food/core/helpers/extensions.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/core/utils/form_validators.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/login/login_bloc.dart';
import 'package:food/food/features/auth/presentation/widgets/auth_template.dart';
import 'package:food/food/features/auth/presentation/widgets/custom_overlay.dart';
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
  String? emailError, passwordError;
  bool isPasswordVisible = false;
  bool isRememberMe = false;
  final nav = GetIt.instance<NavigationService>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager<LoginBloc, LoginState>(
      bloc: context.read<LoginBloc>(),
      isError: (state) => state is LoginFailureState,
      getErrorMessage: (state) => (state as LoginFailureState).errorMessage,
      isSuccess: (state) => state is LoginSuccessState,
      onSuccess: (context, state) {
        nav.navigateAndReplace(Routes.home);
      },
      child: CustomOverlay(
        isLoading:
            context.watch<LoginBloc>().state is LoginLoadingState
                ? true
                : false,
        child: AuthTemplate(
          title: "Login",
          subtitle: "Please sign in to your existing account",
          hasBackButton: true,
          hasSvg: true,
          containerTopHeight: 233,
          child: Column(
            children: [
              FTextField(
                controller: emailController,
                validationMode: AutovalidateMode.onUserInteraction,
                height: 63,
                borderColor: emailError != null ? kErrorColor : kContainerColor,
                hintText: "Enter your email",
                onChanged: (value) {
                  setState(() {
                    emailError = validateEmail(value);
                  });
                },
                onTap: () {},
                keyboardType: TextInputType.emailAddress,
                label: 'EMAIL',
                action: TextInputAction.next,
              ),
              if (emailError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: FText(
                    text: emailError!,
                    fontSize: 12,
                    color: Colors.red,
                    alignment: MainAxisAlignment.start,
                  ),
                ),
              24.verticalSpace,
              FTextField(
                height: 63,
                isPassword: true,
                hintText: "Enter your password",
                validationMode: AutovalidateMode.onUserInteraction,
                borderColor:
                    passwordError != null ? kErrorColor : kContainerColor,
                controller: passwordController,

                onChanged: (value) {
                  setState(() {
                    passwordError = validatePassword(value);
                  });
                },
                onTap: () {},
                keyboardType: TextInputType.emailAddress,
                label: 'PASSWORD',
                action: TextInputAction.next,
              ),
              if (passwordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: FText(
                    text: passwordError!,
                    fontSize: 12,
                    color: Colors.red,
                    alignment: MainAxisAlignment.start,
                  ),
                ),
              24.verticalSpace,
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isRememberMe = !isRememberMe;
                      });
                    },
                    child: FoodContainer(
                      height: 20,
                      width: 20,
                      borderRadius: 5,
                      hasBorder: true,
                      borderWidth: 2,
                      borderColor: kGreyColor,
                      color: isRememberMe ? kPrimaryColor : kWhiteColor,
                      child: Icon(Icons.check, color: kWhiteColor, size: 15),
                    ),
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
                  ).onTap(() {
                    nav.navigateTo(Routes.forgotPassword);
                  }),
                ],
              ),
              31.verticalSpace,
              FButton(
                buttonText: "Login",
                width: 1.sw,
                onPressed: () {
                  if (emailError != null || passwordError != null) {
                    return;
                  }
                  context.read<LoginBloc>().add(
                    AuthLoginEvent(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    ),
                  );
                },
              ),
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
              ).onTap(() {
                nav.navigateTo(Routes.register);
              }),
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
        ),
      ),
    );
  }
}
