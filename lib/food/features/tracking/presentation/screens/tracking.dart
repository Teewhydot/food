import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/food/features/payments/domain/entities/order_entity.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';
import 'package:intl/intl.dart';

import '../../../../components/texts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../auth/presentation/widgets/back_widget.dart';
import '../../../onboarding/presentation/widgets/food_container.dart';
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

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

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
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: _kGooglePlex,
              mapType: MapType.normal,
              markers: {
                Marker(
                  markerId: const MarkerId("marker_1"),
                  position: const LatLng(37.42796133580664, -122.085749655962),
                  infoWindow: const InfoWindow(
                    title: "Marker 1",
                    snippet: "This is marker 1",
                  ),
                ),
                Marker(
                  markerId: const MarkerId("marker_2"),
                  position: const LatLng(
                    37.43296265331129,
                    -122.08832357078792,
                  ),
                  infoWindow: const InfoWindow(
                    title: "Marker 2",
                    snippet: "This is marker 2",
                  ),
                ),
              },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),

          SlidingBox(
            width: 1.sw,
            minHeight: 1.sh * 0.2,
            maxHeight: 1.sh * 0.8,
            style: BoxStyle.none,
            collapsed: true,
            draggableIconBackColor: kWhiteColor,
            body: _buildOrderContent(state),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderContent(OrderTrackingState state) {
    return Column(
      children: [
        switch (state) {
          OrderTrackingLoading() => _buildLoadingState(),
          OrderTrackingError() => _buildErrorState(state.message),
          OrderNotFound() => _buildNotFoundState(),
          OrderTrackingLoaded() => _buildLoadedState(state.order),
          _ => _buildInitialState(),
        },
      ],
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
            FoodContainer(width: 63, height: 63, borderRadius: 10),
            10.horizontalSpace,
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
        FText(
          text: "Order Status",
          alignment: MainAxisAlignment.center,
          fontSize: 16,
          color: kContainerColor,
          fontWeight: FontWeight.w400,
        ),
        10.verticalSpace,
        FText(
          text: _getStatusDisplayText(order.status),
          alignment: MainAxisAlignment.center,
          fontSize: 24,
          color: kTextColorDark,
          fontWeight: FontWeight.w600,
        ),
        36.verticalSpace,
        StepTrackingWidget(orderStatus: order.status),
      ],
    ).paddingOnly(left: AppConstants.defaultPadding);
  }

  String _getStatusDisplayText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return "Order Received";
      case OrderStatus.confirmed:
        return "Order Confirmed";
      case OrderStatus.preparing:
        return "Being Prepared";
      case OrderStatus.onTheWay:
        return "Out for Delivery";
      case OrderStatus.delivered:
        return "Delivered";
      case OrderStatus.cancelled:
        return "Cancelled";
    }
  }
}

class StepTrackingWidget extends StatelessWidget {
  final OrderStatus orderStatus;
  const StepTrackingWidget({
    super.key,
    required this.orderStatus,
  });

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
          message: orderStatus == OrderStatus.cancelled
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
        FText(
          text: message,
          alignment: MainAxisAlignment.start,
          fontSize: 16,
          color: status == StepStatus.completed ? kPrimaryColor : kInactive,
          fontWeight: FontWeight.w600,
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
