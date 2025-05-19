import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons/buttons.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:food/food/features/payments/domain/entities/payment_method_entity.dart';
import 'package:food/food/features/payments/presentation/widgets/payment_type_widget.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/utils.dart';

import '../../../../components/texts/texts.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  List<PaymentMethodEntity> methods = [
    PaymentMethodEntity(
      id: '1',
      name: 'Cash',
      type: 'cash',
      iconUrl: Assets.svgsCash,
    ),
    PaymentMethodEntity(
      id: '2',
      name: 'Visa',
      type: 'card',
      iconUrl: Assets.svgsVisa,
    ),
    PaymentMethodEntity(
      id: '3',
      name: 'Mastercard',
      type: 'card',
      iconUrl: Assets.svgsMastercard,
    ),
    PaymentMethodEntity(
      id: '4',
      name: 'Paypal',
      type: 'paypal',
      iconUrl: Assets.svgsPaypal,
    ),
  ];
  String selectedMethod = "Cash";

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      body: Column(
        children: [
          50.verticalSpace,
          Row(
            children: [
              BackWidget(
                color: kGreyColor,
              ),
              20.horizontalSpace,
              FText(
                text: "Payment Method",
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
          30.verticalSpace,

          SingleChildScrollView(scrollDirection: Axis.horizontal,
      
            child: Row(
              spacing: 10,
              children: [
                ...methods.map((method) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMethod = method.name;
                      });
                    },
                    child: PaymentTypeWidget(
                      image: method.iconUrl,
                      title: method.name,
                      width: 24,
                      height: 24,
                      isSelected: selectedMethod == method.name,
                    ),
                  );
                }),
              ],
            ),
          ),
          30.verticalSpace,
          FoodContainer(
            height: 82,
            width: 1.sw,
            color: kGreyColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FText(
                    text: "Mastercard",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  5.verticalSpace,
                 Row(
                   children: [
                     FImage(assetPath: Assets.svgsMastercard, width: 28, height: 17, assetType: FoodAssetType.svg),
                      10.horizontalSpace,
                       FText(
                    text: "**** **** **** 1234",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: kBlackColor,
                  ),
                   ],
                 ),
                 
                ],
              ),
              FImage(
                assetPath: Assets.svgsArrowDown,
                width: 10,
                height: 10,
                assetType: FoodAssetType.svg,
              ),
            ],).paddingAll(10),
          ).paddingOnly(right: AppConstants.defaultPadding),
          20.verticalSpace,
          FButton(buttonText: "Add New Card",textColor: kPrimaryColor, onPressed: () {},borderColor: kGreyColor, width: 1.sw, height: 50, color: kWhiteColor).paddingOnly(right: AppConstants.defaultPadding),
          20.verticalSpace,
          FoodContainer(
            height: 257,
            width: 1.sw,
            color: kGreyColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FImage(
                  assetPath: Assets.svgsEmptyCard,
                  width: 100,
                  height: 100,
                  assetType: FoodAssetType.svg,
                ),
                20.verticalSpace,
                FText(
                  text: "No Cards Added",
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                10.verticalSpace,
                FText(
                  text: "Add your card to make payments",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ],
          )).paddingOnly(
            right: AppConstants.defaultPadding,
        
          ),
        ],
      ).paddingOnly(left: AppConstants.defaultPadding),
    );
  }
}
