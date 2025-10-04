import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons.dart';
import 'package:food/food/components/texts.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/helpers/user_extensions.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../components/scaffold.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../domain/failures/failures.dart';
import '../../../auth/data/remote/data_sources/user_data_source.dart';
import '../../../payments/domain/entities/order_entity.dart';
import '../../../payments/presentation/manager/order_bloc/order_bloc.dart';
import '../../../payments/presentation/manager/order_bloc/order_event.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final nav = GetIt.instance<NavigationService>();
  final userDataSource = GetIt.instance<UserDataSource>();
  late Stream<Either<Failure, List<OrderEntity>>> _ordersStream;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() async {
    _ordersStream = context.read<OrderBloc>().streamUserOrders(
      context.readCurrentUserId ?? "",
    ).distinct();
  }

  Widget _buildOrdersList() {
    return StreamBuilder<Either<Failure, List<OrderEntity>>>(
      stream: _ordersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: kPrimaryColor));
        }

        if (snapshot.hasError) {
          return _buildErrorState("${snapshot.error}");
        }

        if (snapshot.hasData) {
          return snapshot.data!.fold(
            (failure) => _buildErrorState(failure.toString()),
            (orders) {
              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Ionicons.receipt_outline,
                        size: 80,
                        color: kContainerColor,
                      ),
                      20.verticalSpace,
                      FText(
                        text: "No orders yet",
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: kContainerColor,
                      ),
                      10.verticalSpace,
                      FText(
                        text: "Your order history will appear here",
                        fontSize: 14,
                        color: kContainerColor,
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: orders.map((order) {
                    final firstItem =
                        order.items.isNotEmpty ? order.items.first : null;
                    return OrderDetailsWidget(
                      order: order,
                      category: firstItem?.foodName ?? "Food",
                      foodName: firstItem?.foodName ?? "Unknown",
                      price: order.total.toStringAsFixed(2),
                      orderId: order.id,
                      quantity: order.items.fold(
                        0,
                        (sum, item) => sum + item.quantity,
                      ),
                      onTrackTap: () {
                        nav.navigateTo(Routes.tracking, arguments: order.id);
                      },
                      onCancelTap: () {
                        context.read<OrderBloc>().add(CancelOrderEvent(order.id));
                      },
                    );
                  }).toList(),
                ).paddingOnly(top: 24),
              );
            },
          );
        }

        return _buildErrorState("No orders found");
      },
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
      body: _buildOrdersList().paddingOnly(
        left: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
      ),
    );
  }
}

class OrderDetailsWidget extends StatelessWidget {
  final String category, foodName, price, orderId;
  final int quantity;
  final OrderEntity order;
  final Function()? onTrackTap, onCancelTap;

  const OrderDetailsWidget({
    super.key,
    required this.category,
    required this.foodName,
    required this.price,
    required this.orderId,
    required this.quantity,
    required this.order,
    this.onTrackTap,
    this.onCancelTap,
  });

  Color _getStatusColor() {
    switch (order.status) {
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.pending:
        return Colors.orange;
      default:
        return kPrimaryColor;
    }
  }

  String _getStatusText() {
    switch (order.status) {
      case OrderStatus.pending:
        return "Pending Payment";
      case OrderStatus.confirmed:
        return "Confirmed";
      case OrderStatus.preparing:
        return "Preparing";
      case OrderStatus.onTheWay:
        return "On the Way";
      case OrderStatus.delivered:
        return "Delivered";
      case OrderStatus.cancelled:
        return "Cancelled";
    }
  }

  IconData _getStatusIcon() {
    switch (order.status) {
      case OrderStatus.delivered:
        return Ionicons.checkmark_circle;
      case OrderStatus.cancelled:
        return Ionicons.close_circle;
      case OrderStatus.pending:
        return Ionicons.time_outline;
      default:
        return Ionicons.ellipse_outline;
    }
  }

  bool _canTrack() {
    return order.status != OrderStatus.delivered &&
        order.status != OrderStatus.cancelled;
  }

  bool _canCancel() {
    return order.status == OrderStatus.pending ||
        order.status == OrderStatus.confirmed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16).r,
      padding: EdgeInsets.all(16).r,
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(12).r,
        border: Border.all(color: kContainerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: kContainerColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10).r,
                ),
                child: Icon(
                  Ionicons.fast_food_outline,
                  color: kPrimaryColor,
                  size: 30,
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
                        Expanded(
                          child: FText(
                            text: foodName,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        8.horizontalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ).r,
                          decoration: BoxDecoration(
                            color: _getStatusColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12).r,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(),
                                color: _getStatusColor(),
                                size: 14,
                              ),
                              4.horizontalSpace,
                              FText(
                                text: _getStatusText(),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                color: _getStatusColor(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    4.verticalSpace,
                    FText(
                      text: "Order ID: $orderId",
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: kContainerColor,
                    ),
                    4.verticalSpace,
                    Row(
                      children: [
                        FText(
                          text: "\$$price",
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: kBlackColor,
                        ),
                        8.horizontalSpace,
                        Container(width: 1, height: 16, color: kContainerColor),
                        8.horizontalSpace,
                        FText(
                          text: "$quantity ${quantity > 1 ? 'items' : 'item'}",
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
          if (_canTrack() || _canCancel()) ...[
            16.verticalSpace,
            Row(
              children: [
                if (_canTrack())
                  Expanded(
                    child: FButton(
                      buttonText: "Track Order",
                      textColor: kWhiteColor,
                      onPressed: onTrackTap,
                      color: kPrimaryColor,
                    ),
                  ),
                if (_canTrack() && _canCancel()) 12.horizontalSpace,
                if (_canCancel())
                  Expanded(
                    child: FButton(
                      buttonText: "Cancel",
                      textColor: kPrimaryColor,
                      color: kWhiteColor,
                      onPressed: onCancelTap,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
