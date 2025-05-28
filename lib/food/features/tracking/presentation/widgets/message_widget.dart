import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/texts/texts.dart';
import '../../../../core/theme/colors.dart';
import '../../../home/presentation/widgets/circle_widget.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 10,
          children: [
            CircleWidget(radius: 25, color: kContainerColor),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FText(text: "Tunde idiagbon", color: kBlackColor),
                      FText(text: "3:00", color: kBlackColor),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      FText(
                        text: "Sounds Awesome bro",
                        fontSize: 12,
                        color: kContainerColor,
                      ),
                      CircleWidget(
                        radius: 11,
                        color: kPrimaryColor,
                        child: FText(
                          text: "1",
                          color: kWhiteColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ).paddingAll(16),
        Divider(color: kGreyColor),
      ],
    );
  }
}
