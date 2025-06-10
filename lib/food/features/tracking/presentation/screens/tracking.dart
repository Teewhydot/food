import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../components/texts/texts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../auth/presentation/widgets/back_widget.dart';
import '../../../onboarding/presentation/widgets/food_container.dart';

enum TrackingStatus { orderPlaced, restaurant, outForDelivery, delivered }

enum StepStatus { completed, inProgress, notStarted }

class TrackingOrder extends StatefulWidget {
  const TrackingOrder({super.key});

  @override
  State<TrackingOrder> createState() => _TrackingOrderState();
}

class _TrackingOrderState extends State<TrackingOrder> {
  final nav = GetIt.instance<NavigationService>();

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(37.43296265331129, -122.08832357078792),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
  );
  @override
  Widget build(BuildContext context) {

    return FScaffold(
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
            body: Column(
              children: [
                Column(
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
                                text: "Order ID: 123456",
                                alignment: MainAxisAlignment.start,
                              ),
                              5.verticalSpace,
                              FText(
                                text: "Ordered on: 2023-10-01",
                                alignment: MainAxisAlignment.start,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: kContainerColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    36.verticalSpace,
                    FText(
                      text: "Estimated Delivery Time",
                      alignment: MainAxisAlignment.center,
                      fontSize: 16,
                      color: kContainerColor,
                      fontWeight: FontWeight.w400,
                    ),
                    10.verticalSpace,
                    FText(
                      text: "30 minutes",
                      alignment: MainAxisAlignment.center,
                      fontSize: 24,
                      color: kTextColorDark,
                      fontWeight: FontWeight.w600,
                    ),
                    36.verticalSpace,
                    StepTrackingWidget(),
                  ],
                ).paddingOnly(left: AppConstants.defaultPadding),
              ],
            ),
          ),
          Positioned(
            top: 50,
            left: AppConstants.defaultPadding,
            child: Container(
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
          ),
        ],
      ),
    );
  }
}

class StepTrackingWidget extends StatelessWidget {
  final TrackingStatus trackingStatus;
  const StepTrackingWidget({
    super.key,
    this.trackingStatus = TrackingStatus.delivered,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StepWidget(
          status: switch (trackingStatus) {
            TrackingStatus.orderPlaced => StepStatus.completed,
            TrackingStatus.restaurant => StepStatus.completed,
            TrackingStatus.outForDelivery => StepStatus.completed,
            TrackingStatus.delivered => StepStatus.completed,
          },
          message: "Your order has been received",
        ),
        StepWidget(
          status: switch (trackingStatus) {
            TrackingStatus.orderPlaced => StepStatus.inProgress,
            TrackingStatus.restaurant => StepStatus.completed,
            TrackingStatus.outForDelivery => StepStatus.completed,
            TrackingStatus.delivered => StepStatus.completed,
          },
          message: "The restaurant is preparing your order",
        ),
        StepWidget(
          status: switch (trackingStatus) {
            TrackingStatus.orderPlaced => StepStatus.notStarted,
            TrackingStatus.restaurant => StepStatus.inProgress,
            TrackingStatus.outForDelivery => StepStatus.completed,
            TrackingStatus.delivered => StepStatus.completed,
          },
          message: "Your order is out for delivery",
        ),
        StepWidget(
          isLastStep: true,
          status: switch (trackingStatus) {
            TrackingStatus.orderPlaced => StepStatus.notStarted,
            TrackingStatus.restaurant => StepStatus.notStarted,
            TrackingStatus.outForDelivery => StepStatus.inProgress,
            TrackingStatus.delivered => StepStatus.completed,
          },
          message: "Your order has been delivered",
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
