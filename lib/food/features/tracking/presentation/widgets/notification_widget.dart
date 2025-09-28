import 'package:flutter/material.dart';
import 'package:food/food/features/tracking/domain/entities/notification_entity.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../components/texts.dart';
import '../../../../core/theme/colors.dart';

class NotificationWidget extends StatelessWidget {
  final NotificationEntity notificationEntity;
  const NotificationWidget({super.key, required this.notificationEntity});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kPrimaryColor, width: 1),
          ),
          child: Row(
            spacing: 10,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    FText(
                      text: notificationEntity.title,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),

                    FWrapText(
                      text: notificationEntity.body,
                      fontSize: 12,
                      color: kGreyColor,
                      textAlign: TextAlign.left,
                      alignment: Alignment.centerLeft,
                    ),
                    FText(
                      text: timeago.format(notificationEntity.createdAt),
                      fontSize: 12,
                      color: kGreyColor,
                    ),
                  ],
                ),
              ),
            ],
          ).paddingAll(16),
        ),
      ],
    ).paddingOnly(bottom: 10);
  }
}
