import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/base/base_state.dart';
import '../../../../core/bloc/managers/enhanced_bloc_manager.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/spacings.dart';
import '../../../../components/texts.dart';
import '../../domain/entities/profile.dart';
import '../../manager/user_profile/enhanced_user_profile_cubit.dart';

/// Example screen showcasing the enhanced BLoC management system
class ExampleEnhancedHomeScreen extends StatefulWidget {
  const ExampleEnhancedHomeScreen({super.key});

  @override
  State<ExampleEnhancedHomeScreen> createState() => _ExampleEnhancedHomeScreenState();
}

class _ExampleEnhancedHomeScreenState extends State<ExampleEnhancedHomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EnhancedUserProfileCubit>().onRefresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Example 1: Using EnhancedBlocManager with all features
          _buildUserProfileSection(),
          
          const Divider(),
          
          // Example 2: Using DataBlocBuilder for simple data display
          _buildSimpleUserDisplay(),
          
          const Divider(),
          
          // Example 3: Manual BlocBuilder for custom logic
          _buildCustomUserDisplay(),
        ],
      ),
    );
  }

  /// Example using EnhancedBlocManager with full features
  Widget _buildUserProfileSection() {
    return Expanded(
      child: EnhancedBlocManager<EnhancedUserProfileCubit, BaseState<UserProfileEntity>>(
        bloc: BlocProvider.of<EnhancedUserProfileCubit>(context),
        showLoadingIndicator: true,
        showErrorMessages: true,
        showSuccessMessages: true,
        enableRetry: true,
        enablePullToRefresh: true,
        enableLogging: true,
        onRetry: () {
          context.read<EnhancedUserProfileCubit>().loadUserProfile();
        },
        onRefresh: () async {
          await context.read<EnhancedUserProfileCubit>().onRefresh();
        },
        onError: (context, state) {
          // Custom error handling
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Custom error handler: ${state.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        onSuccess: (context, state) {
          // Custom success handling
          print('Success: ${state.successMessage}');
        },
        errorWidgetBuilder: (context, error, retry) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                16.verticalSpace,
                Text('Oops! $error'),
                16.verticalSpace,
                if (retry != null)
                  ElevatedButton(
                    onPressed: retry,
                    child: const Text('Try Again'),
                  ),
              ],
            ),
          );
        },
        loadingWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading your profile...'),
            ],
          ),
        ),
        child: _buildUserProfileContent(),
      ),
    );
  }

  /// Content to display when user profile is loaded
  Widget _buildUserProfileContent() {
    return DataBlocBuilder<EnhancedUserProfileCubit, BaseState<UserProfileEntity>, UserProfileEntity>(
      bloc: BlocProvider.of<EnhancedUserProfileCubit>(context),
      dataExtractor: (state) => state.data,
      builder: (context, userProfile) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: userProfile.profileImageUrl != null
                        ? NetworkImage(userProfile.profileImageUrl!)
                        : null,
                    child: userProfile.profileImageUrl == null
                        ? Text(userProfile.firstName[0].toUpperCase())
                        : null,
                  ),
                  16.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FText(
                          text: '${userProfile.firstName} ${userProfile.lastName}',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        4.verticalSpace,
                        FText(
                          text: userProfile.email,
                          fontSize: 14,
                          color: Colors.grey[600] ?? Colors.grey,
                        ),
                        if (userProfile.phoneNumber.isNotEmpty) ...[
                          4.verticalSpace,
                          FText(
                            text: userProfile.phoneNumber,
                            fontSize: 14,
                            color: Colors.grey[600] ?? Colors.grey,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              
              24.verticalSpace,
              
              // Profile Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _editProfile(context, userProfile),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                    ),
                  ),
                  16.horizontalSpace,
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _refreshProfile(context),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ),
                ],
              ),
              
              24.verticalSpace,
              
              // Additional info
              if (userProfile.firstTimeLogin == true)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade600),
                      12.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade600,
                              ),
                            ),
                            4.verticalSpace,
                            const Text(
                              'Complete your profile to get personalized recommendations.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<EnhancedUserProfileCubit>().markNotFirstTimeLogin();
                        },
                        child: const Text('Complete'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
      emptyBuilder: (context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64),
            SizedBox(height: 16),
            Text('No profile data available'),
          ],
        ),
      ),
    );
  }

  /// Simple user display using DataBlocBuilder
  Widget _buildSimpleUserDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: DataBlocBuilder<EnhancedUserProfileCubit, BaseState<UserProfileEntity>, String>(
        bloc: BlocProvider.of<EnhancedUserProfileCubit>(context),
        dataExtractor: (state) => state.data != null 
            ? '${state.data!.firstName} ${state.data!.lastName}'
            : null,
        builder: (context, displayName) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text('Welcome, $displayName!'),
              subtitle: const Text('Simple display example'),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          );
        },
        loadingBuilder: (context) => const Card(
          child: ListTile(
            leading: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            title: Text('Loading...'),
          ),
        ),
        errorBuilder: (context, error) => Card(
          child: ListTile(
            leading: const Icon(Icons.error, color: Colors.red),
            title: Text('Error: $error'),
          ),
        ),
      ),
    );
  }

  /// Custom BlocBuilder example
  Widget _buildCustomUserDisplay() {
    return BlocBuilder<EnhancedUserProfileCubit, BaseState<UserProfileEntity>>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'State Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  8.verticalSpace,
                  _buildStateInfo('Is Loading:', state.isLoading.toString()),
                  _buildStateInfo('Is Error:', state.isError.toString()),
                  _buildStateInfo('Is Success:', state.isSuccess.toString()),
                  _buildStateInfo('Has Data:', state.hasData.toString()),
                  if (state.data != null)
                    _buildStateInfo('First Time:', state.data!.firstTimeLogin.toString()),
                  if (state is LoadedState)
                    _buildStateInfo('From Cache:', (state as LoadedState).isFromCache.toString()),
                  if (state is AsyncLoadedState) ...[
                    _buildStateInfo('Last Updated:', (state as AsyncLoadedState).lastUpdated.toString()),
                    _buildStateInfo('Is Refreshing:', (state as AsyncLoadedState).isRefreshing.toString()),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStateInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context, UserProfileEntity profile) {
    // Navigate to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile functionality would go here')),
    );
  }

  void _refreshProfile(BuildContext context) {
    context.read<EnhancedUserProfileCubit>().performRefresh();
  }
}