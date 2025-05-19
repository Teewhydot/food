import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/buttons/buttons.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/textfields.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:get/get_utils/get_utils.dart';

class AddCard extends StatelessWidget {
  const AddCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(body: Column(
      children: [
        Row(
          children: [
            const BackWidget(
              color: kGreyColor,
            ),
    
          ],
        ),
        FText(
          text: "Add New Card",
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        20.verticalSpace,
        FTextField(
          hintText: "Card Number",
          keyboardType: TextInputType.number,
          action: TextInputAction.next,
        ),
        20.verticalSpace,
        FTextField(
          hintText: "Cardholder Name",
          keyboardType: TextInputType.name,
          action: TextInputAction.next,
        ),
        20.verticalSpace,
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: FTextField(
                hintText: "Expiry Date",
                keyboardType: TextInputType.datetime,
                action: TextInputAction.next,
              ),
            ),
            20.verticalSpace,
            Expanded(
              child: FTextField(
                hintText: "CVV",
                keyboardType: TextInputType.number,
                action: TextInputAction.done,
              ),
            ),
          ],
        ),
        const Spacer(),
        FButton(
          buttonText: "Add Card",
          onPressed: () {},
        ),
      ],
    ).paddingAll(AppConstants.defaultPadding));
  }
}