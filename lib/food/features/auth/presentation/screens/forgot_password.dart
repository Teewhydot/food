import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/bloc_manager/bloc_manager.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/forgot_password/forgot_password_bloc.dart';
import 'package:food/food/features/auth/presentation/widgets/auth_template.dart';
import 'package:food/food/features/auth/presentation/widgets/custom_overlay.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/buttons/buttons.dart';
import '../../../../components/textfields.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/app_utils.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _LoginState();
}

class _LoginState extends State<ForgotPassword> {
  final nav = GetIt.instance<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return BlocManager<ForgotPasswordBloc, ForgotPasswordState>(
      bloc: context.read<ForgotPasswordBloc>(),
      isError: (state) => state is ForgotPasswordFailure,
      getErrorMessage: (state) => (state as ForgotPasswordFailure).error,
      isSuccess: (state) => state is ForgotPasswordSuccess,
      onSuccess: (context, state) {
        // Handle any additional success logic if needed
        DFoodUtils.showSnackBar("Code sent successfully", kSuccessColor);
        nav.navigateTo(Routes.otpVerification);
      },
      child: CustomOverlay(
        isLoading:
            context.watch<ForgotPasswordBloc>().state is ForgotPasswordLoading
                ? true
                : false,
        child: AuthTemplate(
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
              FButton(
                buttonText: "Send code",
                width: 1.sw,
                onPressed: () {
                  context.read<ForgotPasswordBloc>().add(
                    ForgotPasswordSubmitEvent(email: "email"),
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
