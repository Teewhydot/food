import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/features/auth/presentation/widgets/back_widget.dart';
import 'package:food/food/features/payments/presentation/widgets/payment_type_widget.dart';
import 'package:food/generated/assets.dart';

import '../../../../components/texts/texts.dart';

class PaymentMethod extends StatelessWidget {
  const PaymentMethod({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      body: Column(
        children: [
          50.verticalSpace,
          Row(
            children: [
              BackWidget(),
              20.horizontalSpace,
              FText(
                text: "Payment Method",
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
          30.verticalSpace,
          PaymentTypeWidget(
            image: Assets.svgsCash,
            title: "Cash",
            width: 24,
            height: 24,
          ),
        ],
      ),
    );
  }
}
