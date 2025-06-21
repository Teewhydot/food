import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/bloc/bloc_manager.dart';
import 'package:food/food/core/helpers/extensions.dart';
import 'package:food/food/features/auth/presentation/widgets/auth_template.dart';
import 'package:food/food/features/auth/presentation/widgets/custom_overlay.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:pinput/pinput.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

import '../../../../components/buttons/buttons.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/app_utils.dart';
import '../manager/auth_bloc/otp_verification/verification_bloc.dart';

class Verification extends StatefulWidget {
  const Verification({super.key});

  @override
  State<Verification> createState() => _LoginState();
}

class _LoginState extends State<Verification> {
  final nav = GetIt.instance<NavigationService>();
  final TextEditingController _otpController = TextEditingController();
  final CountdownController _countdownController = CountdownController(
    autoStart: true,
  );

  @override
  void initState() {
    super.initState();
    _countdownController.start();
  }

  @override
  void dispose() {
    super.dispose();
    _otpController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager<VerificationBloc, VerificationState>(
      isSuccess: (state) => state is VerificationSuccess,
      isError: (state) => state is VerificationFailure,
      getErrorMessage: (state) => (state as VerificationFailure).errorMessage,
      onSuccess: (context, state) {
        // Handle any additional success logic if needed
        DFoodUtils.showSnackBar("Verification successful", kSuccessColor);
        nav.navigateAndReplace(Routes.home);
      },
      bloc: context.watch<VerificationBloc>(),
      child: CustomOverlay(
        isLoading:
            context.watch<VerificationBloc>().state is VerificationLoading
                ? true
                : false,
        child: AuthTemplate(
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
                  Countdown(
                    seconds: 50,
                    controller: _countdownController,
                    build: (context, double time) {
                      return time.toInt() == 0
                          ? FText(
                            text: "Resend",
                            fontSize: 13,
                            color: kPrimaryColor,
                            decorations: [TextDecoration.underline],
                          ).onTap(() {
                            _countdownController.restart();
                          })
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
              8.verticalSpace,
              Pinput(
                length: 4,
                controller: _otpController,
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
              FButton(
                buttonText: "Verify",
                width: 1.sw,
                onPressed: () {
                  final otpCode = _otpController.text.trim();
                  if (otpCode.isEmpty || otpCode.length < 4) {
                    DFoodUtils.showSnackBar(
                      "Please enter a valid OTP code",
                      kErrorColor,
                    );
                    return;
                  }
                  context.read<VerificationBloc>().add(
                    VerificationRequestedEvent(otpCode: otpCode),
                  );
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
