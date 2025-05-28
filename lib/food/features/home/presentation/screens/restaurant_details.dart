import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/features/home/presentation/screens/home.dart';
import 'package:food/food/features/home/presentation/widgets/details_skeleton_widget.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../generated/assets.dart';
import '../../../../components/image.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../widgets/category_widget.dart';
import '../widgets/food_widget.dart';

class RestaurantDetails extends StatefulWidget {
  const RestaurantDetails({super.key});

  @override
  State<RestaurantDetails> createState() => _RestaurantDetailsState();
}

class _RestaurantDetailsState extends State<RestaurantDetails> {
  List<String> categories = [
    "All",
    "Jello",
    "Pizza",
    "Burger",
    "Pasta",
    "Salad",
  ];
  String selectedCategory = "All";
  final nav = GetIt.instance<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return DetailsSkeletonWidget(
      hasBottomWidget: false,
      hasIndicator: true,
      isRestaurant: true,
      icon: Ionicons.menu,
      bodyWidget: Column(
        children: [
          // Add your body widget here
          Row(
            spacing: 24,
            children: [
              Row(
                children: [
                  FImage(
                    assetPath: Assets.svgsRating,
                    assetType: FoodAssetType.svg,
                    width: 20,
                    height: 20,
                  ),
                  4.horizontalSpace,
                  FText(
                    text: "4.9",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextColorDark,
                  ),
                ],
              ),
              Row(
                children: [
                  FImage(
                    assetPath: Assets.svgsTruck,
                    assetType: FoodAssetType.svg,
                    width: 20,
                    height: 20,
                  ),
                  4.horizontalSpace,
                  FText(
                    text: "20m",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextColorDark,
                  ),
                ],
              ),
              Row(
                children: [
                  FImage(
                    assetPath: Assets.svgsClock,
                    assetType: FoodAssetType.svg,
                    width: 20,
                    height: 20,
                  ),
                  4.horizontalSpace,
                  FText(
                    text: "10",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextColorDark,
                  ),
                ],
              ),
            ],
          ),
          7.verticalSpace,
          FText(
            text: "Spicy Restaurant",
            fontSize: 20,
            fontWeight: FontWeight.w700,
            alignment: MainAxisAlignment.start,
          ),
          21.verticalSpace,
          Row(
            spacing: 24,
            children: [
              Row(
                children: [
                  FImage(
                    assetPath: Assets.svgsRating,
                    assetType: FoodAssetType.svg,
                    width: 20,
                    height: 20,
                  ),
                  4.horizontalSpace,
                  FText(
                    text: "4.9",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextColorDark,
                  ),
                ],
              ),
              Row(
                children: [
                  FImage(
                    assetPath: Assets.svgsTruck,
                    assetType: FoodAssetType.svg,
                    width: 20,
                    height: 20,
                  ),
                  4.horizontalSpace,
                  FText(
                    text: "20m",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextColorDark,
                  ),
                ],
              ),
              Row(
                children: [
                  FImage(
                    assetPath: Assets.svgsClock,
                    assetType: FoodAssetType.svg,
                    width: 20,
                    height: 20,
                  ),
                  4.horizontalSpace,
                  FText(
                    text: "10",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextColorDark,
                  ),
                ],
              ),
            ],
          ),
          21.verticalSpace,
          FWrapText(
            textAlign: TextAlign.start,
            color: kContainerColor,
            text:
                "Maecenas sed diam eget risus varius blandit sit amet non magna. Integer posuere erat a ante venenatis dapibus posuere velit aliquet.",
          ),
          20.verticalSpace,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 16,
              children:
                  categories.map((category) {
                    return CategoryWidget(
                      showImage: true,
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
          20.verticalSpace,
          SectionHead(title: selectedCategory, isActionVisible: false),
          40.verticalSpace,
          Wrap(
            direction: Axis.horizontal,
            spacing: 20,
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

          // Add more widgets as needed
        ],
      ),
    );
  }
}
