import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons/buttons.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';
enum PaymentStatusEnum { success, failure, pending }
class PaymentStatus extends StatelessWidget {
  final PaymentStatusEnum status;
  const PaymentStatus({super.key, this.status = PaymentStatusEnum.success});

  @override
  Widget build(BuildContext context) {
    return  FScaffold(

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         Column(
           children: [
            238.verticalSpace,
             FImage(assetPath: Assets.svgsSuccess,
                width: 260,
                height: 181,
                assetType: FoodAssetType.svg,
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
               const Text(
            'Thank you for your purchase!',
            style: TextStyle(fontSize: 16),
          ),
           ],
         ),
         Spacer(),
              FButton(
        buttonText: "Track Order",
        width: 1.sw,
        color: kPrimaryColor,
      ),
        ],
      ).paddingAll(AppConstants.defaultPadding),
    );
  }
}