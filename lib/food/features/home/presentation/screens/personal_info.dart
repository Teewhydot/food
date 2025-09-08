import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/helpers/user_extensions.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
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
    return FScaffold(
      customScroll: true,
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
              decoration: TextDecoration.underline,
              onTap: () {
                nav.navigateTo(
                  Routes.editProfile,
                  arguments: context.readUser(),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleWidget(radius: 80, color: kPrimaryColor),
            32.verticalSpace,
            Column(
              children: [
                FText(
                  text:
                      "${context.watchUser()?.firstName} ${context.watchUser()?.lastName}",
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: kBlackColor,
                  textAlign: TextAlign.center,
                  alignment: MainAxisAlignment.center,
                ),
                8.verticalSpace,
                FWrapText(
                  text: context.watchUser()?.bio ?? "No bio",
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: kContainerColor,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
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
                        "${context.watchUser()?.firstName} ${context.watchUser()?.lastName}",
                    child: FImage(
                      assetPath: Assets.svgsPersonalInfo,
                      assetType: FoodAssetType.svg,
                      width: 12,
                      height: 14,
                    ),
                  ),
                  PersonalInfoWidget(
                    field: 'email',
                    value: context.currentUserEmail ?? "",
                    child: FImage(
                      assetPath: Assets.svgsEmail,
                      assetType: FoodAssetType.svg,
                      width: 12,
                      height: 14,
                    ),
                  ),
                  PersonalInfoWidget(
                    field: 'phone number',
                    value: context.watchUser()!.phoneNumber,
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
}
