import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/helpers/extensions.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/home/manager/recent_keywords/recent_keywords_cubit.dart';
import 'package:food/food/features/home/presentation/widgets/cart_widget.dart';
import 'package:food/food/features/home/presentation/widgets/food_widget.dart';
import 'package:food/food/features/home/presentation/widgets/search_widget.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/bloc/managers/bloc_manager.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../payments/presentation/manager/cart/cart_cubit.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/search_result.dart'; // SearchResultEntity
import '../manager/search_bloc/search_bloc.dart';
import '../manager/search_bloc/search_event.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<RecentKeywordsCubit>().loadRecentKeywords();
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });

    if (newQuery.trim().isNotEmpty) {
      context.read<SearchBloc>().add(SearchAllEvent(newQuery.trim()));
    } else {
      context.read<SearchBloc>().add(ClearSearchEvent());
    }
  }

  Widget _buildSuggestedFoodsSection() {
    return BlocManager<SearchBloc, BaseState<dynamic>>(
      bloc: context.read<SearchBloc>(),
      child: const SizedBox.shrink(),
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

        final foods =
            state.hasData
                ? (state.data is SearchResultEntity
                    ? (state.data as SearchResultEntity).foods
                    : <FoodEntity>[])
                : <FoodEntity>[];

        if (foods.isEmpty && searchQuery.isNotEmpty) {
          return Center(
            child: FText(
              text: "No foods matches your search query",
              color: kPrimaryColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
            ),
          );
        } else if (foods.isNotEmpty) {
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
                    final food = foods[index];
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
                  itemCount: foods.length,
                  shrinkWrap: true,
                ),
              ),
            ],
          );
        }

        return SizedBox.shrink();
      },
    );
  }

  Widget _buildSuggestedRestaurantsSection() {
    return BlocManager<SearchBloc, BaseState<dynamic>>(
      bloc: context.read<SearchBloc>(),
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

        final restaurants =
            state.hasData
                ? (state.data is SearchResultEntity
                    ? (state.data as SearchResultEntity).restaurants
                    : <Restaurant>[])
                : <Restaurant>[];

        if (restaurants.isEmpty && searchQuery.isNotEmpty) {
          return Center(
            child: FText(
              text: "No Restaurants matches your search query",
              color: kPrimaryColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
            ),
          );
        } else if (restaurants.isNotEmpty) {
          return Column(
            children: [
              20.verticalSpace,
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final restaurant = restaurants[index];
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
                itemCount: restaurants.length,
                shrinkWrap: true,
              ),
            ],
          );
        }

        return SizedBox.shrink();
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
                setState(() {
                  searchController.clear();
                  searchQuery = "";
                });
                context.read<SearchBloc>().add(ClearSearchEvent());
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
            BlocManager<RecentKeywordsCubit, BaseState<dynamic>>(
              bloc: context.read<RecentKeywordsCubit>(),
              child: const SizedBox.shrink(),
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
