import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/helpers/user_extensions.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/tracking/presentation/screens/tracking.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/bloc/base/base_state.dart';
import '../../../../core/bloc/managers/bloc_manager.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../payments/domain/entities/order_entity.dart';
import '../../../payments/presentation/manager/order_bloc/order_bloc.dart';
import '../../../payments/presentation/manager/order_bloc/order_event.dart';

enum OrderCategory { ongoing, history }

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  @override
  void initState() {
    super.initState();
    // Load user orders
    context.read<OrderBloc>().add(
      GetUserOrdersEvent(context.currentUserId ?? ""),
    );
  }

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
              BlocManager<OrderBloc, BaseState<dynamic>>(
                bloc: context.read<OrderBloc>(),
                showLoadingIndicator: true,
                builder: (context, state) {
                  if (state is LoadingState) {
                    return Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    );
                  } else if (state.hasData) {
                    final orders = state.data as List? ?? [];
                    final ongoingOrders =
                        orders
                            .where(
                              (order) =>
                                  order.status == OrderStatus.pending ||
                                  order.status == OrderStatus.confirmed ||
                                  order.status == OrderStatus.preparing ||
                                  order.status == OrderStatus.onTheWay,
                            )
                            .toList();

                    if (ongoingOrders.isEmpty) {
                      return Center(
                        child: FText(
                          text: "No ongoing orders",
                          fontSize: 16,
                          color: kContainerColor,
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children:
                            ongoingOrders.map((order) {
                              // Get first item for display
                              final firstItem =
                                  order.items.isNotEmpty
                                      ? order.items.first
                                      : null;
                              return OrderDetailsWidget(
                                orderCategory: OrderCategory.ongoing,
                                order: order,
                                category: firstItem?.foodName ?? "Food",
                                foodName: firstItem?.foodName ?? "Unknown",
                                price: order.total.toStringAsFixed(2),
                                orderId: order.id,
                                quantity: order.items.fold(
                                  0,
                                  (sum, item) => sum + item.quantity,
                                ),
                                firstButtonOnTap: () {
                                  nav.navigateTo(
                                    Routes.tracking,
                                    arguments: order,
                                  );
                                },
                                secondButtonOnTap: () {
                                  context.read<OrderBloc>().add(
                                    UpdateOrderStatusEvent(
                                      order.id,
                                      OrderStatus.cancelled,
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                      ).paddingOnly(top: 32),
                    );
                  }
                  return SizedBox.shrink();
                },
                child: const SizedBox.shrink(),
              ),
              BlocManager<OrderBloc, BaseState<dynamic>>(
                bloc: context.read<OrderBloc>(),
                child: const SizedBox.shrink(),
                showLoadingIndicator: true,
                builder: (context, state) {
                  if (state is LoadingState) {
                    return Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    );
                  } else if (state.hasData) {
                    final orders = state.data as List? ?? [];
                    final historyOrders =
                        state.data
                            .where(
                              (order) =>
                                  order.status == OrderStatus.delivered ||
                                  order.status == OrderStatus.cancelled,
                            )
                            .toList();

                    if (historyOrders.isEmpty) {
                      return Center(
                        child: FText(
                          text: "No order history",
                          fontSize: 16,
                          color: kContainerColor,
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children:
                            historyOrders.map((order) {
                              // Get first item for display
                              final firstItem =
                                  order.items.isNotEmpty
                                      ? order.items.first
                                      : null;
                              return OrderDetailsWidget(
                                orderCategory: OrderCategory.history,
                                order: order,
                                category: firstItem?.foodName ?? "Food",
                                foodName: firstItem?.foodName ?? "Unknown",
                                price: order.total.toStringAsFixed(2),
                                orderId: order.id,
                                quantity: order.items.fold(
                                  0,
                                  (sum, item) => sum + item.quantity,
                                ),
                                firstButtonOnTap: () {
                                  // TODO: Implement rating
                                },
                                secondButtonOnTap: () {
                                  // TODO: Implement re-order
                                },
                              );
                            }).toList(),
                      ).paddingOnly(top: 32),
                    );
                  }
                  return SizedBox.shrink();
                },
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
  final OrderEntity? order;
  final Function()? firstButtonOnTap, secondButtonOnTap;

  const OrderDetailsWidget({
    super.key,
    required this.orderCategory,
    required this.category,
    required this.foodName,
    required this.price,
    required this.orderId,
    required this.quantity,
    this.order,
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
