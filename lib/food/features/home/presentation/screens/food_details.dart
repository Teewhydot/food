import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/bloc/bloc_manager.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/features/home/domain/entities/food.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/food/features/home/presentation/widgets/details_skeleton_widget.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:food/food/features/payments/presentation/manager/cart/cart_cubit.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../generated/assets.dart';
import '../../../../components/buttons/buttons.dart';
import '../../../../components/image.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';

class FoodDetails extends StatefulWidget {
  final FoodEntity foodEntity;

  const FoodDetails({super.key, required this.foodEntity});

  @override
  State<FoodDetails> createState() => _FoodDetailsState();
}

class _FoodDetailsState extends State<FoodDetails> {
  int foodQuantity = 1;
  double totalPrice = 0.0;

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();

    return BlocManager<CartCubit, CartState>(
      bloc: context.read<CartCubit>(),
      isError: (state) => state is CartError,
      getErrorMessage: (state) => (state as CartError).errorMessage,
      isSuccess: (state) => state is CartLoaded,
      child: Container(),
      builder: (context, state) {
        if (state is CartLoaded) {
          return DetailsSkeletonWidget(
            hasBottomWidget: true,
            hasIndicator: false,
            isRestaurant: false,
            icon: Icons.favorite,
            bottomWidget: IntrinsicHeight(
              child: Container(
                width: 1.sw,
                decoration: BoxDecoration(
                  color: kTextFieldColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r),
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FText(
                          text: "\$${widget.foodEntity.price * foodQuantity}",
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                        ),
                        FoodContainer(
                          width: 125,
                          height: 50,
                          borderRadius: 30,
                          color: kBlackColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CircleWidget(
                                radius: 12,
                                color: kGreyColor,
                                child: Icon(Ionicons.remove),
                                onTap: () {
                                  if (foodQuantity > 1) {
                                    setState(() {
                                      foodQuantity--;
                                      totalPrice =
                                          widget.foodEntity.price *
                                          foodQuantity;
                                    });
                                  }
                                },
                              ),
                              FText(
                                text: foodQuantity.toString(),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: kWhiteColor,
                              ),
                              CircleWidget(
                                radius: 12,
                                color: kGreyColor,
                                child: Icon(Ionicons.add),
                                onTap: () {
                                  setState(() {
                                    foodQuantity++;
                                    totalPrice =
                                        widget.foodEntity.price * foodQuantity;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    24.verticalSpace,
                    FButton(
                      buttonText: "ADD TO CART",
                      width: 1.sw,
                      height: 62,
                      onPressed: () {
                        final finalFoodEntity = widget.foodEntity.copyWith(
                          quantity: foodQuantity,
                        );
                        context.read<CartCubit>().addFood(finalFoodEntity);
                        nav.goBack();
                      },
                    ),
                  ],
                ).paddingAll(AppConstants.defaultPadding),
              ),
            ),
            bodyWidget: Column(
              children: [
                // Add your body widget here
                FText(
                  text: widget.foodEntity.name,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  alignment: MainAxisAlignment.start,
                ),
                7.verticalSpace,
                Row(
                  children: [
                    FoodContainer(
                      width: 22,
                      height: 22,
                      borderRadius: 20,
                      color: Colors.red,
                    ),
                    10.horizontalSpace,
                    FText(
                      text:
                          widget.foodEntity.restaurant?.name ??
                          "Unknown Restaurant",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      alignment: MainAxisAlignment.start,
                    ),
                  ],
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
                          text: widget.foodEntity.rating.toString(),
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
                          text:
                              widget.foodEntity.restaurant?.distance
                                  .toString() ??
                              "Unknown Distance",
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
                          text:
                              widget.foodEntity.restaurant?.deliveryTime
                                  .toString() ??
                              "Unknown Delivery Time",
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
                  text: widget.foodEntity.description,
                ),
                20.verticalSpace,
                Row(
                  children: [
                    FText(
                      text: "Size",
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kTextColorDark,
                    ),
                    10.horizontalSpace,
                    CircleWidget(
                      radius: 24,
                      color: kContainerColor,
                      child: FText(
                        text: "M",
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kTextColorDark,
                      ),
                    ),
                    10.horizontalSpace,
                    CircleWidget(
                      radius: 24,
                      color: kContainerColor,
                      child: FText(
                        text: "M",
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kTextColorDark,
                      ),
                    ),
                    10.horizontalSpace,
                    CircleWidget(
                      radius: 24,
                      color: kContainerColor,
                      child: FText(
                        text: "M",
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kTextColorDark,
                      ),
                    ),
                  ],
                ),

                // Add more widgets as needed
              ],
            ),
          );
        }
        return SizedBox();
      },
    );
  }
}
