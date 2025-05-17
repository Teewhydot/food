import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/home/presentation/screens/home.dart';
import 'package:food/food/features/home/presentation/widgets/cart_widget.dart';
import 'package:food/food/features/home/presentation/widgets/search_widget.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../widgets/food_widget.dart';
import '../widgets/restaurant_widget.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<String> recentKeywords = ["Jello", "Pizza", "Burger", "Pasta", "Salad"];
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
                    BackWidget(color: kBackWidgetColor),
                    20.horizontalSpace,
                    FText(
                      text: "Search",
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: kTextColorDark,
                    ),
                  ],
                ),
                Spacer(),
                CartWidget().paddingOnly(right: AppConstants.defaultPadding.w),
              ],
            ),
            25.verticalSpace,
            SearchWidget(),
            25.verticalSpace,
            SectionHead(title: "Recent Keywords", isActionVisible: false),
            20.verticalSpace,
            SizedBox(
              height: 56.h,
              child: ListView.separated(
                separatorBuilder: (context, index) => 10.horizontalSpace,
                scrollDirection: Axis.horizontal,
                itemCount: recentKeywords.length,
                itemBuilder: (context, index) {
                  return KeywordWidget(keyword: recentKeywords[index]);
                },
              ),
            ),
            30.verticalSpace,
            SectionHead(title: "Suggested Restaurants", isActionVisible: false),
            20.verticalSpace,
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                spacing: 16,
                children: [
                  SuggestedRestaurant(name: "Pixel Restaurant", rating: "4.5"),
                  SuggestedRestaurant(name: "Pixel Restaurant", rating: "4.5"),

                  SuggestedRestaurant(name: "Pixel Restaurant", rating: "4.5"),
                  SuggestedRestaurant(name: "Pixel Restaurant", rating: "4.5"),
                ],
              ),
            ).paddingOnly(right: AppConstants.defaultPadding.w),
            20.verticalSpace,
            SectionHead(title: "Popular Fast Food", isActionVisible: false),
            40.verticalSpace,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 10.w,
                children: [
                  PopularFastFood(
                    image: "assets/images/food1.png",
                    name: "Pizza",
                    restaurantName: "4.5",
                    price: "\$10.00",
                  ),
                  PopularFastFood(
                    image: "assets/images/food1.png",
                    name: "Pizza",
                    restaurantName: "4.5",
                    price: "\$10.00",
                  ),
                  PopularFastFood(
                    image: "assets/images/food1.png",
                    name: "Pizza",
                    restaurantName: "4.5",
                    price: "\$10.00",
                  ),
                  PopularFastFood(
                    image: "assets/images/food1.png",
                    name: "Pizza",
                    restaurantName: "4.5",
                    price: "\$10.00",
                  ),
                ],
              ),
            ),
            80.verticalSpace,
            Wrap(
              direction: Axis.horizontal,
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.start,
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              runSpacing: 50,
              children: [
                PopularFastFood(
                  image: "assets/images/food1.png",
                  name: "Pizza",
                  restaurantName: "4.5",
                  price: "\$10.00",
                ),
                PopularFastFood(
                  image: "assets/images/food1.png",
                  name: "Pizza",
                  restaurantName: "4.5",
                  price: "\$10.00",
                ),
                PopularFastFood(
                  image: "assets/images/food1.png",
                  name: "Pizza",
                  restaurantName: "4.5",
                  price: "\$10.00",
                ),
                PopularFastFood(
                  image: "assets/images/food1.png",
                  name: "Pizza",
                  restaurantName: "4.5",
                  price: "\$10.00",
                ),
              ],
            ).paddingOnly(right: AppConstants.defaultPadding),
          ],
        ).paddingOnly(left: AppConstants.defaultPadding.w),
      ),
    );
  }
}

class KeywordWidget extends StatelessWidget {
  final String keyword;
  const KeywordWidget({super.key, required this.keyword});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(33.r),
          border: Border.all(color: kGreyColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: kGreyColor.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FText(
          text: keyword,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: kTextColorDark,
        ).paddingSymmetric(horizontal: 20.w),
      ),
    );
  }
}
