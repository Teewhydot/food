import 'package:flutter/material.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/services/navigation_service/nav_config.dart';

class BackWidget extends StatelessWidget {
  final Color color, iconColor;
  const BackWidget({
    super.key,
    this.color = kWhiteColor,
    this.iconColor = kBlackColor,
  });

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(45),
      ),
      child: IconButton(
        onPressed: () {
          nav.goBack();
        },
        icon: Icon(Icons.arrow_back_ios_new, color: iconColor, size: 15),
      ),
    );
  }
}
