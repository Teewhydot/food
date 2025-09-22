import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/helpers/user_extensions.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/home/manager/user_profile/enhanced_user_profile_cubit.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/food/features/home/presentation/widgets/personal_info_widget.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:dartz/dartz.dart' hide State;

import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../domain/failures/failures.dart';
import '../../domain/entities/profile.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  late Stream<Either<Failure, UserProfileEntity>> _userProfileStream;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    _userProfileStream = context
        .read<EnhancedUserProfileCubit>()
        .watchUserProfile(context.readCurrentUserId ?? "")
        .distinct();
  }

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();
    return StreamBuilder<Either<Failure, UserProfileEntity>>(
      stream: _userProfileStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No profile data'));
        }

        return _buildPersonalInfoScaffold(nav, snapshot.data!);
      },
    );
  }

  Widget _buildPersonalInfoScaffold(NavigationService nav, Either<Failure, UserProfileEntity> profile) {
    return FScaffold(
      customScroll: true,
      appBarWidget: _buildAppBar(nav, profile),
      body: _buildBody(profile),
    );
  }

  Widget _buildAppBar(NavigationService nav, Either<Failure, UserProfileEntity> profile) {
    return GestureDetector(
      onTap: () {
        nav.navigateTo(Routes.home);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              BackWidget(color: kGreyColor),
              20.horizontalSpace,
              FText(
                text: "Personal Info",
                fontSize: 17.sp,
                fontWeight: FontWeight.w400,
                color: kBlackColor,
              ),
            ],
          ),
          FText(
            text: "Edit".toUpperCase(),
            fontSize: 17.sp,
            fontWeight: FontWeight.w400,
            color: kPrimaryColor,
            decoration: TextDecoration.underline,
            onTap: () {
              nav.navigateTo(
                Routes.editProfile,
                arguments: profile.fold((l) => null, (r) => r),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(Either<Failure, UserProfileEntity> profile) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProfileImage(profile),
          32.verticalSpace,
          _buildProfileInfo(profile),
          _buildInfoContainer(profile),
        ],
      ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
    );
  }

  Widget _buildProfileImage(Either<Failure, UserProfileEntity> profile) {
    return CircleWidget(
      radius: 80,
      color: kPrimaryColor,
      child: FImage(
        assetPath: profile.fold(
          (l) => 'https://www.gravatar.com/avatar/',
          (r) => r.profileImageUrl ?? 'https://www.gravatar.com/avatar/',
        ),
        assetType: FoodAssetType.network,
        borderRadius: 70,
        width: 140,
        height: 140,
      ),
    );
  }

  Widget _buildProfileInfo(Either<Failure, UserProfileEntity> profile) {
    return Column(
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
        FWrapText(
          text: profile.fold(
            (l) => 'Guest User',
            (r) => '${r.bio}'.trim(),
          ),
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          color: kContainerColor,
          textAlign: TextAlign.start,
        ),
        18.verticalSpace,
      ],
    );
  }

  Widget _buildInfoContainer(Either<Failure, UserProfileEntity> profile) {
    return Container(
      width: 1.sw,
      decoration: BoxDecoration(
        color: kLightGreyColor,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PersonalInfoWidget(
            field: 'full name',
            value: profile.fold(
              (l) => 'Dev: Abubakar Issa',
              (r) => '${r.firstName} ${r.lastName}'.trim(),
            ),
            child: FImage(
              assetPath: Assets.svgsPersonalInfo,
              assetType: FoodAssetType.svg,
              width: 12,
              height: 14,
            ),
          ),
          PersonalInfoWidget(
            field: 'email',
            value: profile.fold(
              (l) => 'Dev: tchipsical@gmail.com',
              (r) => r.email.trim(),
            ),
            child: FImage(
              assetPath: Assets.svgsEmail,
              assetType: FoodAssetType.svg,
              width: 12,
              height: 14,
            ),
          ),
          PersonalInfoWidget(
            field: 'phone number',
            value: profile.fold(
              (l) => 'Dev: 08068787087',
              (r) => r.phoneNumber.trim(),
            ),
            child: FImage(
              assetPath: Assets.svgsPhoneNum,
              assetType: FoodAssetType.svg,
              width: 12,
              height: 14,
            ),
          ),
        ],
      ).paddingAll(20),
    );
  }
}
