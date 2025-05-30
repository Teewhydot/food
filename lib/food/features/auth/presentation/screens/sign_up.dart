import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/core/utils/app_utils.dart';
import 'package:food/food/features/auth/presentation/widgets/auth_template.dart';
import 'package:food/food/features/auth/presentation/widgets/custom_overlay.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/buttons/buttons.dart';
import '../../../../components/textfields.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../manager/auth_bloc/login/login_bloc.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _LoginState();
}

class _LoginState extends State<SignUp> {
  final nav = GetIt.instance<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      bloc: context.read<LoginBloc>(),
      listener: (context, state) {
        if (state is LoginSuccessState) {
          DFoodUtils.showSnackBar("Registration was successful", kSuccessColor);
          nav.navigateAndReplace(Routes.login);
        } else if (state is LoginFailureState) {
          DFoodUtils.showSnackBar(state.error, kErrorColor);
        }
      },
      child: CustomOverlay(
        isLoading:
            context.watch<LoginBloc>().state is LoginLoadingState
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
                hintText: "Enter your full name",
                onChanged: (value) {},
                onTap: () {},
                keyboardType: TextInputType.name,
                label: 'FULL NAME',
                action: TextInputAction.next,
              ),
              24.verticalSpace,

              FTextField(
                height: 63,
                hintText: "Enter your email",
                onChanged: (value) {},
                onTap: () {},
                keyboardType: TextInputType.emailAddress,
                label: 'FULL NAME',
                action: TextInputAction.next,
              ),
              24.verticalSpace,

              FTextField(
                height: 63,
                hintText: "Enter your password",
                onChanged: (value) {},
                onTap: () {},
                keyboardType: TextInputType.visiblePassword,
                label: 'PASSWORD',
                action: TextInputAction.next,
              ),
              24.verticalSpace,

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
              FButton(
                buttonText: "SIGN UP",
                width: 1.sw,
                onPressed: () {
                  context.read<LoginBloc>().add(
                    AuthSignUpEvent(fullName: '', email: '', password: ''),
                  );
                  // nav.navigateAndReplace(Routes.login);
                },
              ),
              24.verticalSpace,
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
