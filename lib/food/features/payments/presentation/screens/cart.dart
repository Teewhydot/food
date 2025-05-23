import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons/buttons.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/textfields.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:food/food/features/tracking/presentation/widgets/cart_widget.dart';
import 'package:get/get.dart';

class Cart extends StatelessWidget {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      bottomWidget: FoodContainer(
        width: 1.sw,
        height: 310,
        borderRadius: 24,
        color: kWhiteColor,
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
      body: Container(
        width: 1.sw,
        height: 1.sh,
        color: kScaffoldColorDark,
        child: SingleChildScrollView(
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
              DFoodCartWidget(),
              DFoodCartWidget(),
              DFoodCartWidget(),
              DFoodCartWidget(),
              DFoodCartWidget(),
              DFoodCartWidget(),
              DFoodCartWidget(),
              DFoodCartWidget(),
              DFoodCartWidget(),
              DFoodCartWidget(),
              DFoodCartWidget(),
              DFoodCartWidget(),
            ],
          ).paddingOnly(left: 24, right: 24),
        ),
      ),
    );
  }
}
