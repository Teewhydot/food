import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons/buttons.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/texts/texts.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/widgets/back_widget.dart';

enum AddressType { home, work }

class Address extends StatelessWidget {
  const Address({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();

    return FScaffold(
      useSafeArea: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      BackWidget(color: kGreyColor),
                      20.horizontalSpace,
                      FText(
                        text: "My Addresses",
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w400,
                        color: kBlackColor,
                      ),
                    ],
                  ),
                  24.verticalSpace,
                  AddressWidget(addressType: AddressType.home, address: ""),
                  AddressWidget(
                    addressType: AddressType.home,
                    address: "Car park from buggatti veyron farreri la ferrari",
                  ),
                ],
              ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: FButton(
              buttonText: "Add new address",
              width: 1.sw,
            ).paddingSymmetric(horizontal: AppConstants.defaultPadding),
          ),
        ],
      ),
    );
  }
}

class AddressWidget extends StatelessWidget {
  final AddressType addressType;
  final String address;
  const AddressWidget({
    super.key,
    required this.addressType,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return FoodContainer(
      width: 1.sw,
      height: 101,
      color: kTextFieldColor,
      borderRadius: 16,
      child: Row(
        children: [
          CircleWidget(
            radius: 24,
            color: kWhiteColor,
            child: FImage(
              width: 20,
              height: 20,
              assetType: FoodAssetType.svg,
              assetPath:
                  addressType == AddressType.home
                      ? Assets.svgsHomeAddress
                      : Assets.svgsWorkAddress,
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
                      text: addressType == AddressType.home ? "Home" : "Work",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    Row(
                      children: [
                        FImage(
                          assetPath: Assets.svgsEditAddress,
                          width: 20,
                          height: 20,
                          assetType: FoodAssetType.svg,
                        ),
                        20.horizontalSpace,
                        FImage(
                          assetPath: Assets.svgsDeleteAddress,
                          width: 20,
                          height: 20,
                          assetType: FoodAssetType.svg,
                        ),
                      ],
                    ),
                  ],
                ),
                10.verticalSpace,
                FWrapText(
                  text: address,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  textAlign: TextAlign.start,
                  textOverflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ).paddingAll(16),
    ).paddingOnly(bottom: 20);
  }
}
