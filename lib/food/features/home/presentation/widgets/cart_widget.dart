import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../../generated/assets.dart';
import '../../../../components/image.dart';
import '../../../../components/texts/texts.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../../core/theme/colors.dart';
import 'circle_widget.dart';

class CartWidget extends StatelessWidget {
  const CartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();
    return Stack(
      children: [
        CircleWidget(
          radius: 22.5,
          color: kAuthBgColor,
          onTap: () {
            nav.navigateTo(Routes.cart);
          },
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
          child: CircleWidget(
            radius: 10,
            color: kPrimaryColor,
            onTap: null,
            child: FText(text: "2", fontSize: 10, color: kWhiteColor),
          ),
        ),
      ],
    );
  }
}
