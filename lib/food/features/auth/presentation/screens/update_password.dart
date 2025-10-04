import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/update_password/update_password_bloc.dart';
import 'package:food/food/features/auth/presentation/widgets/auth_template.dart';
import 'package:food/food/features/auth/presentation/widgets/custom_overlay.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/buttons.dart';
import '../../../../components/textfields.dart';
import '../../../../core/bloc/managers/bloc_manager.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/app_utils.dart';

class UpdatePassword extends StatefulWidget {
  const UpdatePassword({super.key});

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  final nav = GetIt.instance<NavigationService>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateInputs() {
    if (_currentPasswordController.text.isEmpty) {
      return 'Current password is required';
    }
    if (_newPasswordController.text.isEmpty) {
      return 'New password is required';
    }
    if (_newPasswordController.text.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (_confirmPasswordController.text.isEmpty) {
      return 'Please confirm your new password';
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      return 'Passwords do not match';
    }
    if (_currentPasswordController.text == _newPasswordController.text) {
      return 'New password must be different from current password';
    }
    return null;
  }

  void _handleUpdatePassword() {
    final error = _validateInputs();
    if (error != null) {
      DFoodUtils.showSnackBar(error, kErrorColor);
      return;
    }

    context.read<UpdatePasswordBloc>().add(
      UpdatePasswordSubmitEvent(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager<UpdatePasswordBloc, BaseState<void>>(
      bloc: context.read<UpdatePasswordBloc>(),
      showLoadingIndicator: true,
      onSuccess: (context, state) {
        DFoodUtils.showSnackBar(
          "Password updated successfully",
          kSuccessColor,
        );
        // Clear the text fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        // Navigate back or to home
        nav.goBack();
      },
      builder: (context, state) {
        return CustomOverlay(
          isLoading: state is LoadingState,
          child: AuthTemplate(
            title: "Update Password",
            subtitle: "Enter your current password and choose a new one",
            hasBackButton: true,
            hasSvg: false,
            containerTopHeight: 200,
            child: Column(
              children: [
                FTextField(
                  height: 63,
                  controller: _currentPasswordController,
                  hintText: "Current Password",
                  onChanged: (value) {},
                  onTap: () {},
                  keyboardType: TextInputType.visiblePassword,
                  label: 'CURRENT PASSWORD',
                  action: TextInputAction.next,
                  obscureText: _obscureCurrentPassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureCurrentPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: kContainerColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),
                ),
                16.verticalSpace,
                FTextField(
                  height: 63,
                  controller: _newPasswordController,
                  hintText: "New Password",
                  onChanged: (value) {},
                  onTap: () {},
                  keyboardType: TextInputType.visiblePassword,
                  label: 'NEW PASSWORD',
                  action: TextInputAction.next,
                  obscureText: _obscureNewPassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: kContainerColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                ),
                16.verticalSpace,
                FTextField(
                  height: 63,
                  controller: _confirmPasswordController,
                  hintText: "Confirm New Password",
                  onChanged: (value) {},
                  onTap: () {},
                  keyboardType: TextInputType.visiblePassword,
                  label: 'CONFIRM NEW PASSWORD',
                  action: TextInputAction.done,
                  obscureText: _obscureConfirmPassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: kContainerColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                24.verticalSpace,
                FButton(
                  buttonText: "Update Password",
                  width: 1.sw,
                  onPressed: _handleUpdatePassword,
                ),
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
