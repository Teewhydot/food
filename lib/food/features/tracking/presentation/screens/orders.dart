import 'dart:async';

import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dartz/dartz.dart' hide State;

import '../../../../components/scaffold.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../payments/domain/entities/order_entity.dart';
import '../../../payments/presentation/manager/order_bloc/order_bloc.dart';
import '../../../payments/presentation/manager/order_bloc/order_event.dart';
import '../../../../domain/failures/failures.dart';
import '../../../auth/data/remote/data_sources/user_data_source.dart';

enum OrderCategory { ongoing, history }

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final nav = GetIt.instance<NavigationService>();
  final userDataSource = GetIt.instance<UserDataSource>();
  late OrderBloc _orderBloc;
  late Stream<Either<Failure, List<OrderEntity>>> _ordersStream;

  @override
  void initState() {
    super.initState();
    _orderBloc = OrderBloc();
    _initializeStream();
  }

  @override
  void dispose() {
    _orderBloc.close();
    super.dispose();
  }

  void _initializeStream() async {
    try {
      final currentUser = await userDataSource.getCurrentUser();
      if (currentUser.id != null) {
        _ordersStream = _orderBloc
            .streamUserOrders(currentUser.id!)
            .distinct();
      }
    } catch (e) {
      // Handle error - stream will show error state
    }
  }

  Widget _buildOrdersTab(OrderCategory category) {
    return StreamBuilder<Either<Failure, List<OrderEntity>>>(
      stream: _ordersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: kPrimaryColor),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState("${snapshot.error}");
        }

        if (snapshot.hasData) {
          return snapshot.data!.fold(
            (failure) => _buildErrorState(failure.toString()),
            (orders) => _buildOrdersList(orders, category),
          );
        }

        return _buildErrorState("No orders found");
      },
    );
  }

  Widget _buildOrdersList(List<OrderEntity> orders, OrderCategory category) {
    List<OrderEntity> filteredOrders;

    if (category == OrderCategory.ongoing) {
      filteredOrders = orders
          .where((order) =>
              order.status == OrderStatus.pending ||
              order.status == OrderStatus.preparing ||
              order.status == OrderStatus.onTheWay)
          .toList();
    } else {
      filteredOrders = orders
          .where((order) =>
              order.status == OrderStatus.delivered ||
              order.status == OrderStatus.cancelled)
          .toList();
    }

    if (filteredOrders.isEmpty) {
      return Center(
        child: FText(
          text: category == OrderCategory.ongoing
              ? "No ongoing orders"
              : "No order history",
          fontSize: 16,
          color: kContainerColor,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: filteredOrders.map((order) {
          final firstItem = order.items.isNotEmpty ? order.items.first : null;
          return OrderDetailsWidget(
            orderCategory: category,
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
              if (category == OrderCategory.ongoing) {
                nav.navigateTo(Routes.tracking, arguments: order.id);
              } else {
                // TODO: Implement rating
              }
            },
            secondButtonOnTap: () {
              if (category == OrderCategory.ongoing) {
                _orderBloc.add(CancelOrderEvent(order.id));
              } else {
                // TODO: Implement re-order
              }
            },
          );
        }).toList(),
      ).paddingOnly(top: 32),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: FText(
        text: "Error: $message",
        fontSize: 14,
        color: kErrorColor,
        textAlign: TextAlign.center,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return FScaffold(
      appBarWidget: Row(
        children: [
          BackWidget(color: kGreyColor),
          20.horizontalSpace,
          FText(text: "My Orders", fontWeight: FontWeight.w700, fontSize: 17),
        ],
      ),

      body: Column(
        children: [
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
                // Ongoing Orders Tab
                _buildOrdersTab(OrderCategory.ongoing),
                // History Orders Tab
                _buildOrdersTab(OrderCategory.history),
              ],
            ),
          ),
        ],
      ).paddingOnly(
        left: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
      ),
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
                      Container(
                        width: 1,
                        height: 16,
                        color: kContainerColor,
                      ),
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
