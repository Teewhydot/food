import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../components/buttons.dart';
import '../../../../components/textfields.dart';
import '../../../../components/texts.dart';
import '../../../../core/bloc/base/base_state.dart';
import '../../../../core/bloc/managers/simplified_enhanced_bloc_manager.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/spacings.dart';
import '../../../home/domain/entities/profile.dart';
import '../manager/auth_bloc/login/enhanced_login_bloc.dart';
import '../widgets/auth_template.dart';

/// Enhanced Login Screen using the new BLoC management system
class EnhancedLoginScreen extends StatefulWidget {
  const EnhancedLoginScreen({super.key});

  @override
  State<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends State<EnhancedLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
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
    return BlocProvider(
      create: (context) => EnhancedLoginBloc(),
      child: SimplifiedEnhancedBlocManager<
        EnhancedLoginBloc,
        BaseState<UserProfileEntity>
      >(
        bloc: BlocProvider.of<EnhancedLoginBloc>(context),
        showLoadingIndicator: true,
        onSuccess: (context, state) {
          // Navigate to home screen on successful login
          Navigator.of(context).pushReplacementNamed('/home');
        },
        onError: (context, state) {
          // Additional error handling can be added here
          _clearPasswordField();
        },
        child: AuthTemplate(
          title: 'Welcome Back',
          subtitle: 'Sign in to your account to continue',
          child: _buildLoginForm(),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              ),

              16.verticalSpace,

              // Password Field
              FTextField(
                controller: _passwordController,
                node: _passwordFocusNode,
                hintText: 'Enter your password',
                action: TextInputAction.done,
                obscureText: _obscurePassword,
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
                    onPressed:
                        () =>
                            Navigator.of(context).pushNamed('/forgot-password'),
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
                    onPressed:
                        () => Navigator.of(context).pushNamed('/register'),
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

              // Social Login Options
              _buildSocialLoginSection(),

              // Debug Section (only in debug mode)
              if (kDebugMode) ...[32.verticalSpace, _buildDebugSection()],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: FText(
                text: 'Or continue with',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),

        16.verticalSpace,

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleSocialLogin('google'),
                icon: const Icon(Icons.g_mobiledata, size: 24),
                label: const Text('Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _handleSocialLogin('facebook'),
                icon: const Icon(Icons.facebook, size: 24),
                label: const Text('Facebook'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDebugSection() {
    return BlocBuilder<EnhancedLoginBloc, BaseState<UserProfileEntity>>(
      builder: (context, state) {
        return Card(
          color: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Debug Info',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                4.verticalSpace,
                Text(
                  'State: ${state.runtimeType}',
                  style: const TextStyle(fontSize: 10),
                ),
                Text(
                  'Is Loading: ${state.isLoading}',
                  style: const TextStyle(fontSize: 10),
                ),
                Text(
                  'Is Error: ${state.isError}',
                  style: const TextStyle(fontSize: 10),
                ),
                Text(
                  'Has Data: ${state.hasData}',
                  style: const TextStyle(fontSize: 10),
                ),
                if (state.errorMessage != null)
                  Text(
                    'Error: ${state.errorMessage}',
                    style: const TextStyle(fontSize: 10, color: Colors.red),
                  ),
                8.verticalSpace,
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _emailController.text = 'test@example.com';
                          _passwordController.text = 'password123';
                        },
                        child: const Text(
                          'Fill Test Data',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    8.horizontalSpace,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<EnhancedLoginBloc>().resetLogin();
                        },
                        child: const Text(
                          'Reset State',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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

  void _handleSocialLogin(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider login is not implemented yet'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearPasswordField() {
    _passwordController.clear();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }
}
