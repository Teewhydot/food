import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/helpers/extensions.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/home/manager/user_profile/user_profile_cubit.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/food/features/home/presentation/widgets/personal_info_widget.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/services/navigation_service/nav_config.dart';

class PersonalInfo extends StatelessWidget {
  const PersonalInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();
    // done
    return BlocBuilder<UserProfileCubit, UserProfileState>(
      builder: (context, state) {
        if (state is UserProfileLoaded) {
          return FScaffold(
            hasAppBar: true,
            appBarWidget: GestureDetector(
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
                    decorations: [TextDecoration.underline],
                  ).onTap(() {
                    nav.navigateTo(Routes.editProfile);
                  }),
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleWidget(radius: 50, color: kPrimaryColor),
                      32.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FText(
                              text:
                                  "${state.userProfile.firstName} ${state.userProfile.lastName}",
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w500,
                              color: kBlackColor,
                              alignment: MainAxisAlignment.start,
                            ),
                            8.verticalSpace,
                            FWrapText(
                              text: state.userProfile.bio ?? "No bio",
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                              color: kContainerColor,
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),
                    ],
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
                        PersonalInfoWidget(
                          field: 'full name',
                          value:
                              "${state.userProfile.firstName} ${state.userProfile.lastName}",
                          child: FImage(
                            assetPath: Assets.svgsPersonalInfo,
                            assetType: FoodAssetType.svg,
                            width: 12,
                            height: 14,
                          ),
                        ),
                        PersonalInfoWidget(
                          field: 'email',
                          value: state.userProfile.email,
                          child: FImage(
                            assetPath: Assets.svgsEmail,
                            assetType: FoodAssetType.svg,
                            width: 12,
                            height: 14,
                          ),
                        ),
                        PersonalInfoWidget(
                          field: 'phone number',
                          value: state.userProfile.phoneNumber,
                          child: FImage(
                            assetPath: Assets.svgsPhoneNum,
                            assetType: FoodAssetType.svg,
                            width: 12,
                            height: 14,
                          ),
                        ),
                      ],
                    ).paddingAll(20),
                  ),
                ],
              ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
            ),
          );
        }
        return SizedBox();
      },
    );
  }
}
