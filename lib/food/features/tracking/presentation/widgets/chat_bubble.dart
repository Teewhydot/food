import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/texts/texts.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:get/get.dart';

import 'chat_status_widget.dart';

enum BubbleType { sender, receiver }

enum ChatStatus { sent, delivered, read }

class CustomChatBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isSender;

  const CustomChatBubble({
    super.key,
    required this.message,
    required this.time,
    this.isSender = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isSender) CircleWidget(radius: 15, color: kGreyColor),
        if (!isSender) 8.horizontalSpace,
        if (isSender) ChatStatusWidget(chatStatus: ChatStatus.delivered),
        if (isSender) 5.horizontalSpace,

        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isSender ? kPrimaryColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              constraints: const BoxConstraints(maxWidth: 250),
              child: Text(
                message,
                style: TextStyle(
                  color: isSender ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
            Positioned(
              top: -15,
              right: isSender ? null : 0,
              left: isSender ? 0 : null,
              child: Text(
                time,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ],
        ),

        if (isSender) 8.horizontalSpace,
        if (isSender) CircleWidget(radius: 15, color: kGreyColor),
      ],
    ).paddingSymmetric(vertical: 20);
  }
}
