import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';

import '../widgets/cart_widget.dart';
import '../widgets/category_widget.dart';
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
            Row(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22.5,
                      backgroundColor: kGreyColor,
                      child: FImage(
                        assetPath: Assets.svgsDelivery,
                        imageType: FoodImageType.svg,
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
                              imageType: FoodImageType.svg,
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
                CartWidget().paddingOnly(right: 24.w),
              ],
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
            SectionHead().paddingOnly(right: 24.w),
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
            SectionHead(title: "Open Restaurants").paddingOnly(right: 24.w),
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
            ).paddingOnly(right: 24.w),
          ],
        ).paddingOnly(left: 24.w),
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
                imageType: FoodImageType.svg,
                width: 10,
                height: 10,
              ),
            ],
          ),
      ],
    );
  }
}
