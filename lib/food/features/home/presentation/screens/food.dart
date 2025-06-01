import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons/buttons.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/services/navigation_service/nav_config.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/core/utils/app_utils.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/home/presentation/screens/search.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../widgets/circle_widget.dart';
import '../widgets/section_head.dart';

class Food extends StatelessWidget {
  const Food({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();
    return FScaffold(
      useSafeArea: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    BackWidget(color: kContainerColor),
                    17.horizontalSpace,
                    FoodContainer(
                      width: 102,
                      height: 45,
                      borderRadius: 33,
                      color: kWhiteColor,
                      hasBorder: true,
                      borderColor: kGreyColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              FText(text: "Burger"),
                              5.horizontalSpace,
                              FImage(
                                assetPath: Assets.svgsArrowDown,
                                assetType: FoodAssetType.svg,
                                width: 10,
                                height: 10,
                                svgAssetColor: kPrimaryColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  children: [
                    FoodContainer(
                      width: 46,
                      height: 46,
                      color: kBlackColor,
                      borderRadius: 46,
                      child: Icon(Icons.search, color: kWhiteColor),
                    ),
                    CircleWidget(
                      onTap: () {
                        DFoodUtils.showDialogContainer(
                          context: context,
                          pop: true,
                          isDismissible: true,
                          insetPadding: EdgeInsets.symmetric(horizontal: 14),
                          contentPadding: EdgeInsets.symmetric(horizontal: 14),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  FText(text: "Filter your search"),
                                  CircleWidget(
                                    color: kGreyColor,
                                    onTap: () {
                                      nav.goBack();
                                    },
                                    radius: 22.5,
                                    child: Icon(Icons.close_outlined),
                                  ),
                                ],
                              ),
                              20.verticalSpace,
                              SectionHead(
                                title: "Offers",
                                isActionVisible: false,
                              ),
                              10.verticalSpace,
                              Wrap(
                                spacing: 5,
                                direction: Axis.horizontal,
                                runSpacing: 10,
                                children: [
                                  KeywordWidget(keyword: "Delivery"),
                                  KeywordWidget(keyword: "Pick-up"),
                                  KeywordWidget(keyword: "Cash"),
                                  KeywordWidget(keyword: "Online Payment"),
                                ],
                              ),
                              20.verticalSpace,
                              SectionHead(
                                title: "Delivery time",
                                isActionVisible: false,
                              ),
                              10.verticalSpace,
                              Wrap(
                                spacing: 5,
                                direction: Axis.horizontal,
                                runSpacing: 10,
                                children: [
                                  KeywordWidget(keyword: "10-20m"),
                                  KeywordWidget(keyword: "30-50m"),
                                  KeywordWidget(keyword: "1-2h"),
                                ],
                              ),
                              20.verticalSpace,
                              SectionHead(
                                title: "Pricing",
                                isActionVisible: false,
                              ),
                              10.verticalSpace,
                              Wrap(
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                spacing: 5,
                                direction: Axis.horizontal,
                                runSpacing: 10,
                                children: [
                                  FoodContainer(
                                    width: 48,
                                    height: 48,
                                    borderRadius: 48,
                                    borderWidth: 1,
                                    borderColor: kGreyColor,
                                    hasBorder: true,
                                    color: kWhiteColor,
                                    child: FText(text: "\$"),
                                  ),
                                  FoodContainer(
                                    width: 48,
                                    height: 48,
                                    borderRadius: 48,
                                    borderWidth: 1,
                                    borderColor: kGreyColor,
                                    hasBorder: true,
                                    color: kWhiteColor,
                                    child: FText(text: "\$\$"),
                                  ),
                                  FoodContainer(
                                    width: 48,
                                    height: 48,
                                    borderRadius: 48,
                                    borderWidth: 1,
                                    borderColor: kGreyColor,
                                    hasBorder: true,
                                    color: kWhiteColor,
                                    child: FText(text: "\$\$\$"),
                                  ),
                                ],
                              ),
                              20.verticalSpace,
                              SectionHead(
                                title: "Rating",
                                isActionVisible: false,
                              ),
                              10.verticalSpace,
                              RatingBar(
                                initialRating: 3,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                ratingWidget: RatingWidget(
                                  full: FoodContainer(
                                    width: 48,
                                    height: 48,
                                    borderRadius: 48,
                                    hasBorder: true,
                                    borderColor: kGreyColor,
                                    color: kWhiteColor,
                                    child: Icon(
                                      Icons.star,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  empty: FoodContainer(
                                    width: 48,
                                    height: 48,
                                    borderRadius: 48,
                                    hasBorder: true,
                                    borderColor: kGreyColor,
                                    color: kWhiteColor,
                                    child: Icon(Icons.star, color: kGreyColor),
                                  ),
                                  half: SizedBox(),
                                ),
                                itemPadding: EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                onRatingUpdate: (rating) {
                                  print(rating);
                                },
                              ),
                              20.verticalSpace,
                              FButton(buttonText: "Filter", width: 1.sw),
                            ],
                          ).paddingAll(20),
                        );
                      },
                      radius: 23,
                      color: kGreyColor,
                      child: FImage(
                        assetPath: Assets.svgsFilter,
                        assetType: FoodAssetType.svg,
                        width: 22,
                        height: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ).paddingOnly(right: AppConstants.defaultPadding),
            24.verticalSpace,
            SectionHead(title: "Popular Burgers", isActionVisible: false),
            40.verticalSpace,
            Wrap(
              direction: Axis.horizontal,
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.start,
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              runSpacing: 50,
              // children: [
              //   FoodWidget(
              //     image: "assets/images/food1.png",
              //     name: "Pizza",
              //     rating: "4.5",
              //     price: "\$10.00",
              //   ),
              //   FoodWidget(
              //     image: "assets/images/food1.png",
              //     name: "Pizza",
              //     rating: "4.5",
              //     price: "\$10.00",
              //   ),
              //   FoodWidget(
              //     image: "assets/images/food1.png",
              //     name: "Pizza",
              //     rating: "4.5",
              //     price: "\$10.00",
              //   ),
              //   FoodWidget(
              //     image: "assets/images/food1.png",
              //     name: "Pizza",
              //     rating: "4.5",
              //     price: "\$10.00",
              //   ),
              // ],
            ).paddingOnly(right: AppConstants.defaultPadding),
            40.verticalSpace,
            SectionHead(
              title: "Open Restaurants",
            ).paddingOnly(right: AppConstants.defaultPadding.w),
            20.verticalSpace,
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                spacing: 16,
                // children: [
                //   RestaurantWidget(
                //     name: "Burger King",
                //     rating: "4.5",
                //     distance: "2.5 km",
                //     time: "30 min",
                //     categories: ["Burger", "Fast Food"],
                //   ),
                //   RestaurantWidget(
                //     name: "Pizza Hut",
                //     rating: "4.8",
                //     distance: "3.0 km",
                //     time: "25 min",
                //     categories: ["Pizza", "Italian"],
                //   ),
                //   RestaurantWidget(
                //     name: "Pizza Hut",
                //     rating: "4.8",
                //     distance: "3.0 km",
                //     time: "25 min",
                //     categories: ["Pizza", "Italian"],
                //   ),
                //   RestaurantWidget(
                //     name: "Pizza Hut",
                //     rating: "4.8",
                //     distance: "3.0 km",
                //     time: "25 min",
                //     categories: ["Pizza", "Italian"],
                //   ),
                // ],
              ),
            ).paddingOnly(right: AppConstants.defaultPadding.w),
          ],
        ).paddingOnly(left: AppConstants.defaultPadding),
      ),
    );
  }
}
