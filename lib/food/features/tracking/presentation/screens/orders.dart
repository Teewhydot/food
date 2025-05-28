import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons/buttons.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/tracking/presentation/screens/tracking.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/navigation_service/nav_config.dart';

enum OrderCategory { ongoing, history }

class Orders extends StatelessWidget {
  const Orders({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();

    return Column(
      children: [
        Row(
          children: [
            BackWidget(color: kGreyColor),
            20.horizontalSpace,
            FText(text: "My Orders", fontWeight: FontWeight.w700, fontSize: 17),
          ],
        ),
        24.verticalSpace,
        Expanded(
          child: ContainedTabBarView(
            tabBarProperties: TabBarProperties(
              labelStyle: GoogleFonts.sen(color: kPrimaryColor),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: kPrimaryColor,
              labelColor: kPrimaryColor,
              unselectedLabelStyle: GoogleFonts.sen(
                color: kContainerColor,
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            tabs: [Text("Ongoing"), Text("History")],
            views: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    OrderDetailsWidget(
                      orderCategory: OrderCategory.ongoing,
                      category: "Pizza",
                      foodName: "Cheese Pizza",
                      price: "12.00",
                      orderId: "123456789",
                      quantity: 2,
                      firstButtonOnTap: () {},
                    ),
                    OrderDetailsWidget(
                      orderCategory: OrderCategory.ongoing,
                      category: "Burger",
                      foodName: "Cheese Burger",
                      price: "10.00",
                      orderId: "123456789",
                      quantity: 1,
                      firstButtonOnTap: () {},
                    ),
                    OrderDetailsWidget(
                      orderCategory: OrderCategory.ongoing,
                      category: "Pizza",
                      foodName: "Cheese Pizza",
                      price: "12.00",
                      orderId: "123456789",
                      quantity: 2,
                      firstButtonOnTap: () {},
                    ),
                  ],
                ).paddingOnly(top: 32),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    OrderDetailsWidget(
                      orderCategory: OrderCategory.history,
                      category: "Pizza",
                      foodName: "Cheese Pizza",
                      price: "12.00",
                      orderId: "123456789",
                      quantity: 2,
                      firstButtonOnTap: () {},
                    ),
                    OrderDetailsWidget(
                      orderCategory: OrderCategory.history,
                      category: "Burger",
                      foodName: "Cheese Burger",
                      price: "10.00",
                      orderId: "123456789",
                      quantity: 1,
                      firstButtonOnTap: () {},
                    ),
                    OrderDetailsWidget(
                      orderCategory: OrderCategory.history,
                      category: "Pizza",
                      foodName: "Cheese Pizza",
                      price: "12.00",
                      orderId: "123456789",
                      quantity: 2,
                      firstButtonOnTap: () {},
                    ),
                  ],
                ).paddingOnly(top: 32),
              ),
            ],
          ),
        ),
      ],
    ).paddingOnly(
      left: AppConstants.defaultPadding,
      right: AppConstants.defaultPadding,
    );
  }
}

class OrderDetailsWidget extends StatelessWidget {
  final String category, foodName, price, orderId;
  final OrderCategory orderCategory;
  final int quantity;
  final Function()? firstButtonOnTap, secondButtonOnTap;

  const OrderDetailsWidget({
    super.key,
    required this.orderCategory,
    required this.category,
    required this.foodName,
    required this.price,
    required this.orderId,
    required this.quantity,

    this.firstButtonOnTap,
    this.secondButtonOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FText(
          text: category,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          alignment: MainAxisAlignment.start,
        ),
        16.verticalSpace,
        Divider(color: kGreyColor),
        16.verticalSpace,
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: kContainerColor,
                borderRadius: BorderRadius.circular(10).r,
              ),
            ),
            14.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FText(
                        text: foodName,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      FText(
                        text: "Order ID: $orderId",
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: kContainerColor,
                      ),
                    ],
                  ),
                  4.verticalSpace,
                  Row(
                    children: [
                      FText(
                        text: "\$$price.00",
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: kBlackColor,
                      ),
                      8.horizontalSpace,
                      Line(color: kContainerColor, height: 16),
                      8.horizontalSpace,
                      FText(
                        text: "x$quantity",
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: kContainerColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        24.verticalSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 49,
          children: [
            FButton(
              buttonText:
                  orderCategory == OrderCategory.ongoing
                      ? "Track Order"
                      : "Rate",
              width: 139,
              textColor:
                  orderCategory == OrderCategory.ongoing
                      ? kWhiteColor
                      : kPrimaryColor,
              onPressed: firstButtonOnTap,
              color:
                  orderCategory == OrderCategory.ongoing
                      ? kPrimaryColor
                      : kWhiteColor,
            ),
            FButton(
              buttonText:
                  orderCategory == OrderCategory.ongoing
                      ? "Cancel"
                      : "Re-order",
              width: 139,
              textColor:
                  orderCategory == OrderCategory.ongoing
                      ? kPrimaryColor
                      : kWhiteColor,
              color:
                  orderCategory == OrderCategory.ongoing
                      ? kWhiteColor
                      : kPrimaryColor,
              onPressed: secondButtonOnTap,
            ),
          ],
        ),
        24.verticalSpace,
      ],
    );
  }
}
