import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/helpers/user_extensions.dart';
import 'package:food/food/core/routes/routes.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/domain/entities/location_data.dart';
import 'package:food/food/features/auth/presentation/manager/location_bloc/location_bloc.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/bloc/base/base_state.dart';
import '../../../../core/bloc/managers/bloc_manager.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../payments/presentation/manager/cart/cart_cubit.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/restaurant.dart';
import '../manager/food_bloc/food_bloc.dart'; // Now FoodCubit
import '../manager/restaurant_bloc/restaurant_bloc.dart'; // Now RestaurantCubit
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

  @override
  void initState() {
    super.initState();
    // Load location data if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationBloc>().requestLocation();
      context.read<RestaurantCubit>().getRestaurants();
      context.read<FoodCubit>().getAllFoods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      customScroll: true,
      appBarWidget: GestureDetector(
        // onTap: () {
        //   DFoodUtils.showDialogContainer(
        //     pop: true,
        //     context: context,
        //     contentPadding: EdgeInsets.zero,
        //     child: Container(
        //       height: 395.h,
        //       width: 327.w,
        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(35).r,
        //         gradient: const LinearGradient(
        //           colors: [kGradientColor2, kGradientColor1],
        //           begin: Alignment.topLeft,
        //           end: Alignment.bottomCenter,
        //           stops: [0.1, 0.9],
        //         ),
        //       ),
        //       child: Stack(
        //         clipBehavior: Clip.none,
        //         children: [
        //           Column(
        //             children: [
        //               37.verticalSpace,
        //               FImage(
        //                 assetPath: Assets.svgsOfferBg,
        //                 assetType: FoodAssetType.svg,
        //                 width: 270,
        //                 height: 190,
        //               ),
        //             ],
        //           ),
        //           Positioned(
        //             top: -15,
        //             right: -15,
        //             child: CircleWidget(
        //               radius: 22,
        //               color: kCloseColor,
        //               child: Icon(Icons.close, size: 10),
        //             ),
        //           ),
        //           Positioned(
        //             top: 82,
        //             left: 0,
        //             right: 0,
        //             child: Column(
        //               children: [
        //                 FText(
        //                   text: "Hurry now",
        //                   fontSize: 41,
        //                   color: kWhiteColor,
        //                   fontWeight: FontWeight.w800,
        //                 ),
        //                 35.verticalSpace,
        //                 FText(
        //                   text: "#1234CD2",
        //                   fontSize: 24,
        //                   color: kWhiteColor,
        //                   fontWeight: FontWeight.w600,
        //                 ),
        //                 20.verticalSpace,
        //                 FText(
        //                   text: "Use the coupon to get 50% off",
        //                   fontSize: 15,
        //                   fontWeight: FontWeight.w700,
        //                   color: kWhiteColor,
        //                 ),
        //                 30.verticalSpace,
        //                 FButton(
        //                   buttonText: "GOT IT",
        //                   onPressed: () {
        //                     Get.back();
        //                   },
        //                   borderColor: kWhiteColor,
        //                   color: Colors.transparent,
        //                   textColor: kWhiteColor,
        //                   fontSize: 14,
        //                   fontWeight: FontWeight.w700,
        //                 ).paddingSymmetric(horizontal: 35),
        //               ],
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   );
        // },
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
                20.horizontalSpace,
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
                        BlocBuilder<LocationBloc, BaseState<LocationData>>(
                          builder: (context, state) {
                            String locationText = "Lding...";

                            if (state is LoadingState<LocationData>) {
                              locationText = "Loading...";
                            } else if (state is SuccessState<LocationData> &&
                                state.data != null) {
                              final location = state.data!;
                              // Format as "City, Country" or just "City" if country is same as city
                              if (location.city.isNotEmpty &&
                                  location.country.isNotEmpty) {
                                locationText =
                                    "${location.city}, ${location.country}";
                              } else if (location.city.isNotEmpty) {
                                locationText = location.city;
                              } else if (location.address.isNotEmpty) {
                                // Fallback to address if city is not available
                                locationText = location.address;
                              } else {
                                locationText = "Location unavailable";
                              }
                            } else if (state is ErrorState<LocationData>) {
                              locationText = "Location unavailable";
                            }

                            return FText(
                              text: locationText,
                              fontSize: 14,
                              color: kAddressColor,
                            );
                          },
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
                  text: "Hello, ${context.watchUser()?.lastName ?? 'Guest'}",
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
                          // Optionally trigger category-specific food loading
                          if (category != "All") {
                            context.read<FoodCubit>().getFoodsByCategory(
                              category,
                            );
                          } else {
                            context.read<FoodCubit>().getAllFoods();
                          }
                        },
                      );
                    }).toList(),
              ),
            ),
            32.verticalSpace,
            BlocManager<FoodCubit, BaseState<dynamic>>(
              bloc: context.read<FoodCubit>(),
              showLoadingIndicator: true,
              builder: (context, state) {
                if (state is LoadingState) {
                  return SizedBox(
                    height: 250.h,
                    child: Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    ),
                  );
                } else if (state.hasData && state.data is List<FoodEntity>) {
                  final foods = state.data as List<FoodEntity>;
                  return buildFoodWidget(
                    selectedCategory,
                    foods,
                  ).paddingOnly(right: AppConstants.defaultPadding);
                } else if (state is EmptyState) {
                  return SizedBox(
                    height: 250.h,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fastfood, size: 48, color: kGreyColor),
                          16.verticalSpace,
                          FText(
                            text: state.message ?? 'No food available',
                            fontSize: 16,
                            color: kGreyColor,
                            alignment: MainAxisAlignment.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                // Loading and error states are handled by SimplifiedEnhancedBlocManager
                return const SizedBox.shrink();
              },
              child: const SizedBox.shrink(),
            ),
            32.verticalSpace,
            SectionHead(
              title: "Restaurants",
              isActionVisible: false,
            ).paddingOnly(right: AppConstants.defaultPadding.w),
            20.verticalSpace,
            BlocManager<RestaurantCubit, BaseState<dynamic>>(
              bloc: context.read<RestaurantCubit>(),
              showLoadingIndicator: true,
              builder: (context, state) {
                if (state is LoadingState) {
                  return Column(
                    children: List.generate(
                      3,
                      (index) => Container(
                        height: 100.h,
                        margin: EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: kGreyColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ).paddingOnly(right: AppConstants.defaultPadding.w);
                } else if (state.hasData && state.data is List<Restaurant>) {
                  final restaurants = state.data as List<Restaurant>;
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      spacing: 16,
                      children:
                          restaurants.map((restaurant) {
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
                  );
                }
                return SizedBox.shrink();
              },
              child: const SizedBox.shrink(),
            ),
          ],
        ).paddingOnly(left: AppConstants.defaultPadding.w),
      ),
    );
  }

  Widget buildFoodWidget(String category, List<FoodEntity> foods) {
    Widget foodWidget;
    List<FoodEntity> filteredFoodList;

    if (category == "All") {
      filteredFoodList = foods;
    } else {
      filteredFoodList =
          foods.where((food) => food.category == category).toList();
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
