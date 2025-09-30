import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/no_items_found_widget.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/features/home/domain/entities/restaurant.dart';
import 'package:food/food/features/home/domain/entities/restaurant_food_category.dart';
import 'package:food/food/features/home/presentation/widgets/details_skeleton_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../generated/assets.dart';
import '../../../../components/image.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/detail_image_cache.dart';
import '../../domain/entities/food.dart';
import '../widgets/category_widget.dart';
import '../widgets/food_widget.dart';
import '../widgets/section_head.dart';
import '../../../payments/presentation/manager/cart/cart_cubit.dart';
import '../../../payments/presentation/manager/cart/cart_event.dart';

class RestaurantDetails extends StatefulWidget {
  final Restaurant restaurant;
  const RestaurantDetails({super.key, required this.restaurant});
  @override
  State<RestaurantDetails> createState() => _RestaurantDetailsState();
}

class _RestaurantDetailsState extends State<RestaurantDetails> {
  List<RestaurantFoodCategory> categories = [];
  String selectedCategory = "All";
  final nav = GetIt.instance<NavigationService>();
  @override
  void initState() {
    super.initState();
    categories = [
      RestaurantFoodCategory(
        category: "All",
        imageUrl: "",
        foods: widget.restaurant.category.expand((cat) => cat.foods).toList(),
      ),
      ...widget.restaurant.category,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DetailsSkeletonWidget(
      key: ValueKey('restaurant_detail_${widget.restaurant.id}'),
      hasBottomWidget: false,
      hasIndicator: true,
      isRestaurant: true,
      icon: Ionicons.menu,
      imageUrl: widget.restaurant.imageUrl,
      cacheKey: DetailImageCache.getDetailCacheKey(
        type: 'restaurant',
        id: widget.restaurant.id,
      ),
      bodyWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add your body widget here
          FText(
            text: widget.restaurant.name,
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
                    text: widget.restaurant.rating.toString(),
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
                    text: widget.restaurant.distance.toString(),
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
                    text: widget.restaurant.deliveryTime.toString(),
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
            text: widget.restaurant.description,
          ),
          20.verticalSpace,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              spacing: 16,
              children:
                  categories.map((category) {
                    return CategoryWidget(
                      showImage: true,
                      text: category.category,
                      isSelected: selectedCategory == category.category,
                      onTap: () {
                        setState(() {
                          selectedCategory = category.category;
                        });
                      },
                    );
                  }).toList(),
            ),
          ),
          20.verticalSpace,
          SectionHead(title: selectedCategory, isActionVisible: false),
          40.verticalSpace,
          buildFoodWidget(selectedCategory),

          // Add more widgets as needed
        ],
      ),
    );
  }

  Widget buildFoodWidget(String category) {
    Widget foodWidget;
    List<FoodEntity> filteredFoodList;

    if (category == "All") {
      // If "All" is selected, combine foods from all categories
      filteredFoodList =
          widget.restaurant.category.expand((cat) => cat.foods).toList();
    } else {
      // Find the specific category and get its foods
      filteredFoodList =
          widget.restaurant.category
              .where((food) => food.category == category)
              .expand((cat) => cat.foods)
              .toList();
    }

    if (filteredFoodList.isEmpty) {
      return NoItemsFoundWidget(
        type: NoItemsType.food,
        customMessage: "No food available in this category",
        height: 200.h,
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
                key: ValueKey('restaurant_detail_food_${food.id}'),
                id: food.id,
                image: food.imageUrl,
                name: food.name,
                onAddTapped: () {
                  context.read<CartCubit>().add(CartAddFoodEvent(food: food));
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
