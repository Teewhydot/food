import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/food/features/payments/domain/entities/order_entity.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../components/texts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../auth/presentation/widgets/back_widget.dart';
import '../manager/order_tracking/order_tracking_cubit.dart';
import '../manager/order_tracking/order_tracking_state.dart';

enum StepStatus { completed, inProgress, notStarted }

class TrackingOrder extends StatelessWidget {
  final String orderId;

  const TrackingOrder({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderTrackingCubit()..startTrackingOrder(orderId),
      child: _TrackingOrderView(),
    );
  }
}

class _TrackingOrderView extends StatefulWidget {
  @override
  State<_TrackingOrderView> createState() => _TrackingOrderViewState();
}

class _TrackingOrderViewState extends State<_TrackingOrderView> {
  final nav = GetIt.instance<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderTrackingCubit, OrderTrackingState>(
      builder: (context, state) {
        return _buildScaffold(context, state);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, OrderTrackingState state) {
    return FScaffold(
      appBarWidget: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            BackWidget(color: kBlackColor, iconColor: kWhiteColor),
            10.horizontalSpace,
            FText(
              text: "Track Order",
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: kTextColorDark,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppConstants.defaultPadding).r,
        child: _buildOrderContent(state),
      ),
    );
  }

  Widget _buildOrderContent(OrderTrackingState state) {
    return SingleChildScrollView(
      child: switch (state) {
        OrderTrackingLoading() => _buildLoadingState(),
        OrderTrackingError() => _buildErrorState(state.message),
        OrderNotFound() => _buildNotFoundState(),
        OrderTrackingLoaded() => _buildLoadedState(state.order),
        _ => _buildInitialState(),
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(50.0),
        child: CupertinoActivityIndicator(radius: 20),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: EdgeInsets.all(AppConstants.defaultPadding).r,
      child: Column(
        children: [
          Icon(Ionicons.alert_circle_outline, size: 60, color: Colors.red),
          20.verticalSpace,
          FText(
            text: "Error loading order",
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          10.verticalSpace,
          FText(
            text: message,
            fontSize: 14,
            color: kContainerColor,
            alignment: MainAxisAlignment.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Padding(
      padding: EdgeInsets.all(AppConstants.defaultPadding).r,
      child: Column(
        children: [
          Icon(Ionicons.receipt_outline, size: 60, color: kContainerColor),
          20.verticalSpace,
          FText(
            text: "Order Not Found",
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          10.verticalSpace,
          FText(
            text: "The order you're looking for doesn't exist.",
            fontSize: 14,
            color: kContainerColor,
            alignment: MainAxisAlignment.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return const SizedBox();
  }

  Widget _buildLoadedState(OrderEntity order) {
    final DateFormat dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FText(
                    text: "Order ID: ${order.id}",
                    alignment: MainAxisAlignment.start,
                  ),
                  5.verticalSpace,
                  FText(
                    text: "Ordered on: ${dateFormat.format(order.createdAt)}",
                    alignment: MainAxisAlignment.start,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: kContainerColor,
                  ),
                  5.verticalSpace,
                  FText(
                    text: order.restaurantName,
                    alignment: MainAxisAlignment.start,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kPrimaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        36.verticalSpace,
        StepTrackingWidget(orderStatus: order.serviceStatus),
      ],
    );
  }
}

class StepTrackingWidget extends StatelessWidget {
  final OrderStatus orderStatus;
  const StepTrackingWidget({super.key, required this.orderStatus});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StepWidget(
          status: switch (orderStatus) {
            OrderStatus.pending => StepStatus.inProgress,
            OrderStatus.confirmed => StepStatus.completed,
            OrderStatus.preparing => StepStatus.completed,
            OrderStatus.onTheWay => StepStatus.completed,
            OrderStatus.delivered => StepStatus.completed,
            OrderStatus.cancelled => StepStatus.completed,
          },
          message: "Your order has been received",
        ),
        StepWidget(
          status: switch (orderStatus) {
            OrderStatus.pending => StepStatus.notStarted,
            OrderStatus.confirmed => StepStatus.inProgress,
            OrderStatus.preparing => StepStatus.completed,
            OrderStatus.onTheWay => StepStatus.completed,
            OrderStatus.delivered => StepStatus.completed,
            OrderStatus.cancelled => StepStatus.notStarted,
          },
          message: "Order confirmed by restaurant",
        ),
        StepWidget(
          status: switch (orderStatus) {
            OrderStatus.pending => StepStatus.notStarted,
            OrderStatus.confirmed => StepStatus.notStarted,
            OrderStatus.preparing => StepStatus.inProgress,
            OrderStatus.onTheWay => StepStatus.completed,
            OrderStatus.delivered => StepStatus.completed,
            OrderStatus.cancelled => StepStatus.notStarted,
          },
          message: "The restaurant is preparing your order",
        ),
        StepWidget(
          status: switch (orderStatus) {
            OrderStatus.pending => StepStatus.notStarted,
            OrderStatus.confirmed => StepStatus.notStarted,
            OrderStatus.preparing => StepStatus.notStarted,
            OrderStatus.onTheWay => StepStatus.inProgress,
            OrderStatus.delivered => StepStatus.completed,
            OrderStatus.cancelled => StepStatus.notStarted,
          },
          message: "Your order is out for delivery",
        ),
        StepWidget(
          isLastStep: true,
          status: switch (orderStatus) {
            OrderStatus.pending => StepStatus.notStarted,
            OrderStatus.confirmed => StepStatus.notStarted,
            OrderStatus.preparing => StepStatus.notStarted,
            OrderStatus.onTheWay => StepStatus.notStarted,
            OrderStatus.delivered => StepStatus.completed,
            OrderStatus.cancelled => StepStatus.notStarted,
          },
          message:
              orderStatus == OrderStatus.cancelled
                  ? "Your order has been cancelled"
                  : "Your order has been delivered",
        ),
      ],
    );
  }
}

class StepWidget extends StatelessWidget {
  final StepStatus status;
  final String message;
  final bool isLastStep; // New parameter to indicate the last step

  const StepWidget({
    super.key,
    required this.status,
    this.message = "",
    this.isLastStep = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleWidget(
              radius: 10,
              color:
                  status == StepStatus.completed
                      ? kPrimaryColor
                      : status == StepStatus.inProgress
                      ? kPrimaryColor
                      : kInactive,
              child: switch (status) {
                StepStatus.completed => const Icon(
                  size: 10,
                  Ionicons.checkmark,
                  color: kWhiteColor,
                ),
                StepStatus.inProgress => CupertinoActivityIndicator(
                  radius: 5,
                  color: kWhiteColor,
                ),
                StepStatus.notStarted => const Icon(
                  size: 10,
                  Ionicons.checkmark,
                  color: kWhiteColor,
                ),
              },
            ),
            if (!isLastStep) // Conditionally render the Line widget
              Line(
                color:
                    status == StepStatus.completed ? kPrimaryColor : kInactive,
              ),
          ],
        ),
        10.horizontalSpace,
        Text(
          message,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: status == StepStatus.completed ? kPrimaryColor : kInactive,
          ),
        ),
      ],
    );
  }
}

class Line extends StatelessWidget {
  final Color color;
  final double height;
  const Line({super.key, required this.color, this.height = 50});

  @override
  Widget build(BuildContext context) {
    return Container(width: 2, height: height, color: color);
  }
}
