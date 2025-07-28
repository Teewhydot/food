import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/bloc/bloc_manager.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/helpers/extensions.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/core/services/navigation_service/nav_config.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/core/utils/app_utils.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/email_verification_status/email_verification_status_bloc.dart';
import 'package:food/food/features/auth/presentation/widgets/auth_template.dart';
import 'package:food/food/features/auth/presentation/widgets/custom_overlay.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final nav = GetIt.instance<NavigationService>();
  final CountdownController _countdownController = CountdownController(
    autoStart: true,
  );
  String? userEmail;
  Timer? _checkEmailVerificationTimer;

  @override
  void initState() {
    super.initState();
    _countdownController.start();
    // Get current user email
    userEmail = FirebaseAuth.instance.currentUser?.email;
  }

  void _checkEmailVerification() {
    context.read<VerifyEmailBloc>().add(CheckEmailVerificationEvent());
  }

  void _resendVerificationEmail() {
    if (userEmail != null) {
      context.read<VerifyEmailBloc>().add(
        ResendVerificationEmailEvent(email: userEmail!),
      );
      _countdownController.restart();
    } else {
      DFoodUtils.showSnackBar(
        "Unable to get user email. Please try again later.",
        kErrorColor,
      );
    }
  }

  @override
  void dispose() {
    _checkEmailVerificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager<VerifyEmailBloc, VerifyEmailState>(
      isSuccess:
          (state) =>
              state is EmailVerificationStatusSuccess ||
              state is EmailVerificationResendSuccess,
      isError: (state) => state is EmailVerificationStatusFailure,
      getErrorMessage:
          (state) => (state as EmailVerificationStatusFailure).errorMessage,
      onSuccess: (context, state) {
        if (state is EmailVerificationStatusSuccess) {
          // Email verified successfully, navigate to location screen
          DFoodUtils.showSnackBar("Email verified successfully", kSuccessColor);
          nav.navigateAndReplace(Routes.location);
        } else if (state is EmailVerificationResendSuccess) {
          // Show success message for resending verification email
          DFoodUtils.showSnackBar(state.successMessage, kSuccessColor);
        }
      },
      bloc: context.watch<VerifyEmailBloc>(),
      child: CustomOverlay(
        isLoading:
            context.watch<VerifyEmailBloc>().state
                is EmailVerificationStatusLoading,
        child: AuthTemplate(
          title: "Email Verification",
          subtitle: "We've sent a verification link to your email",
          hasBackButton: true,
          hasSvg: true,
          containerTopHeight: 233,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kGreyColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    FText(
                      text: "Please check your email",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    16.verticalSpace,
                    FText(
                      text: "We've sent a verification link to:",
                      fontSize: 14,
                      color: kTextColorDark,
                    ),
                    8.verticalSpace,
                    FText(
                      text: userEmail ?? "your email address",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor,
                    ),
                    16.verticalSpace,
                    FWrapText(
                      text:
                          "Click the link in the email to verify your account. "
                          "If you don't see it, check your spam folder.",
                      fontSize: 14,
                      color: kTextColorDark,
                    ),
                  ],
                ),
              ),
              24.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FText(text: "Didn't receive the email?", fontSize: 13),
                  8.horizontalSpace,
                  Countdown(
                    seconds: 60,
                    controller: _countdownController,
                    build: (context, double time) {
                      return time.toInt() == 0
                          ? FText(
                            text: "Resend",
                            fontSize: 13,
                            color: kPrimaryColor,
                            decorations: [TextDecoration.underline],
                          ).onTap(() => _resendVerificationEmail())
                          : FText(
                            text: "Resend in ${time.toInt()}s",
                            fontSize: 13,
                            color: kTextColorDark,
                          );
                    },
                    interval: Duration(seconds: 1),
                  ),
                ],
              ),
              24.verticalSpace,
              FButton(
                buttonText: "I've Verified My Email",
                width: 1.sw,
                onPressed: _checkEmailVerification,
              ),
              16.verticalSpace,
              FButton(
                buttonText: "Back to Login",
                width: 1.sw,
                color: kWhiteColor,
                textColor: kPrimaryColor,
                borderColor: kPrimaryColor,
                onPressed: () {
                  nav.navigateAndReplace(Routes.login);
                },
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
