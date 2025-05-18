import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/core/utils/app_utils.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';

import '../../../../components/buttons/buttons.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/cart_widget.dart';
import '../widgets/category_widget.dart';
import '../widgets/circle_widget.dart';
import '../widgets/restaurant_widget.dart';
import '../widgets/search_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String selectedCategory = "All";

  final List<String> categories = ["All", "Hot Dog", "Burger", "Pizza"];

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            50.verticalSpace,
            GestureDetector(
              onTap: () {
                DFoodUtils.showDialogContainer(
                  pop: true,
                  context: context,
                  contentPadding: EdgeInsets.zero,
                  child: Container(
                    height: 395.h,
                    width: 382.w,
                    decoration: BoxDecoration(
                      color: kWhiteColor,
                      borderRadius: BorderRadius.circular(35).r,
                      gradient: const LinearGradient(
                        colors: [kGradientColor2, kGradientColor1],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomCenter,
                        stops: [0.1, 0.9],
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Column(
                          children: [
                            37.verticalSpace,
                            FImage(
                              assetPath: Assets.svgsOfferBg,
                              assetType: FoodAssetType.svg,
                              width: 270,
                              height: 190,
                            ),
                          ],
                        ),
                        Positioned(
                          top: -15,
                          right: -15,
                          child: CircleWidget(
                            radius: 22,
                            color: kCloseColor,
                            child: Icon(Icons.close, size: 10),
                          ),
                        ),
                        Positioned(
                          top: 85,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              FText(
                                text: "Hurry now",
                                fontSize: 41,
                                color: kWhiteColor,
                                fontWeight: FontWeight.w800,
                              ),
                              50.verticalSpace,
                              FText(
                                text: "#1234CD2",
                                fontSize: 24,
                                color: kWhiteColor,
                                fontWeight: FontWeight.w600,
                              ),
                              40.verticalSpace,
                              FText(
                                text: "Use the coupon to get 50% off",
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: kWhiteColor,
                              ),
                              50.verticalSpace,
                              FButton(
                                buttonText: "GOT IT",
                                onPressed: () {
                                  Get.back();
                                },
                                borderColor: kWhiteColor,
                                color: Colors.transparent,
                                textColor: kWhiteColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Row(
                    children: [
                      CircleWidget(
                        radius: 22.5,
                        color: kGreyColor,
                        child: FImage(
                          assetPath: Assets.svgsDelivery,
                          assetType: FoodAssetType.svg,
                          width: 12,
                          height: 16,
                        ),
                      ),
                      18.horizontalSpace,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FText(
                            text: "Deliver to",
                            fontSize: 14,
                            color: kTextColorDark,
                          ),
                          Row(
                            children: [
                              FText(
                                text: "Lagos, Nigeria",
                                fontSize: 14,
                                color: kAddressColor,
                              ),
                              8.horizontalSpace,
                              FImage(
                                assetPath: Assets.svgsArrowDown,
                                assetType: FoodAssetType.svg,
                                width: 10,
                                height: 10,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  CartWidget().paddingOnly(
                    right: AppConstants.defaultPadding.w,
                  ),
                ],
              ),
            ),
            24.verticalSpace,
            Row(
              children: [
                FText(
                  text: "Hello, John",
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: kTextColorDark,
                  alignment: MainAxisAlignment.start,
                ),
                8.horizontalSpace,
                FText(
                  text: "Good Afternoon",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kTextColorDark,
                  alignment: MainAxisAlignment.start,
                ),
              ],
            ),
            16.verticalSpace,
            SearchWidget(),
            32.verticalSpace,
            SectionHead().paddingOnly(right: AppConstants.defaultPadding.w),
            20.verticalSpace,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 16,
                children:
                    categories.map((category) {
                      return CategoryWidget(
                        text: category,
                        isSelected: selectedCategory == category,
                        onTap: () {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      );
                    }).toList(),
              ),
            ),
            32.verticalSpace,
            SectionHead(
              title: "Open Restaurants",
            ).paddingOnly(right: AppConstants.defaultPadding.w),
            20.verticalSpace,
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                spacing: 16,
                children: [
                  RestaurantWidget(
                    name: "Burger King",
                    rating: "4.5",
                    distance: "2.5 km",
                    time: "30 min",
                    categories: ["Burger", "Fast Food"],
                  ),
                  RestaurantWidget(
                    name: "Pizza Hut",
                    rating: "4.8",
                    distance: "3.0 km",
                    time: "25 min",
                    categories: ["Pizza", "Italian"],
                  ),
                  RestaurantWidget(
                    name: "Pizza Hut",
                    rating: "4.8",
                    distance: "3.0 km",
                    time: "25 min",
                    categories: ["Pizza", "Italian"],
                  ),
                  RestaurantWidget(
                    name: "Pizza Hut",
                    rating: "4.8",
                    distance: "3.0 km",
                    time: "25 min",
                    categories: ["Pizza", "Italian"],
                  ),
                ],
              ),
            ).paddingOnly(right: AppConstants.defaultPadding.w),
          ],
        ).paddingOnly(left: AppConstants.defaultPadding.w),
      ),
    );
  }
}

class SectionHead extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback? action;
  final bool isActionVisible;
  const SectionHead({
    super.key,
    this.title = "All categories",
    this.actionText = "See All",
    this.action,
    this.isActionVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FText(
          text: title,
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: kTextColorDark,
        ),
        if (isActionVisible)
          Row(
            children: [
              FText(
                text: actionText,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: kTextColorDark,
              ),
              8.horizontalSpace,
              FImage(
                assetPath: Assets.svgsArrowRight,
                assetType: FoodAssetType.svg,
                width: 10,
                height: 10,
              ),
            ],
          ),
      ],
    );
  }
}
