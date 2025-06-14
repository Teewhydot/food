import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/home/manager/user_profile/user_profile_cubit.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/food/features/home/presentation/widgets/menu_section_widget.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/services/navigation_service/nav_config.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  void initState() {
    super.initState();
    // Load user profile when the menu screen is initialized
    BlocProvider.of<UserProfileCubit>(context).loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();

    return BlocBuilder<UserProfileCubit, UserProfileState>(
      builder: (context, state) {
        if (state is UserProfileLoaded) {
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
                        16.verticalSpace,
                        MenuSectionWidget(
                          title: "Payment Methods",
                          child: FImage(
                            assetPath: Assets.svgsPaymentMethod,
                            assetType: FoodAssetType.svg,
                            width: 12,
                            height: 14,
                          ),
                          onTap: () {
                            nav.navigateTo(Routes.paymentMethod);
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
                          title: "Settings",
                          child: FImage(
                            assetPath: Assets.svgsSettings,
                            assetType: FoodAssetType.svg,
                            width: 12,
                            height: 14,
                          ),
                          onTap: () {
                            nav.navigateTo(Routes.settings);
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
                          title: "Log out",
                          child: FImage(
                            assetPath: Assets.svgsLogout,
                            assetType: FoodAssetType.svg,
                            width: 12,
                            height: 14,
                          ),
                          onTap: () {
                            nav.navigateAndReplaceAll(Routes.login);
                          },
                        ),
                      ],
                    ).paddingAll(20),
                  ),
                  20.verticalSpace,
                ],
              ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
            ),
          );
        } else if (state is UserProfileLoading) {
          return Center(child: CircularProgressIndicator(color: kPrimaryColor));
        } else if (state is UserProfileError) {
          return Center(
            child: FText(
              text: state.errorMessage,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: Colors.red,
            ),
          );
        }
        return SizedBox();
      },
    );
  }
}
