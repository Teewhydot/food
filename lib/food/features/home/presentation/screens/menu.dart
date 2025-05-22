import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/food/features/home/presentation/widgets/menu_section_widget.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      body: Column(
        children: [
          50.verticalSpace,
          Row(
            children: [
              BackWidget(color: kGreyColor),
              20.horizontalSpace,
              FText(
                text: "Profile",
                fontSize: 17.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                Row(
                  children: [
                    CircleWidget(radius: 50, color: kPrimaryColor),
                    32.horizontalSpace,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FText(
                          text: "Vishal Dharma",
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                          color: kBlackColor,
                        ),
                        8.verticalSpace,
                        FText(
                          text: "I hate fast food",
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: kContainerColor,
                        ),
                      ],
                    ),
                  ],
                ),
                32.verticalSpace,
                FoodContainer(
                  height: 136,
                  width: 1.sw,
                  color: kLightGreyColor,

                  child: Column(
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
                      ),
                      16.verticalSpace,
                      MenuSectionWidget(
                        title: "Addresses",
                        child: FImage(
                          assetPath: Assets.svgsAddress,
                          assetType: FoodAssetType.svg,
                          width: 12,
                          height: 14,
                        ),
                      ),
                    ],
                  ).paddingAll(20),
                ),
                20.verticalSpace,
                FoodContainer(
                  color: kLightGreyColor,
                  height: 248,
                  width: 1.sw,
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
                      ),
                      16.verticalSpace,
                      MenuSectionWidget(
                        title: "Favourites",
                        child: FImage(
                          assetPath: Assets.svgsFavourite,
                          assetType: FoodAssetType.svg,
                          width: 12,
                          height: 14,
                        ),
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
                      ),
                      16.verticalSpace,
                      MenuSectionWidget(
                        title: "Payment Methods",
                        child: FImage(
                          assetPath: Assets.svgsPaymentMethod,
                          assetType: FoodAssetType.svg,
                          width: 12,
                          height: 14,
                        ),
                      ),
                    ],
                  ).paddingAll(20),
                ),
                20.verticalSpace,
                FoodContainer(
                  color: kLightGreyColor,
                  height: 192,
                  width: 1.sw,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MenuSectionWidget(
                        title: "FAQ",
                        child: FImage(
                          assetPath: Assets.svgsFaq,
                          assetType: FoodAssetType.svg,
                          width: 12,
                          height: 14,
                        ),
                      ),
                      16.verticalSpace,
                      MenuSectionWidget(
                        title: "User review",
                        child: FImage(
                          assetPath: Assets.svgsUserReview,
                          assetType: FoodAssetType.svg,
                          width: 12,
                          height: 14,
                        ),
                      ),
                      16.verticalSpace,
                      MenuSectionWidget(
                        title: "Settings",
                        child: FImage(
                          assetPath: Assets.svgsSettings,
                          assetType: FoodAssetType.svg,
                          width: 12,
                          height: 14,
                        ),
                      ),
                    ],
                  ).paddingAll(20),
                ),
                20.verticalSpace,
                FoodContainer(
                  color: kLightGreyColor,
                  height: 80,
                  width: 1.sw,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MenuSectionWidget(
                        title: "Log out",
                        child: FImage(
                          assetPath: Assets.svgsLogout,
                          assetType: FoodAssetType.svg,
                          width: 12,
                          height: 14,
                        ),
                      ),
                    ],
                  ).paddingAll(20),
                ),
                20.verticalSpace,
              ],
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
    );
  }
}
