import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons/buttons.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/routes/routes.dart';
import '../../../../core/services/navigation_service/nav_config.dart';

enum PaymentStatusEnum { success, failure, pending }

class PaymentStatus extends StatelessWidget {
  final PaymentStatusEnum status;
  const PaymentStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();

    return FScaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              238.verticalSpace,
              status == PaymentStatusEnum.success
                  ? FImage(
                    assetPath: Assets.svgsSuccessful,
                    width: 260,
                    height: 181,
                    assetType: FoodAssetType.svg,
                  )
                  : CircleWidget(
                    color: kErrorColor,
                    radius: 60,
                    child: Icon(Icons.close, size: 90),
                  ),
              32.verticalSpace,
              status == PaymentStatusEnum.success
                  ? const Text(
                    'Payment Successful',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  )
                  : const Text(
                    'Payment Failed',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
              16.verticalSpace,
              Text(
                status == PaymentStatusEnum.success
                    ? 'Thank you for your purchase!'
                    : "Something went wrong, please try again.",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          Spacer(),
          FButton(
            buttonText:
                status == PaymentStatusEnum.success
                    ? "Track Order"
                    : "Retry Payment",
            width: 1.sw,
            color: kPrimaryColor,
            onPressed: () {
              status == PaymentStatusEnum.success
                  ? nav.navigateAndOffAll(Routes.tracking, Routes.home)
                  : nav.goBack();
            },
          ),
        ],
      ).paddingAll(AppConstants.defaultPadding),
    );
  }
}
