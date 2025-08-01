import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

import '../../../../components/texts.dart';
import '../../../../core/bloc/bloc_manager.dart';
import '../../../../core/services/navigation_service/nav_config.dart';
import '../../../auth/presentation/widgets/back_widget.dart';
import '../../domain/entities/chat_entity.dart';
import '../manager/messaging_bloc/messaging_bloc.dart';

enum ChatType { text, image, video }

enum Origin { sender, receiver }

class ChatScreen extends StatefulWidget {
  final ChatEntity chat;
  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load messages for this chat
    context.read<MessagingBloc>().add(
      LoadMessagesEvent(chatId: widget.chat.id),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      context.read<MessagingBloc>().add(
        SendMessageEvent(
          chatId: widget.chat.id,
          message: text,
          receiverId: widget.chat.receiverID,
        ),
      );
      _messageController.clear();
      // Scroll to bottom
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

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
            text: widget.chat.receiverID,
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
            child: BlocManager<MessagingBloc, MessagingState>(
              bloc: context.read<MessagingBloc>(),
              child: SizedBox.shrink(),
              isError: (state) => state is MessagingError,
              getErrorMessage:
                  (state) =>
                      state is MessagingError
                          ? state.errorMessage
                          : AppConstants.defaultErrorMessage,
              builder: (context, state) {
                if (state is MessagingLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  );
                } else if (state is MessagingLoaded) {
                  if (state.messages.isEmpty) {
                    return Center(
                      child: FText(
                        text: "No messages yet. Start a conversation!",
                        fontSize: 16,
                        color: kContainerColor,
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return CustomChatBubble(
                        message: message.content,
                        time: _formatTime(message.timestamp),
                        isSender: message.senderId == widget.chat.senderID,
                      );
                    },
                  ).paddingOnly(
                    left: AppConstants.defaultPadding,
                    right: AppConstants.defaultPadding,
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ),
          FTextField(
            height: 63,
            controller: _messageController,
            hintText: "Type something",
            action: TextInputAction.send,
            onEditingComplete: _sendMessage,
            prefix: Icon(Icons.emoji_emotions_outlined),
            suffix: GestureDetector(
              onTap: _sendMessage,
              child: CircleWidget(
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

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${timestamp.minute.toString().padLeft(2, '0')}$period';
  }
}
