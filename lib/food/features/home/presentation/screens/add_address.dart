import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons/buttons.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/textfields.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/onboarding/presentation/widgets/food_container.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/services/navigation_service/nav_config.dart';

class AddAddress extends StatelessWidget {
  const AddAddress({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();

    return FScaffold(
      appBarWidget: Row(
        children: [
          BackWidget(color: kGreyColor),
          10.horizontalSpace,
          FText(
            text: "Add new address",
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              30.verticalSpace,
              FTextField(hintText: "Address", action: TextInputAction.next),
              10.verticalSpace,
              Row(
                spacing: 15,
                children: [
                  Expanded(
                    child: FTextField(
                      hintText: "Street",
                      action: TextInputAction.next,
                    ),
                  ),
                  Expanded(
                    child: FTextField(
                      hintText: "Post code",
                      action: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              10.verticalSpace,
              FTextField(hintText: "Apartment", action: TextInputAction.next),
              30.verticalSpace,
              FText(
                text: "Label as".toUpperCase(),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                alignment: MainAxisAlignment.start,
              ),
              10.verticalSpace,
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: FoodContainer(
                      width: 95,
                      height: 45,
                      color: kGreyColor,
                      borderRadius: 22,
                      child: FText(
                        text: "Home",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        alignment: MainAxisAlignment.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: FoodContainer(
                      width: 95,
                      height: 45,
                      color: kGreyColor,
                      borderRadius: 22,
                      child: FText(
                        text: "Work",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        alignment: MainAxisAlignment.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: FoodContainer(
                      width: 95,
                      height: 45,
                      color: kGreyColor,
                      borderRadius: 22,
                      child: FText(
                        text: "Other",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        alignment: MainAxisAlignment.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          FButton(buttonText: "Save Address", width: 1.sw),
        ],
      ).paddingOnly(
        left: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
        bottom: AppConstants.defaultPadding,
      ),
    );
  }
}
