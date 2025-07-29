import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/base/base_state.dart';
import '../../../../core/bloc/managers/enhanced_bloc_manager.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/spacings.dart';
import '../../../../components/buttons.dart';
import '../../../../components/textfields.dart';
import '../../../../components/texts.dart';
import '../../../home/domain/entities/profile.dart';
import '../manager/auth_bloc/register/enhanced_register_bloc.dart';
import '../widgets/auth_template.dart';

/// Simplified Enhanced Registration Screen
class EnhancedRegisterScreen extends StatefulWidget {
  const EnhancedRegisterScreen({super.key});

  @override
  State<EnhancedRegisterScreen> createState() => _EnhancedRegisterScreenState();
}

class _EnhancedRegisterScreenState extends State<EnhancedRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EnhancedRegisterBloc(),
      child: AuthTemplate(
        title: 'Create Account',
        subtitle: 'Sign up to get started with your account',
        child: _buildRegistrationForm(),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return EnhancedBlocManager<EnhancedRegisterBloc, BaseState<UserProfileEntity>>(
      bloc: BlocProvider.of<EnhancedRegisterBloc>(context),
      showLoadingIndicator: false,
      showErrorMessages: true,
      showSuccessMessages: true,
      enableRetry: true,
      onRetry: () => _handleRegistration(),
      onSuccess: (context, state) {
        Navigator.of(context).pushReplacementNamed(
          '/email-verification',
          arguments: _emailController.text,
        );
      },
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // First Name Field
              FTextField(
                controller: _firstNameController,
                hintText: 'First name',
                action: TextInputAction.next,
              ),

              16.verticalSpace,

              // Email Field
              FTextField(
                controller: _emailController,
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                action: TextInputAction.next,
              ),

              16.verticalSpace,

              // Password Field
              FTextField(
                controller: _passwordController,
                hintText: 'Create password',
                obscureText: true,
                action: TextInputAction.done,
              ),

              24.verticalSpace,

              // Register Button with State-aware Loading
              BlocBuilder<EnhancedRegisterBloc, BaseState<UserProfileEntity>>(
                builder: (context, state) {
                  final isLoading = state.isLoading;
                  
                  return FButton(
                    onPressed: isLoading ? null : _handleRegistration,
                    buttonText: isLoading ? 'Creating Account...' : 'Create Account',
                  );
                },
              ),

              24.verticalSpace,

              // Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FText(
                    text: 'Already have an account? ',
                    fontSize: 14,
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                    child: const FText(
                      text: 'Sign In',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRegistration() {
    if (_formKey.currentState?.validate() ?? false) {
      // Hide keyboard
      FocusScope.of(context).unfocus();
      
      // Submit registration
      context.read<EnhancedRegisterBloc>().quickRegister(
        firstName: _firstNameController.text.trim(),
        lastName: 'User', // Simplified
        email: _emailController.text.trim(),
        phoneNumber: '1234567890', // Simplified
        password: _passwordController.text,
        confirmPassword: _passwordController.text,
      );
    }
  }
}