import 'package:flutter/material.dart';
import '../../../domain/entities/widget_response.dart';
import 'base_chat_widget.dart';

/// Simple text widget for fallback cases
class TextChatWidget extends BaseChatWidget {
  const TextChatWidget({
    super.key,
    required super.widgetResponse,
    super.onInteraction,
  });

  TextWidgetData get textData => widgetResponse.data as TextWidgetData;

  @override
  bool shouldShowHeader() => false;

  @override
  Widget buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        textData.text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}