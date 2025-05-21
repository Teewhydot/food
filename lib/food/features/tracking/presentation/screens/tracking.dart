import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sliding_box/flutter_sliding_box.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../components/texts/texts.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../onboarding/presentation/widgets/food_container.dart';

enum TrackingStatus { orderPlaced, restaurant, outForDelivery, delivered }

enum StepStatus { completed, inProgress, notStarted }

class TrackingOrder extends StatefulWidget {
  const TrackingOrder({super.key});

  @override
  State<TrackingOrder> createState() => _TrackingOrderState();
}

class _TrackingOrderState extends State<TrackingOrder> {
  double _calculateChildSize(double height, double maxHeight) {
    // Calculate what fraction of the screen height the given pixel height represents
    return height / maxHeight;
  }

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FoodContainer(
              color: kGreyColor,
              child: Column(
                children: [
                  50.verticalSpace,
                  Row(
                    children: [
                      BackWidget(color: kContainerColor),
                      10.horizontalSpace,
                      FText(
                        text: "Track Order",
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: kTextColorDark,
                      ),
                    ],
                  ),
                ],
              ).paddingOnly(left: AppConstants.defaultPadding),
            ),
          ),
          SlidingBox(
            width: 1.sw,
            minHeight: 1.sh * 0.2,
            maxHeight: 1.sh * 0.8,
            style: BoxStyle.none,
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
  const Line({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 2, height: 50, color: color);
  }
}
