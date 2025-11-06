import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/register/register_bloc.dart';
import 'package:food/food/features/auth/presentation/widgets/auth_template.dart';
import 'package:food/food/features/auth/presentation/widgets/custom_overlay.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/buttons.dart';
import '../../../../components/textfields.dart';
import '../../../../components/texts.dart';
import '../../../../core/bloc/managers/bloc_manager.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/form_validators.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _LoginState();
}

class _LoginState extends State<SignUp> {
  String? firstNameError,
      lastNameError,
      emailError,
      phoneNumberError,
      passwordError;

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
    return BlocManager<RegisterBloc, BaseState<void>>(
      bloc: context.read<RegisterBloc>(),
      showLoadingIndicator: true,
      onSuccess: (context, state) {
        // Handle any additional success logic if needed
        nav.navigateTo(Routes.emailVerification,
            arguments: {'email': emailController.text.trim()});
      },
      builder: (context, state) {
        return CustomOverlay(
          isLoading: state is LoadingState,
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
                  borderColor:
                      lastNameError != null ? kErrorColor : kContainerColor,
                  onChanged: (value) {
                    setState(() {
                      lastNameError = validateName(value);
                    });
                  },
                  onTap: () {},
                  keyboardType: TextInputType.name,
                  label: 'LAST NAME',
                  action: TextInputAction.next,
                ),
                if (lastNameError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: FText(
                      text: lastNameError!,
                      fontSize: 12,
                      color: Colors.red,
                      alignment: MainAxisAlignment.start,
                    ),
                  ),
                24.verticalSpace,
                FTextField(
                  height: 63,
                  hintText: "Enter your first name",
                  controller: firstNameController,
                  onTap: () {},
                  borderColor:
                      firstNameError != null ? kErrorColor : kContainerColor,
                  onChanged: (value) {
                    setState(() {
                      firstNameError = validateName(value);
                    });
                  },
                  keyboardType: TextInputType.name,
                  label: 'FIRST NAME',
                  action: TextInputAction.next,
                ),
                if (firstNameError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: FText(
                      text: firstNameError!,
                      fontSize: 12,
                      color: Colors.red,
                      alignment: MainAxisAlignment.start,
                    ),
                  ),
                24.verticalSpace,
                FTextField(
                  height: 63,
                  hintText: "Enter your email",
                  onTap: () {},
                  borderColor:
                      emailError != null ? kErrorColor : kContainerColor,
                  onChanged: (value) {
                    setState(() {
                      emailError = validateEmail(value);
                    });
                  },

                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  label: 'Email',
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
                  hintText: "Enter your password",
                  borderColor:
                      passwordError != null ? kErrorColor : kContainerColor,
                  onChanged: (value) {
                    setState(() {
                      passwordError = validatePassword(value);
                    });
                  },

                  controller: passwordController,
                  onTap: () {},
                  keyboardType: TextInputType.visiblePassword,
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

                FTextField(
                  height: 63,
                  hintText: "Enter your password again",
                  borderColor:
                      confirmPasswordController.text != passwordController.text
                          ? kErrorColor
                          : kContainerColor,
                  onChanged: (value) {
                    setState(() {
                      validatePassword(value);
                    });
                  },
                  controller: confirmPasswordController,
                  onTap: () {},

                  keyboardType: TextInputType.visiblePassword,
                  label: 'CONFIRM PASSWORD',
                  action: TextInputAction.next,
                ),
                if (confirmPasswordController.text != passwordController.text)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: FText(
                      text: "Passwords do not match",
                      fontSize: 12,
                      color: Colors.red,
                      alignment: MainAxisAlignment.start,
                    ),
                  ),
                24.verticalSpace,
                FButton(
                  buttonText: "SIGN UP",
                  width: 1.sw,
                  onPressed: () {
                    context.read<RegisterBloc>().register(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                      phoneNumber: phoneNumberController.text,
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
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}
