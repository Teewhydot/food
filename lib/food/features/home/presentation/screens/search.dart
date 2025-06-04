import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/helpers/extensions.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/home/manager/recent_keywords/recent_keywords_cubit.dart';
import 'package:food/food/features/home/presentation/widgets/cart_widget.dart';
import 'package:food/food/features/home/presentation/widgets/food_widget.dart';
import 'package:food/food/features/home/presentation/widgets/search_widget.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../payments/presentation/manager/cart/cart_cubit.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/restaurant_food_category.dart';
import '../widgets/keyword_widget.dart';
import '../widgets/restaurant_widget.dart';
import '../widgets/section_head.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final nav = GetIt.instance<NavigationService>();
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
  final TextEditingController searchController = TextEditingController();
  List<Restaurant> filteredRestaurants = [];
  List<FoodEntity> filteredFoods = [];

  String searchQuery = "";
  @override
  void initState() {
    super.initState();
    context.read<RecentKeywordsCubit>().loadRecentKeywords();
    filteredRestaurants = restaurantList;
    filteredFoods = foodList;
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
      filteredFoods =
          foodList
              .where(
                (food) =>
                    food.name.toLowerCase().contains(searchQuery.toLowerCase()),
              )
              .toList();
      filteredRestaurants =
          restaurantList
              .where(
                (restaurant) => restaurant.name.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
              )
              .toList();
      print("Filtered restaurants: $filteredRestaurants");
      print("Filtered foods: $filteredFoods");
    });
  }

  Widget _buildSuggestedFoodsSection() {
    return Column(
      children: [
        if (filteredFoods.isEmpty && searchQuery.isNotEmpty)
          Center(
            child: FText(
              text: "No foods matches your search query",
              color: kPrimaryColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
            ),
          )
        else ...[
          20.verticalSpace,
          SizedBox(
            height: 250.h,
            width: 1.sw,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final food = filteredFoods[index];
                return FoodWidget(
                  name: food.name,
                  rating: food.rating.toString(),
                  price: food.price.toString(),
                  image: food.imageUrl,
                  onAddTapped: () {
                    context.read<CartCubit>().addFood(food);
                  },
                  onTap: () {
                    nav.navigateTo(Routes.foodDetails, arguments: food);
                  },
                );
              },
              itemCount: filteredFoods.length,
              shrinkWrap: true,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuggestedRestaurantsSection() {
    return Column(
      children: [
        if (filteredRestaurants.isEmpty && searchQuery.isNotEmpty)
          Center(
            child: FText(
              text: "No Restaurants matches your search query",
              color: kPrimaryColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
            ),
          )
        else ...[
          20.verticalSpace,
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final restaurant = filteredRestaurants[index];
              return SuggestedRestaurant(
                restaurant: restaurant,
                onTap: () {
                  nav.navigateTo(
                    Routes.restaurantDetails,
                    arguments: restaurant,
                  );
                },
              );
            },
            itemCount: filteredRestaurants.length,
            shrinkWrap: true,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      appBarWidget: Row(
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
      useSafeArea: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            25.verticalSpace,
            SearchWidget(
              controller: searchController,
              onValueChanged: updateSearchQuery,
              onSuffixTap: () {
                setState(() {
                  searchController.clear();
                  searchQuery = "";
                  filteredRestaurants = restaurantList;
                  filteredFoods = foodList;
                });
              },
              onEditingComplete: () {
                if (searchQuery.isNotEmpty) {
                  final keyword = searchQuery.trim();
                  context.read<RecentKeywordsCubit>().addKeyword(keyword);
                }
              },
            ),
            25.verticalSpace,
            SectionHead(title: "Recent Keywords", isActionVisible: false),
            20.verticalSpace,
            BlocBuilder<RecentKeywordsCubit, RecentKeywordsState>(
              builder: (context, state) {
                if (state is RecentKeywordsLoading) {
                  return SizedBox(
                    height: 56.h,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => 10.horizontalSpace,
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return KeywordWidget(keyword: "Hope", onTap: () {});
                      },
                    ),
                  ).skeletonize();
                } else if (state is RecentKeywordsError) {
                  return Center(
                    child: FText(text: state.message, color: kPrimaryColor),
                  );
                } else if (state is RecentKeywordsLoaded) {
                  if (state.keywords.isEmpty) {
                    return Center(
                      child: FText(
                        text: "No recent keywords found",
                        color: kPrimaryColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.normal,
                      ),
                    );
                  }
                  return SizedBox(
                    height: 56.h,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => 10.horizontalSpace,
                      scrollDirection: Axis.horizontal,
                      itemCount: state.keywords.length,
                      itemBuilder: (context, index) {
                        return KeywordWidget(
                          keyword: state.keywords[index].keyword,
                          onTap: () {
                            searchController.text =
                                state.keywords[index].keyword;
                            updateSearchQuery(state.keywords[index].keyword);
                          },
                        );
                      },
                    ),
                  );
                } else {
                  return SizedBox();
                }
              },
            ),
            30.verticalSpace,
            SectionHead(title: "Suggested Restaurants", isActionVisible: false),
            10.verticalSpace,
            _buildSuggestedRestaurantsSection(),
            20.verticalSpace,
            SectionHead(title: "Suggested Foods", isActionVisible: false),
            10.verticalSpace,

            _buildSuggestedFoodsSection(),
          ],
        ).paddingOnly(left: AppConstants.defaultPadding.w),
      ),
    );
  }
}
