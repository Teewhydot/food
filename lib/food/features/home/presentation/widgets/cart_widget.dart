import 'package:flutter/material.dart';

import '../../../../../generated/assets.dart';
import '../../../../components/image.dart';
import '../../../../components/texts/texts.dart';
import '../../../../core/theme/colors.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 22.5,
          backgroundColor: kAuthBgColor,
          child: FImage(
            assetPath: Assets.svgsCartIcon,
            assetType: FoodAssetType.svg,
            svgAssetColor: kWhiteColor,
            width: 18,
            height: 20,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: CircleAvatar(
            radius: 10,
            backgroundColor: kPrimaryColor,
            child: FText(text: "2", fontSize: 10, color: kWhiteColor),
          ),
        ),
      ],
    );
  }
}
