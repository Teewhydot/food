import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/helpers/user_extensions.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/manager/auth_bloc/sign_out/sign_out_bloc.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/home/manager/user_profile/enhanced_user_profile_cubit.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/food/features/home/presentation/widgets/menu_section_widget.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/buttons.dart';
import '../../../../core/bloc/managers/bloc_manager.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../domain/failures/failures.dart';
import '../../domain/entities/profile.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> with AutomaticKeepAliveClientMixin {
  late Stream<Either<Failure, UserProfileEntity>> _userProfileStream;
  bool _streamInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_streamInitialized) {
      _initializeStream();
      _streamInitialized = true;
    }
  }

  void _initializeStream() {
    try {
      final userId = context.readCurrentUserId;
      if (userId != null && userId.isNotEmpty) {
        _userProfileStream =
            context
                .read<UserProfileCubit>()
                .watchUserProfile(userId)
                .distinct();
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_streamInitialized) {
          _initializeStream();
          _streamInitialized = true;
        }
      });
    }
  }

  void _retryStreamInitialization() {
    _streamInitialized = false;
    _initializeStream();
    if (mounted) {
      setState(() {});
    }
  }

  void _resetUserData(BuildContext context) {
    try {
      // Clear only user profile data
      context.read<UserProfileCubit>().clearUserProfile();
    } catch (e) {
      // Continue even if reset fails
      debugPrint("Error resetting user data: $e");
    }
  }

  Widget _buildProfileHeader(Either<Failure, UserProfileEntity> profile) {
    return Row(
      children: [
        CircleWidget(
          radius: 50,
          color: kPrimaryColor,
          child: FImage(
            assetPath: profile.fold((l) => "", (r) => r.profileImageUrl) ?? "",
            assetType: FoodAssetType.network,
            borderRadius: 70,
            width: 140,
            height: 140,
          ),
        ),
        32.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FText(
                text: profile.fold(
                  (l) => 'Guest User',
                  (r) => '${r.firstName} ${r.lastName}'.trim(),
                ),
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: kBlackColor,
                alignment: MainAxisAlignment.start,
              ),
              8.verticalSpace,
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: kWhiteColor,
                  border: Border.all(color: kGreyColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FWrapText(
                    text: profile.fold(
                      (l) => 'No bio available',
                      (r) =>
                          r.bio?.isNotEmpty == true
                              ? r.bio!
                              : 'No bio available',
                    ),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: kContainerColor,
                    alignment: Alignment.topLeft,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final nav = GetIt.instance<NavigationService>();

    if (!_streamInitialized) {
      return FScaffold(
        customScroll: true,
        appBarWidget: Row(
          children: [
            BackWidget(color: kGreyColor),
            20.horizontalSpace,
            FText(
              text: "Menu",
              fontSize: 17.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: kPrimaryColor),
              16.verticalSpace,
              FText(
                text: "Loading profile...",
                fontSize: 14,
                color: kContainerColor,
              ),
            ],
          ),
        ),
      );
    }

    return BlocManager<SignOutBloc, BaseState<dynamic>>(
      bloc: context.read<SignOutBloc>(),
      showLoadingIndicator: true,
      onSuccess: (_, __) {
        nav.navigateAndReplaceAll(Routes.login);
      },
      child: FScaffold(
        customScroll: true,
        appBarWidget: Row(
          children: [
            BackWidget(color: kGreyColor),
            20.horizontalSpace,
            FText(
              text: "Menu",
              fontSize: 17.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<Either<Failure, UserProfileEntity>>(
                stream: _userProfileStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return _buildErrorWidget('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return _buildErrorWidget('No profile data');
                  }
                  return _buildProfileHeader(snapshot.data!);
                },
              ),
              32.verticalSpace,
              Container(
                width: 1.sw,
                decoration: BoxDecoration(
                  color: kLightGreyColor,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Column(
                  spacing: 16,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MenuSectionWidget(
                      title: "Personal Info",
                      child: FImage(
                        assetPath: Assets.svgsPersonalInfo,
                        assetType: FoodAssetType.svg,
                        width: 12,
                        height: 14,
                      ),
                      onTap: () {
                        nav.navigateTo(Routes.personalInfo);
                      },
                    ),
                    MenuSectionWidget(
                      title: "Addresses",
                      child: FImage(
                        assetPath: Assets.svgsAddress,
                        assetType: FoodAssetType.svg,
                        width: 12,
                        height: 14,
                      ),
                      onTap: () {
                        nav.navigateTo(Routes.address);
                      },
                    ),
                    MenuSectionWidget(
                      title: "Order History",
                      child: FImage(
                        assetPath: Assets.svgsTruck,
                        assetType: FoodAssetType.svg,
                        width: 12,
                        height: 14,
                      ),
                      onTap: () {
                        nav.navigateTo(Routes.orderHistory);
                      },
                    ),
                  ],
                ).paddingAll(20),
              ),
              20.verticalSpace,
              Container(
                width: 1.sw,
                decoration: BoxDecoration(
                  color: kLightGreyColor,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MenuSectionWidget(
                      title: "Cart",
                      child: FImage(
                        assetPath: Assets.svgsCart,
                        assetType: FoodAssetType.svg,
                        width: 12,
                        height: 14,
                      ),
                      onTap: () {
                        nav.navigateTo(Routes.cart);
                      },
                    ),

                    16.verticalSpace,
                    MenuSectionWidget(
                      title: "Notifications",
                      child: FImage(
                        assetPath: Assets.svgsNotifications,
                        assetType: FoodAssetType.svg,
                        width: 12,
                        height: 14,
                      ),
                      onTap: () {
                        nav.navigateTo(Routes.notifications);
                      },
                    ),
                  ],
                ).paddingAll(20),
              ),
              20.verticalSpace,
              Container(
                width: 1.sw,
                decoration: BoxDecoration(
                  color: kLightGreyColor,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MenuSectionWidget(
                      title: "Update Password",
                      child: FImage(
                        assetPath: Assets.svgsSettings,
                        assetType: FoodAssetType.svg,
                        width: 12,
                        height: 14,
                      ),
                      onTap: () {
                        nav.navigateTo(Routes.updatePassword);
                      },
                    ),
                    16.verticalSpace,
                    MenuSectionWidget(
                      title: "Log out",
                      child: FImage(
                        assetPath: Assets.svgsLogout,
                        assetType: FoodAssetType.svg,
                        width: 12,
                        height: 14,
                      ),
                      onTap: () {
                        // Reset user data before signing out
                        _resetUserData(context);
                        context.read<SignOutBloc>().add(SignOutRequestEvent());
                      },
                    ),
                  ],
                ).paddingAll(20),
              ),
              20.verticalSpace,
            ],
          ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FText(
            text: message,
            color: kErrorColor,
            fontSize: 14,
            textAlign: TextAlign.center,
          ),
          16.verticalSpace,
          FButton(
            buttonText: "Retry",
            width: 120,
            height: 40,
            onPressed: _retryStreamInitialization,
          ),
        ],
      ),
    );
  }
}
