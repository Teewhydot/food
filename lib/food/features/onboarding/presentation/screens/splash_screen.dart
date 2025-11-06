import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/login/enhanced_login_bloc.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/login/login_event.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';
import 'package:get_it/get_it.dart';

import '../../../../../generated/assets.dart';
import '../../../../components/scaffold.dart';
import '../../../../core/services/navigation_service/nav_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final nav = GetIt.instance<NavigationService>();

  @override
  void initState() {
    super.initState();

    // Delay the auth check to ensure the widget tree is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  void _checkAuthStatus() {
    try {
      final bloc = context.read<EnhancedLoginBloc>();
      bloc.add(const CheckAuthStatusEvent());
    } catch (e) {
      // If bloc is not found, navigate to login
      debugPrint('Error accessing EnhancedLoginBloc: $e');
      nav.navigateTo(Routes.login);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EnhancedLoginBloc, BaseState<UserProfileEntity>>(
      listener: (context, state) {
        if (state is LoadedState<UserProfileEntity>) {
          nav.navigateTo(Routes.home);
        } else if (state is ErrorState<UserProfileEntity>) {
          nav.navigateTo(Routes.login);
        }
      },
      builder: (context, state) {
        return const FScaffold(
          body: Stack(
            children: [
              Center(
                child: FImage(
                  assetType: FoodAssetType.svg,
                  assetPath: Assets.svgsLogo,
                  width: 121,
                  height: 60,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: FImage(
                  assetType: FoodAssetType.svg,
                  assetPath: Assets.svgsSplashDesign,
                  width: 295,
                  height: 295,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
