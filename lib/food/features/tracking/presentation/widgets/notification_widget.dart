import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/texts/texts.dart';
import '../../../../core/theme/colors.dart';
import '../../../home/presentation/widgets/circle_widget.dart';

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 10,
          children: [
            CircleWidget(radius: 25, color: kContainerColor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                FRichText(
                  text: "Tunde",
                  text2: ' placed a new order',
                  text2Color: kContainerColor,
                  color: kBlackColor,
                ),
                FText(text: "20mins ago"),
              ],
            ),
          ],
        ).paddingAll(16),
        Divider(color: kGreyColor),
      ],
    );
  }
}
