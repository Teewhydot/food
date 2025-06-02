import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/home/presentation/widgets/cart_widget.dart';
import 'package:food/food/features/home/presentation/widgets/search_widget.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/restaurant_food_category.dart';
import '../widgets/restaurant_widget.dart';
import '../widgets/section_head.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final nav = GetIt.instance<NavigationService>();

  List<String> recentKeywords = ["Jello", "Pizza", "Burger"];
  final List<Restaurant> restaurantList = [
    Restaurant(
      id: Uuid().v4(),
      name: "Burger King",
      imageUrl: "assets/images/restaurant1.png",
      description: "Best burger in town with fresh ingredients",
      categories: [
        RestaurantFoodCategory(
          category: "Burger",
          imageUrl: "imageUrl",
          foods: [
            FoodEntity(
              imageUrl: "assets/images/food2.png",
              name: "Cucumber Chips",
              restaurantName: "Burger King",
              price: 8,
              rating: 4.0,
              category: "Burger",
              id: Uuid().v4(),
              description: "Crispy cucumber chips with a hint of salt",
            ),
            FoodEntity(
              imageUrl: "assets/images/food2.png",
              name: "Samosa",
              restaurantName: "Burger",
              price: 8,
              rating: 4.0,
              category: "Burger",
              id: Uuid().v4(),
              description: "Delicious samosa with a crispy outer layer",
            ),
            FoodEntity(
              imageUrl: "assets/images/food1.png",
              name: "Fabburger",
              restaurantName: "Burger King",
              price: 10,
              rating: 4.5,
              category: "Burger",
              id: Uuid().v4(),
              description: "Fabburger with milkshake and fries",
            ),
            FoodEntity(
              imageUrl: "assets/images/food2.png",
              name: "Shake",
              restaurantName: "Burger King",
              price: 8,
              rating: 4.0,
              category: "Burger",
              id: Uuid().v4(),
              description: "Refreshing milkshake with a hint of chocolate",
            ),
            FoodEntity(
              imageUrl: "assets/images/food2.png",
              name: "Chips",
              restaurantName: "Burger King",
              price: 8,
              rating: 4.0,
              category: "Burger",
              id: Uuid().v4(),
              description: "Crispy chips with a hint of salt",
            ),
            FoodEntity(
              imageUrl: "assets/images/food2.png",
              name: "Burger",
              restaurantName: "Burger",
              price: 8,
              rating: 4.0,
              category: "Fries",
              id: Uuid().v4(),
              description: "Delicious puff puff with a soft texture",
            ),
          ],
        ),
        RestaurantFoodCategory(
          category: "Fast Food",
          imageUrl: "imageUrl",
          foods: [
            // Generate some sample foods for the Fast Food category
            FoodEntity(
              imageUrl: "assets/images/food1.png",
              name: "French Fries",
              restaurantName: "Burger King",
              price: 5,
              rating: 4.2,
              category: "Fast Food",
              id: Uuid().v4(),
              description: "Crispy golden French fries",
            ),
            FoodEntity(
              imageUrl: "assets/images/food2.png",
              name: "Chicken Nuggets",
              restaurantName: "Burger King",
              price: 6,
              rating: 4.1,
              category: "Fast Food",
              id: Uuid().v4(),
              description: "Crispy chicken nuggets with dipping sauce",
            ),
            FoodEntity(
              imageUrl: "assets/images/food2.png",
              name: "Onion Rings",
              restaurantName: "Burger King",
              price: 4,
              rating: 4.0,
              category: "Fast Food",
              id: Uuid().v4(),
              description: "Crispy onion rings with a hint of spice",
            ),
            FoodEntity(
              imageUrl: "assets/images/food2.png",
              name: "Mozzarella Sticks",
              restaurantName: "Burger King",
              price: 7,
              rating: 4.3,
              category: "Fast Food",
              id: Uuid().v4(),
              description: "Crispy mozzarella sticks with marinara sauce",
            ),
            FoodEntity(
              imageUrl: "assets/images/food1.png",
              name: "Chicken Sandwich",
              restaurantName: "Burger King",
              price: 8,
              rating: 4.4,
              category: "Fast Food",
              id: Uuid().v4(),
              description: "Grilled chicken sandwich with lettuce and mayo",
            ),
            FoodEntity(
              imageUrl: "assets/images/food2.png",
              name: "Fish Sandwich",
              restaurantName: "Burger King",
              price: 9,
              rating: 4.5,
              category: "Fast Food",
              id: Uuid().v4(),
              description: "Crispy fish sandwich with tartar sauce",
            ),
            FoodEntity(
              imageUrl: "assets/images/food2.png",
              name: "Veggie Burger",
              restaurantName: "Burger King",
              price: 7,
              rating: 4.0,
              category: "Fast Food",
              id: Uuid().v4(),
              description: "Grilled veggie burger with fresh toppings",
            ),
            FoodEntity(
              imageUrl: "assets/images/food2.png",
              name: "Chicken Fries",
              restaurantName: "Burger King",
              price: 6,
              rating: 4.1,
              category: "Fast Food",
              id: Uuid().v4(),
              description: "Crispy chicken fries with dipping sauce",
            ),
          ],
        ),
      ],
      rating: 4.5,
      reviewCount: 120,
      deliveryTime: 30,
      distance: 2, // Distance in km
    ),
    Restaurant(
      id: Uuid().v4(),
      name: "Pizza Hut",
      imageUrl: "assets/images/restaurant2.png",
      description: "Famous for its delicious pizza and pasta",
      categories: [
        RestaurantFoodCategory(
          category: "Pizza",
          imageUrl: "imageUrl",
          foods: [],
        ),
        RestaurantFoodCategory(
          category: "Italian",
          imageUrl: "imageUrl",
          foods: [],
        ),
      ],
      rating: 4.8,
      reviewCount: 200,
      deliveryTime: 25,
      distance: 3, // Distance in km
    ),
    Restaurant(
      id: Uuid().v4(),
      name: "KFC",
      imageUrl: "assets/images/restaurant3.png",
      description: "Crispy fried chicken with secret recipe",
      categories: [
        RestaurantFoodCategory(
          category: "Chicken",
          imageUrl: "imageUrl",
          foods: [],
        ),
        RestaurantFoodCategory(
          category: "Fast Food",
          imageUrl: "imageUrl",
          foods: [],
        ),
      ],
      rating: 4.3,
      reviewCount: 150,
      deliveryTime: 20,
      distance: 1.5, // Distance in km
    ),
  ];
  List<Restaurant> filteredRestaurants = [];
  String searchQuery = "";
  @override
  void initState() {
    super.initState();
    filteredRestaurants = restaurantList;
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      filteredRestaurants =
          restaurantList
              .where(
                (restaurant) => restaurant.name.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      useSafeArea: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
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
            SearchWidget(onchanged: updateSearchQuery),
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
            // SingleChildScrollView(
            //   scrollDirection: Axis.vertical,
            //   child: Column(
            //     spacing: 16,
            //     children: [
            //       for (var restaurant in suggestedRestaurants)
            //         SuggestedRestaurant(
            //         ),
            //     ],
            //   ),
            // ).paddingOnly(right: AppConstants.defaultPadding.w),
            ListView.builder(
              itemBuilder: (context, index) {
                final restaurant = filteredRestaurants[index];
                return SuggestedRestaurant(
                  restaurant: restaurant,
                  // onTap: () {
                  //   nav.navigateTo(
                  //     Routes.restaurantDetails,
                  //     arguments: restaurantList[index],
                  //   );
                  // },
                );
              },
              itemCount: filteredRestaurants.length,
              shrinkWrap: true,
            ),
            20.verticalSpace,
            SectionHead(title: "Popular Fast Food", isActionVisible: false),
            40.verticalSpace,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 10.w,
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
              ),
            ),
            80.verticalSpace,
            Wrap(
              direction: Axis.horizontal,
              spacing: 20,
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
