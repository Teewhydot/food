import 'package:flutter/material.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/tracking/presentation/widgets/chat_bubble.dart';

class ChatStatusWidget extends StatelessWidget {
  final ChatStatus chatStatus;
  const ChatStatusWidget({super.key, required this.chatStatus});

  @override
  Widget build(BuildContext context) {
    return switch (chatStatus) {
      ChatStatus.sent => const Icon(Icons.check, size: 15, color: kBlackColor),
      ChatStatus.delivered => const DeliveredStatusWidget(),
      ChatStatus.read => const DeliveredStatusWidget(color: kPrimaryColor),
    };
  }
}

class DeliveredStatusWidget extends StatelessWidget {
  final Color color;
  const DeliveredStatusWidget({super.key, this.color = kBlackColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.check, size: 15, color: color),
        Positioned(
          top: -3,
          left: 0,
          child: Icon(Icons.check, size: 15, color: color),
        ),
      ],
    );
  }
}
