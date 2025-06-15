import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:food/food/components/image.dart';
import 'package:food/food/components/scaffold.dart';
import 'package:food/food/components/textfields.dart';
import 'package:food/food/core/constants/app_constants.dart';
import 'package:food/food/core/theme/colors.dart';
import 'package:food/food/features/home/presentation/widgets/circle_widget.dart';
import 'package:food/food/features/tracking/presentation/widgets/chat_bubble.dart';
import 'package:food/generated/assets.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../../../components/texts/texts.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../auth/presentation/widgets/back_widget.dart';

enum ChatType { text, image, video }

enum Origin { sender, receiver }

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = GetIt.instance<NavigationService>();

    return FScaffold(
      customScroll: false,
      showNavBar: true,
      appBarWidget: Row(
        children: [
          BackWidget(color: kGreyColor, iconColor: kBlackColor),
          10.horizontalSpace,
          FText(
            text: "Robert Fox",
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: kTextColorDark,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: true,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: false,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: false,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: true,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: true,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: false,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: false,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: true,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: true,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: false,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: false,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: true,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: true,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: false,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: false,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: true,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: true,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: false,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: false,
                  ),
                  CustomChatBubble(
                    message: "Hello, how are you?",
                    time: "8:23PM",
                    isSender: true,
                  ),
                ],
              ).paddingOnly(
                left: AppConstants.defaultPadding,
                right: AppConstants.defaultPadding,
              ),
            ),
          ),
          FTextField(
            height: 63,
            hintText: "Type something",
            action: TextInputAction.send,
            prefix: Icon(Icons.emoji_emotions_outlined),
            suffix: CircleWidget(
              radius: 21,
              color: kWhiteColor,
              child: FImage(
                assetPath: Assets.svgsSend,
                width: 20,
                height: 20,
                assetType: FoodAssetType.svg,
                svgAssetColor: kPrimaryColor,
              ),
            ),
            keyboardType: TextInputType.text,
          ).paddingOnly(
            left: AppConstants.defaultPadding,
            bottom: AppConstants.defaultPadding,
            right: AppConstants.defaultPadding,
          ),
        ],
      ),
    );
  }
}
