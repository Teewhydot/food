import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/utils/form_validators.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/buttons.dart';
import '../../../../components/textfields.dart';
import '../../../../components/texts.dart';
import '../../../../core/bloc/base/base_state.dart';
import '../../../../core/bloc/managers/bloc_manager.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/spacings.dart';
import '../../../home/domain/entities/profile.dart';
import '../manager/auth_bloc/login/enhanced_login_bloc.dart';
import '../widgets/auth_template.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  String? emailError, passwordError;
  final nav = GetIt.instance<NavigationService>();

  final bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocManager<EnhancedLoginBloc, BaseState<UserProfileEntity>>(
      bloc: BlocProvider.of<EnhancedLoginBloc>(context),
      showLoadingIndicator: true,
      onSuccess: (context, state) {
        nav.navigateAndReplaceAll(Routes.home);
      },
      onError: (context, state) {
        _clearPasswordField();
      },
      child: AuthTemplate(
        title: 'Welcome Back',
        subtitle: 'Sign in to your account to continue',
        child: _buildLoginForm(),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Field
              FTextField(
                controller: _emailController,
                node: _emailFocusNode,
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                action: TextInputAction.next,
                borderColor: emailError != null ? kErrorColor : kContainerColor,
                onChanged: (value) {
                  setState(() {
                    emailError = validateEmail(value);
                  });
                },
              ),

              16.verticalSpace,

              // Password Field
              FTextField(
                controller: _passwordController,
                node: _passwordFocusNode,
                hintText: 'Enter your password',
                action: TextInputAction.done,
                obscureText: _obscurePassword,
                borderColor:
                    passwordError != null ? kErrorColor : kContainerColor,
                onChanged: (value) {
                  setState(() {
                    passwordError = validatePassword(value);
                  });
                },
              ),

              12.verticalSpace,

              // Remember Me & Forgot Password Row
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                  ),
                  const FText(text: 'Remember me', fontSize: 14),
                  const Spacer(),
                  TextButton(
                    onPressed: () => nav.navigateTo(Routes.forgotPassword),
                    child: const FText(
                      text: 'Forgot Password?',
                      fontSize: 14,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),

              24.verticalSpace,

              // Login Button with State-aware Loading
              BlocBuilder<EnhancedLoginBloc, BaseState<UserProfileEntity>>(
                builder: (context, state) {
                  final isLoading = state.isLoading;

                  return FButton(
                    onPressed: isLoading ? null : _handleLogin,
                    buttonText: isLoading ? 'Signing In...' : 'Sign In',
                  );
                },
              ),

              24.verticalSpace,

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FText(text: 'Don\'t have an account? ', fontSize: 14),
                  TextButton(
                    onPressed: () => nav.navigateTo(Routes.register),
                    child: const FText(
                      text: 'Sign Up',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),

              16.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      // Hide keyboard
      FocusScope.of(context).unfocus();

      // Submit login
      context.read<EnhancedLoginBloc>().quickLogin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _clearPasswordField() {
    _passwordController.clear();
  }
}
