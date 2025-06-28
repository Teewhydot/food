import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/core/bloc/bloc_manager.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/core/utils/app_utils.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/register/register_bloc.dart';
import 'package:food/food/features/auth/presentation/widgets/auth_template.dart';
import 'package:food/food/features/auth/presentation/widgets/custom_overlay.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/buttons/buttons.dart';
import '../../../../components/textfields.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _LoginState();
}

class _LoginState extends State<SignUp> {
  final nav = GetIt.instance<NavigationService>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager<RegisterBloc, RegisterState>(
      bloc: context.read<RegisterBloc>(),
      isError: (state) => state is RegisterFailure,
      getErrorMessage: (state) => (state as RegisterFailure).errorMessage,
      isSuccess: (state) => state is RegisterSuccess,
      onSuccess: (context, state) {
        // Handle any additional success logic if needed
        DFoodUtils.showSnackBar("Registration successful", kSuccessColor);
        nav.navigateTo(Routes.otpVerification);
      },
      child: CustomOverlay(
        isLoading:
            context.watch<RegisterBloc>().state is RegisterLoading
                ? true
                : false,
        child: AuthTemplate(
          title: "Sign Up",
          subtitle: "Please sign up to get started",
          hasBackButton: true,
          hasSvg: true,
          containerTopHeight: 233,
          child: ListView(
            children: [
              FTextField(
                height: 63,
                hintText: "Enter your last name",
                controller: lastNameController,
                onChanged: (value) {},
                onTap: () {},
                keyboardType: TextInputType.name,
                label: 'LAST NAME',
                action: TextInputAction.next,
              ),
              24.verticalSpace,
              FTextField(
                height: 63,
                hintText: "Enter your first name",
                onChanged: (value) {},
                controller: firstNameController,
                onTap: () {},
                keyboardType: TextInputType.name,
                label: 'FIRST NAME',
                action: TextInputAction.next,
              ),
              24.verticalSpace,
              FTextField(
                height: 63,
                hintText: "Enter your email",
                onChanged: (value) {},
                onTap: () {},
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                label: 'Email',
                action: TextInputAction.next,
              ),
              24.verticalSpace,

              FTextField(
                height: 63,
                hintText: "Enter your password",
                onChanged: (value) {},
                controller: passwordController,
                onTap: () {},
                keyboardType: TextInputType.visiblePassword,
                label: 'PASSWORD',
                action: TextInputAction.next,
              ),
              24.verticalSpace,

              FTextField(
                height: 63,
                hintText: "Enter your password again",
                onChanged: (value) {},
                controller: confirmPasswordController,
                onTap: () {},
                keyboardType: TextInputType.visiblePassword,
                label: 'CONFIRM PASSWORD',
                action: TextInputAction.next,
              ),
              24.verticalSpace,
              FButton(
                buttonText: "SIGN UP",
                width: 1.sw,
                onPressed: () {
                  context.read<RegisterBloc>().add(
                    RegisterInitialEvent(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      phoneNumber: phoneNumberController.text,
                    ),
                  );
                },
              ),
              440.verticalSpace,
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
