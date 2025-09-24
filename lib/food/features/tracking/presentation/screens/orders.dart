import 'dart:async';

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
import 'package:dartz/dartz.dart' hide State;

import '../../../../components/scaffold.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../payments/domain/entities/order_entity.dart';
import '../../../payments/presentation/manager/order_bloc/order_bloc.dart';
import '../../../payments/presentation/manager/order_bloc/order_event.dart';
import '../../../../domain/failures/failures.dart';

enum OrderCategory { ongoing, history }

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders>
    with AutomaticKeepAliveClientMixin {
  final nav = GetIt.instance<NavigationService>();
  late Stream<Either<Failure, List<OrderEntity>>> _ordersStream;
  bool _streamInitialized = false;

  @override
  bool get wantKeepAlive => true; // Keep tabs alive to prevent recreation


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_streamInitialized) {
      _initializeStream();
      _streamInitialized = true;
    }
  }

  void _initializeStream() {
    try {
      final userId = context.readCurrentUserId;
      if (userId != null && userId.isNotEmpty) {
        _ordersStream = context.read<OrderBloc>()
            .streamUserOrders(userId)
            .distinct(); // Prevent unnecessary rebuilds for same data
      }
    } catch (e) {
      // Fallback: reinitialize on next frame if context not ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_streamInitialized) {
          _initializeStream();
          _streamInitialized = true;
        }
      });
    }
  }

  void _retryStreamInitialization() {
    _streamInitialized = false;
    _initializeStream();
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildOrdersTab(OrderCategory category) {
    if (!_streamInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: kPrimaryColor),
            16.verticalSpace,
            FText(
              text: "Loading orders...",
              fontSize: 14,
              color: kContainerColor,
            ),
          ],
        ),
      );
    }

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
            (failure) => _buildErrorState(failure.failureMessage),
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
                nav.navigateTo(Routes.tracking);
              } else {
                // TODO: Implement rating
              }
            },
            secondButtonOnTap: () {
              if (category == OrderCategory.ongoing) {
                context.read<OrderBloc>().add(CancelOrderEvent(order.id));
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FText(
            text: "Error: $message",
            fontSize: 14,
            color: kErrorColor,
            textAlign: TextAlign.center,
          ),
          16.verticalSpace,
          FButton(
            buttonText: "Retry",
            width: 120,
            height: 40,
            onPressed: _retryStreamInitialization,
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

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
