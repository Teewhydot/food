import 'package:flutter/material.dart';
import 'package:food/food/features/tracking/domain/entities/notification_entity.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../components/texts.dart';
import '../../../../core/theme/colors.dart';
import '../../../home/presentation/widgets/circle_widget.dart';

class NotificationWidget extends StatelessWidget {
  final NotificationEntity notificationEntity;
  const NotificationWidget({super.key, required this.notificationEntity});

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
                FWrapText(text: notificationEntity.body),
                // FRichText(
                //   text: "Tunde",
                //   text2: ' placed a new order',
                //   text2Color: kContainerColor,
                //   color: kBlackColor,
                // ),
                FText(
                  text: timeago.format(notificationEntity.createdAt),
                  fontSize: 12,
                  color: kGreyColor,
                ),
              ],
            ),
          ],
        ).paddingAll(16),
        Divider(color: kGreyColor),
      ],
    );
  }
}
