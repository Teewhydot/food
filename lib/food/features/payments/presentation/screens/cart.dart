import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/tracking/presentation/widgets/cart_widget.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/buttons/buttons.dart';
import '../../../../components/textfields.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';

class Cart extends StatelessWidget {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();
    return FScaffold(
      useSafeArea: true,
      backgroundColor: kScaffoldColorDark,
      bottomWidget: IntrinsicHeight(
        child: Container(
          width: 1.sw,
          decoration: BoxDecoration(
            color: kWhiteColor,
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
                    text: "Delivery address".toUpperCase(),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  FText(
                    text: "Edit".toUpperCase(),
                    fontSize: 14,
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w400,
                    decorations: [TextDecoration.underline],
                  ),
                ],
              ),
              10.verticalSpace,
              FTextField(hintText: "Address", action: TextInputAction.next),
              30.verticalSpace,
              Row(
                children: [
                  FText(
                    text: "Total:".toUpperCase(),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  10.horizontalSpace,
                  FText(
                    text: "\$900".toUpperCase(),
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
              30.verticalSpace,
              FButton(buttonText: "Place order", width: 1.sw),
            ],
          ).paddingAll(AppConstants.defaultPadding),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                BackWidget(),
                18.horizontalSpace,
                FText(text: "Cart", color: kWhiteColor),
                Spacer(),
                FText(
                  text: "Edit cart".toUpperCase(),
                  color: kPrimaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  decorations: [TextDecoration.underline],
                ),
              ],
            ),
            30.verticalSpace,
            DFoodCartWidget(
              imagePath: "assets/images/pizza.png",
              foodName: "Hot and Spicy Pizza",
              price: "\$90",
              size: "12",
              quantity: "12",
              restaurantName: "Pizza Hut",
            ),
            DFoodCartWidget(
              imagePath: "assets/images/pizza.png",
              foodName: "Hot dog",
              price: "\$10",
              size: "12",
              quantity: "12",
              restaurantName: "Hot Dog Stand",
            ),
            DFoodCartWidget(
              imagePath: "assets/images/pizza.png",
              foodName: "Cheese Burger",
              price: "\$20",
              size: "12",
              quantity: "12",
              restaurantName: "Burger King",
            ),
            DFoodCartWidget(
              imagePath: "assets/images/pizza.png",
              foodName: "Sushi Rolls",
              price: "\$30",
              size: "12",
              quantity: "12",
              restaurantName: "Sushi Place",
            ),
            DFoodCartWidget(
              imagePath: "assets/images/pizza.png",
              foodName: "Pasta Carbonara",
              price: "\$40",
              size: "12",
              quantity: "12",
              restaurantName: "Italian Bistro",
            ),
          ],
        ).paddingOnly(left: 24, right: 24),
      ),
    );
  }
}
