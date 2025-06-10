import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/home/domain/entities/restaurant_food_category.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../../../components/buttons/buttons.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../payments/presentation/manager/cart/cart_cubit.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/restaurant.dart';
import '../widgets/cart_widget.dart';
import '../widgets/category_widget.dart';
import '../widgets/circle_widget.dart';
import '../widgets/food_widget.dart';
import '../widgets/restaurant_widget.dart';
import '../widgets/section_head.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String selectedCategory = "All";
  final nav = GetIt.instance<NavigationService>();
  final List<String> categories = [
    "All",
    "Hot Dog",
    "Burger",
    "Pizza",
    "Salad",
    "Pasta",
    "Sushi",
    "Tacos",
    "Sandwich",
    "Ice Cream",
    "Coffee",
    "Tea",
    "Juice",
    "Smoothie",
    "Steak",
    "Seafood",
    "Chicken Wings",
    "Fries",
    "Soup",
    "Dessert",
  ];
  final List<FoodEntity> foodList = [
    FoodEntity(
      imageUrl: "assets/images/food1.png",
      name: "Pizza",
      restaurantName: "Pizza Place",
      price: 10,
      rating: 4.6,
      category: "Pizza",
      id: Uuid().v4(),
      description: "Delicious cheese pizza with fresh toppings",
      restaurant: Restaurant(
        id: Uuid().v4(),
        name: "Pizza Place",
        imageUrl: "assets/images/restaurant1.png",
        description: "Best pizza in town with fresh ingredients",
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
        rating: 4.6,
        reviewCount: 120,
        deliveryTime: 30,
        distance: 2, // Distance in km
      ),
    ),
    FoodEntity(
      imageUrl: "assets/images/food1.png",
      name: "Hot Dog",
      restaurantName: "Hot Dog Stand",
      price: 10,
      category: "Hot Dog",
      rating: 4.2,
      id: Uuid().v4(),
      description: "Tasty hot dog with mustard and ketchup",
      restaurant: Restaurant(
        id: Uuid().v4(),
        name: "Hot Dog Stand",
        imageUrl: "assets/images/restaurant2.png",
        description: "Famous for its delicious hot dogs",
        categories: [
          RestaurantFoodCategory(
            category: "Hot Dog",
            imageUrl: "imageUrl",
            foods: [],
          ),
          RestaurantFoodCategory(
            category: "Fast Food",
            imageUrl: "imageUrl",
            foods: [],
          ),
        ],
        rating: 4.2,
        reviewCount: 80,
        deliveryTime: 20,
        distance: 1, // Distance in km
      ),
    ),
    FoodEntity(
      imageUrl: "assets/images/food1.png",
      name: "Burger",
      restaurantName: "Burger Joint",
      price: 10,
      category: "Burger",
      rating: 4.1,

      id: Uuid().v4(),
      description: "Juicy beef burger with lettuce and tomato",
      restaurant: Restaurant(
        id: Uuid().v4(),
        name: "Burger Joint",
        imageUrl: "assets/images/restaurant3.png",
        description: "Famous for its juicy burgers and fries",
        categories: [
          RestaurantFoodCategory(
            category: "Burger",
            imageUrl: "imageUrl",
            foods: [],
          ),
          RestaurantFoodCategory(
            category: "Fast Food",
            imageUrl: "imageUrl",
            foods: [],
          ),
        ],
        rating: 4.1,
        reviewCount: 150,
        deliveryTime: 25,
        distance: 3, // Distance in km
      ),
    ),
    FoodEntity(
      imageUrl: "assets/images/food2.png",
      name: "Salad",
      restaurantName: "Green Bowl",
      price: 8,
      category: "Salad",
      rating: 4.5,
      id: Uuid().v4(),
      description: "Fresh garden salad with a variety of vegetables",
      restaurant: Restaurant(
        id: Uuid().v4(),
        name: "Green Bowl",
        imageUrl: "assets/images/restaurant4.png",
        description: "Healthy salads made with fresh ingredients",
        categories: [
          RestaurantFoodCategory(
            category: "Salad",
            imageUrl: "imageUrl",
            foods: [],
          ),
          RestaurantFoodCategory(
            category: "Healthy",
            imageUrl: "imageUrl",
            foods: [],
          ),
        ],
        rating: 4.5,
        reviewCount: 90,
        deliveryTime: 15,
        distance: 1.5, // Distance in km
      ),
    ),
    FoodEntity(
      imageUrl: "assets/images/food3.png",
      name: "Pasta",
      restaurantName: "Italiano",
      price: 12,
      category: "Pasta",
      rating: 4.3,
      id: Uuid().v4(),
      description: "Creamy Alfredo pasta with chicken",
      restaurant: Restaurant(
        id: Uuid().v4(),
        name: "Italiano",
        imageUrl: "assets/images/restaurant5.png",
        description: "Authentic Italian pasta dishes",
        categories: [
          RestaurantFoodCategory(
            category: "Pasta",
            imageUrl: "imageUrl",
            foods: [],
          ),
          RestaurantFoodCategory(
            category: "Italian",
            imageUrl: "imageUrl",
            foods: [],
          ),
        ],
        rating: 4.3,
        reviewCount: 110,
        deliveryTime: 35,
        distance: 2.5, // Distance in km
      ),
    ),
    FoodEntity(
      imageUrl: "assets/images/food4.png",
      name: "Sushi",
      restaurantName: "Sushi Place",
      price: 15,
      rating: 4.8,
      category: "Sushi",
      id: Uuid().v4(),
      description: "Assorted sushi rolls with soy sauce and wasabi",
      restaurant: Restaurant(
        id: Uuid().v4(),
        name: "Sushi Place",
        imageUrl: "assets/images/restaurant6.png",
        description: "Fresh sushi made with the finest ingredients",
        categories: [
          RestaurantFoodCategory(
            category: "Sushi",
            imageUrl: "imageUrl",
            foods: [],
          ),
          RestaurantFoodCategory(
            category: "Japanese",
            imageUrl: "imageUrl",
            foods: [],
          ),
        ],
        rating: 4.8,
        reviewCount: 200,
        deliveryTime: 40,
        distance: 3.5, // Distance in km
      ),
    ),
    FoodEntity(
      imageUrl: "assets/images/food1.png",
      name: "Tacos",
      restaurantName: "Taco Bell",
      price: 9,
      category: "Tacos",
      rating: 4.0,

      id: Uuid().v4(),
      description: "Crunchy tacos with seasoned beef and cheese",
      restaurant: Restaurant(
        id: Uuid().v4(),
        name: "Taco Bell",
        imageUrl: "assets/images/restaurant7.png",
        description: "Famous for its delicious tacos and burritos",
        categories: [
          RestaurantFoodCategory(
            category: "Tacos",
            imageUrl: "imageUrl",
            foods: [],
          ),
          RestaurantFoodCategory(
            category: "Mexican",
            imageUrl: "imageUrl",
            foods: [],
          ),
        ],
        rating: 4.0,
        reviewCount: 100,
        deliveryTime: 30,
        distance: 2, // Distance in km
      ),
    ),
    FoodEntity(
      imageUrl: "assets/images/food2.png",
      name: "Sandwich",
      restaurantName: "Subway",
      price: 7,
      category: "Sandwich",
      rating: 4.4,
      id: Uuid().v4(),
      description: "Customizable sandwich with fresh ingredients",
      restaurant: Restaurant(
        id: Uuid().v4(),
        name: "Subway",
        imageUrl: "assets/images/restaurant8.png",
        description: "Build your own sandwich with fresh ingredients",
        categories: [
          RestaurantFoodCategory(
            category: "Sandwich",
            imageUrl: "imageUrl",
            foods: [],
          ),
          RestaurantFoodCategory(
            category: "Fast Food",
            imageUrl: "imageUrl",
            foods: [],
          ),
        ],
        rating: 4.4,
        reviewCount: 130,
        deliveryTime: 20,
        distance: 1, // Distance in km
      ),
    ),
    FoodEntity(
      imageUrl: "assets/images/food3.png",
      name: "Ice Cream",
      restaurantName: "Baskin Robbins",
      price: 5,
      category: "Ice Cream",
      rating: 4.7,
      id: Uuid().v4(),
      description: "Variety of ice cream flavors and toppings",
      restaurant: Restaurant(
        id: Uuid().v4(),
        name: "Baskin Robbins",
        imageUrl: "assets/images/restaurant9.png",
        description: "Delicious ice cream with a variety of flavors",
        categories: [
          RestaurantFoodCategory(
            category: "Ice Cream",
            imageUrl: "imageUrl",
            foods: [],
          ),
          RestaurantFoodCategory(
            category: "Dessert",
            imageUrl: "imageUrl",
            foods: [],
          ),
        ],
        rating: 4.7,
        reviewCount: 180,
        deliveryTime: 15,
        distance: 0.5, // Distance in km
      ),
    ),

    FoodEntity(
      imageUrl: "assets/images/food4.png",
      name: "Steak",
      restaurantName: "Outback Steakhouse",
      price: 25,
      category: "Steak",
      rating: 4.7,
      id: Uuid().v4(),
      description: "Grilled steak cooked to perfection",
      restaurant: Restaurant(
        id: Uuid().v4(),
        name: "Outback Steakhouse",
        imageUrl: "assets/images/restaurant10.png",
        description: "Famous for its juicy steaks and Australian cuisine",
        categories: [],
        rating: 4.7,
        reviewCount: 150,
        deliveryTime: 45,
        distance: 4, // Distance in km
      ),
    ),
    FoodEntity(
      imageUrl: "assets/images/food1.png",
      name: "Seafood",
      restaurantName: "Red Lobster",
      price: 30,
      category: "Seafood",
      rating: 4.6,
      id: Uuid().v4(),
      description: "Fresh seafood platter with various options",
      restaurant: Restaurant(
        id: Uuid().v4(),
        name: "Red Lobster",
        imageUrl: "assets/images/restaurant11.png",
        description: "Specializes in fresh seafood dishes",
        categories: [
          RestaurantFoodCategory(
            category: "Seafood",
            imageUrl: "imageUrl",
            foods: [],
          ),
          RestaurantFoodCategory(
            category: "American",
            imageUrl: "imageUrl",
            foods: [],
          ),
        ],
        rating: 4.6,
        reviewCount: 200,
        deliveryTime: 50,
        distance: 5, // Distance in km
      ),
    ),
    FoodEntity(
      imageUrl: "assets/images/food2.png",
      name: "Chicken Wings",
      restaurantName: "Buffalo Wild Wings",
      price: 12,
      category: "Chicken Wings",
      rating: 4.2,
      id: Uuid().v4(),
      description: "Spicy and flavorful chicken wings",
      restaurant: Restaurant(
        id: Uuid().v4(),
        name: "Buffalo Wild Wings",
        imageUrl: "assets/images/restaurant12.png",
        description:
            "Known for its spicy chicken wings and sports bar atmosphere",
        categories: [
          RestaurantFoodCategory(
            category: "Chicken Wings",
            imageUrl: "imageUrl",
            foods: [],
          ),
          RestaurantFoodCategory(
            category: "American",
            imageUrl: "imageUrl",
            foods: [],
          ),
        ],
        rating: 4.2,
        reviewCount: 160,
        deliveryTime: 35,
        distance: 3, // Distance in km
      ),
    ),
    FoodEntity(
      imageUrl: "assets/images/food3.png",
      name: "Fries",
      restaurantName: "McDonald's",
      price: 3,
      category: "Fries",
      rating: 4.0,
      id: Uuid().v4(),
      description: "Crispy golden French fries",
      restaurant: Restaurant(
        id: Uuid().v4(),
        name: "McDonald's",
        imageUrl: "assets/images/restaurant13.png",
        description:
            "World-famous fast food chain known for its fries and burgers",
        categories: [
          RestaurantFoodCategory(
            category: "Fries",
            imageUrl: "imageUrl",
            foods: [],
          ),
          RestaurantFoodCategory(
            category: "Fast Food",
            imageUrl: "imageUrl",
            foods: [],
          ),
        ],
        rating: 4.0,
        reviewCount: 300,
        deliveryTime: 20,
        distance: 1, // Distance in km
      ),
    ),
  ];
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

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      useSafeArea: true,
      appBarWidget: GestureDetector(
        onTap: () {
          DFoodUtils.showDialogContainer(
            pop: true,
            context: context,
            contentPadding: EdgeInsets.zero,
            child: Container(
              height: 395.h,
              width: 327.w,
              decoration: BoxDecoration(
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
                    top: 82,
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
                        35.verticalSpace,
                        FText(
                          text: "#1234CD2",
                          fontSize: 24,
                          color: kWhiteColor,
                          fontWeight: FontWeight.w600,
                        ),
                        20.verticalSpace,
                        FText(
                          text: "Use the coupon to get 50% off",
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kWhiteColor,
                        ),
                        30.verticalSpace,
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
                        ).paddingSymmetric(horizontal: 35),
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
                  onTap: () {
                    nav.navigateTo(Routes.menu);
                  },
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
            CartWidget(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
            32.verticalSpace,
            SectionHead(
              actionText: "Search",
              action: () {
                nav.navigateTo(Routes.search);
              },
            ).paddingOnly(right: AppConstants.defaultPadding.w),
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
            buildFoodWidget(
              selectedCategory,
            ).paddingOnly(right: AppConstants.defaultPadding),
            32.verticalSpace,
            SectionHead(
              title: "Restaurants",
              isActionVisible: false,
            ).paddingOnly(right: AppConstants.defaultPadding.w),
            20.verticalSpace,
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                spacing: 16,
                children:
                    restaurantList.map((restaurant) {
                      return RestaurantWidget(
                        restaurant: restaurant,
                        onTap: () {
                          nav.navigateTo(
                            Routes.restaurantDetails,
                            arguments: restaurant,
                          );
                        },
                      );
                    }).toList(),
              ).paddingOnly(right: AppConstants.defaultPadding.w),
            ),
          ],
        ).paddingOnly(left: AppConstants.defaultPadding.w),
      ),
    );
  }

  Widget buildFoodWidget(String category) {
    Widget foodWidget;
    List<FoodEntity> filteredFoodList;

    if (category == "All") {
      filteredFoodList = foodList;
    } else {
      filteredFoodList =
          foodList.where((food) => food.category == category).toList();
    }

    if (filteredFoodList.isEmpty) {
      return Center(
        child: FText(
          text: "No food available in this category.",
          fontSize: 16,
          color: kPrimaryColor,
        ),
      );
    }

    foodWidget = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 20,
        children:
            filteredFoodList.map((food) {
              return FoodWidget(
                image: food.imageUrl,
                name: food.name,
                onAddTapped: () {
                  context.read<CartCubit>().addFood(food);
                },
                onTap: () {
                  nav.navigateTo(Routes.foodDetails, arguments: food);
                },
                rating: food.rating.toStringAsFixed(
                  2,
                ), // Assuming a default rating for now
                price: "\$${food.price.toStringAsFixed(2)}",
              );
            }).toList(),
      ),
    );
    return foodWidget;
  }
}
