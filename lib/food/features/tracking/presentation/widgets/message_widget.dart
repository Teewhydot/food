import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../components/texts.dart';
import '../../../../core/theme/colors.dart';
import '../../../home/presentation/widgets/circle_widget.dart';
import '../../domain/entities/chat_entity.dart';

class MessageWidget extends StatelessWidget {
  final ChatEntity chat;
  final VoidCallback? onTap;
  const MessageWidget({super.key, required this.chat, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            spacing: 10,
            children: [
              CircleWidget(radius: 25, color: kContainerColor, onTap: null),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FText(text: chat.receiverID, color: kBlackColor),
                        FText(
                          text: _formatTime(chat.lastMessageTime),
                          color: kBlackColor,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: FText(
                            text: chat.lastMessage,
                            fontSize: 12,
                            color: kContainerColor,
                          ),
                        ),
                        //   if (chat.un > 0)
                        //     CircleWidget(
                        //       radius: 11,
                        //       color: kPrimaryColor,
                        //       onTap: null,
                        //       child: FText(
                        //         text: chat.unreadCount.toString(),
                        //         color: kWhiteColor,
                        //         fontSize: 12,
                        //       ),
                        //     ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ).paddingAll(16),
          Divider(color: kGreyColor),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
