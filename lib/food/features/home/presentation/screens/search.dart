import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/no_items_found_widget.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/helpers/extensions.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/home/manager/recent_keywords/recent_keywords_cubit.dart';
import 'package:food/food/features/home/presentation/manager/food_bloc/food_bloc.dart';
import 'package:food/food/features/home/presentation/manager/restaurant_bloc/restaurant_bloc.dart';
import 'package:food/food/features/home/presentation/widgets/cart_widget.dart';
import 'package:food/food/features/home/presentation/widgets/food_widget.dart';
import 'package:food/food/features/home/presentation/widgets/search_widget.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/bloc/managers/bloc_manager.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/utils/detail_image_cache.dart';
import '../../../payments/presentation/manager/cart/cart_cubit.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/restaurant.dart';
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
  final TextEditingController searchController = TextEditingController();

  String searchQuery = "";
  List<FoodEntity> allFoods = [];
  List<Restaurant> allRestaurants = [];
  List<FoodEntity> filteredFoods = [];
  List<Restaurant> filteredRestaurants = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    context.read<RecentKeywordsCubit>().loadRecentKeywords();
    _loadInitialData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _loadInitialData() {
    // Load foods and restaurants from their respective cubits (same data as home)
    context.read<FoodCubit>().getAllFoods();
    context.read<RestaurantCubit>().getRestaurants();
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });

    // Cancel any existing debounce timer
    _debounceTimer?.cancel();

    if (newQuery.trim().isEmpty) {
      // Show all items when search is empty
      setState(() {
        filteredFoods = allFoods;
        filteredRestaurants = allRestaurants;
      });
    } else {
      // Filter locally for instant results
      _filterDataLocally(newQuery);
    }
  }

  void _filterDataLocally(String query) {
    final lowerQuery = query.toLowerCase();

    setState(() {
      filteredFoods =
          allFoods
              .where(
                (food) =>
                    food.name.toLowerCase().contains(lowerQuery) ||
                    food.category.toLowerCase().contains(lowerQuery) ||
                    food.description.toLowerCase().contains(lowerQuery),
              )
              .toList();

      filteredRestaurants =
          allRestaurants
              .where(
                (restaurant) =>
                    restaurant.name.toLowerCase().contains(lowerQuery) ||
                    restaurant.description.toLowerCase().contains(lowerQuery) ||
                    restaurant.category.any(
                      (cat) => cat.category.toLowerCase().contains(lowerQuery),
                    ),
              )
              .toList();
    });
  }

  Widget _buildSuggestedFoodsSection() {
    return BlocManager<FoodCubit, BaseState<dynamic>>(
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
        }

        // Update local data when FoodCubit loads data
        if (state.hasData && state.data is List<FoodEntity>) {
          final loadedFoods = state.data as List<FoodEntity>;
          if (allFoods != loadedFoods) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                allFoods = loadedFoods;
                if (searchQuery.trim().isEmpty) {
                  filteredFoods = allFoods;
                } else {
                  _filterDataLocally(searchQuery);
                }
              });
            });
          }
        }

        final foodsToShow =
            searchQuery.trim().isEmpty ? allFoods : filteredFoods;

        if (foodsToShow.isEmpty && searchQuery.isNotEmpty) {
          return NoItemsFoundWidget(
            type: NoItemsType.search,
            customMessage: "No foods match your search query",
            height: 120.h,
          );
        } else if (foodsToShow.isEmpty && searchQuery.isEmpty) {
          return NoItemsFoundWidget(
            type: NoItemsType.food,
            customMessage: "Loading foods...",
            height: 120.h,
          );
        }

        return Column(
          children: [
            20.verticalSpace,
            SizedBox(
              height: 250.h,
              width: 1.sw,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final food = foodsToShow[index];
                  return FoodWidget(
                    key: ValueKey('search_food_${food.id}'),
                    id: food.id,
                    name: food.name,
                    rating: food.rating.toString(),
                    price: food.price.toString(),
                    image: food.imageUrl,
                    onAddTapped: () {
                      context.read<CartCubit>().addFood(food);
                    },
                    onTap: () {
                      // Preload detail image for smooth navigation
                      DetailImageCache.preloadDetailImage(
                        context: context,
                        imageUrl: food.imageUrl,
                        cacheKey: DetailImageCache.getDetailCacheKey(
                          type: 'food',
                          id: food.id,
                        ),
                      );
                      nav.navigateTo(Routes.foodDetails, arguments: food);
                    },
                  );
                },
                itemCount: foodsToShow.length,
                shrinkWrap: true,
              ),
            ),
          ],
        );
      },
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildSuggestedRestaurantsSection() {
    return BlocManager<RestaurantCubit, BaseState<dynamic>>(
      bloc: context.read<RestaurantCubit>(),
      child: const SizedBox.shrink(),
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
          );
        }

        // Update local data when RestaurantCubit loads data
        if (state.hasData && state.data is List<Restaurant>) {
          final loadedRestaurants = state.data as List<Restaurant>;
          if (allRestaurants != loadedRestaurants) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                allRestaurants = loadedRestaurants;
                if (searchQuery.trim().isEmpty) {
                  filteredRestaurants = allRestaurants;
                } else {
                  _filterDataLocally(searchQuery);
                }
              });
            });
          }
        }

        final restaurantsToShow =
            searchQuery.trim().isEmpty ? allRestaurants : filteredRestaurants;

        if (restaurantsToShow.isEmpty && searchQuery.isNotEmpty) {
          return NoItemsFoundWidget(
            type: NoItemsType.search,
            customMessage: "No restaurants match your search query",
            height: 120.h,
          );
        } else if (restaurantsToShow.isEmpty && searchQuery.isEmpty) {
          return NoItemsFoundWidget(
            type: NoItemsType.restaurant,
            customMessage: "Loading restaurants...",
            height: 120.h,
          );
        }

        return Column(
          children: [
            20.verticalSpace,
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final restaurant = restaurantsToShow[index];
                return RestaurantWidget(
                  key: ValueKey('search_restaurant_${restaurant.id}'),
                  restaurant: restaurant,
                  onTap: () {
                    // Preload detail image for smooth navigation
                    DetailImageCache.preloadDetailImage(
                      context: context,
                      imageUrl: restaurant.imageUrl,
                      cacheKey: DetailImageCache.getDetailCacheKey(
                        type: 'restaurant',
                        id: restaurant.id,
                      ),
                    );
                    nav.navigateTo(
                      Routes.restaurantDetails,
                      arguments: restaurant,
                    );
                  },
                );
              },
              itemCount: restaurantsToShow.length,
              shrinkWrap: true,
            ),
          ],
        );
      },
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
      customScroll: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            25.verticalSpace,
            SearchWidget(
              controller: searchController,
              onValueChanged: updateSearchQuery,
              onSuffixTap: () {
                _debounceTimer?.cancel();
                setState(() {
                  searchController.clear();
                  searchQuery = "";
                  filteredFoods = allFoods;
                  filteredRestaurants = allRestaurants;
                });
              },
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
                context.read<RecentKeywordsCubit>().addKeyword(
                  searchQuery.trim(),
                );
              },
            ),
            25.verticalSpace,
            SectionHead(title: "Recent Keywords", isActionVisible: false),
            20.verticalSpace,
            BlocManager<RecentKeywordsCubit, BaseState<dynamic>>(
              bloc: context.read<RecentKeywordsCubit>(),
              showLoadingIndicator: true,
              builder: (context, state) {
                if (state is LoadingState) {
                  return SizedBox(
                    height: 56.h,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => 10.horizontalSpace,
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return KeywordWidget(keyword: "Loading", onTap: () {});
                      },
                    ),
                  ).skeletonize();
                } else if (state.hasData) {
                  final keywords = state.data as List;
                  if (keywords.isEmpty) {
                    return NoItemsFoundWidget(
                      type: NoItemsType.generic,
                      customMessage: "No recent keywords found",
                      height: 80.h,
                    );
                  }
                  return SizedBox(
                    height: 56.h,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => 10.horizontalSpace,
                      scrollDirection: Axis.horizontal,
                      itemCount: keywords.length,
                      itemBuilder: (context, index) {
                        return KeywordWidget(
                          keyword: keywords[index].keyword,
                          onTap: () {
                            searchController.text = keywords[index].keyword;
                            updateSearchQuery(keywords[index].keyword);
                          },
                        );
                      },
                    ),
                  );
                } else {
                  return SizedBox();
                }
              },
              child: const SizedBox.shrink(),
            ),
            30.verticalSpace,
            SectionHead(title: "Suggested Foods", isActionVisible: false),
            10.verticalSpace,
            _buildSuggestedFoodsSection(),
            20.verticalSpace,
            SectionHead(title: "Suggested Restaurants", isActionVisible: false),
            10.verticalSpace,
            _buildSuggestedRestaurantsSection(),
          ],
        ).paddingOnly(left: AppConstants.defaultPadding.w),
      ),
    );
  }
}
