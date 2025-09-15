import 'package:flutter/material.dart';
import '../../domain/entities/widget_response.dart';
import 'chat_widgets/text_chat_widget.dart';
import 'chat_widgets/room_list_chat_widget.dart';
import 'chat_widgets/booking_confirmation_chat_widget.dart';
import 'chat_widgets/payment_result_chat_widget.dart';
import 'chat_widgets/quick_actions_chat_widget.dart';

/// Callback type for widget interactions
typedef WidgetInteractionCallback = void Function(String action, Map<String, dynamic> parameters);

/// Factory class for creating chat widgets based on widget response type
class ChatWidgetFactory {
  /// Creates a chat widget based on the widget response type
  static Widget createWidget({
    required ChatWidgetResponse widgetResponse,
    WidgetInteractionCallback? onInteraction,
  }) {
    try {
      switch (widgetResponse.widgetType) {
        case ChatWidgetType.roomList:
          return RoomListChatWidget(
            widgetResponse: widgetResponse,
            onInteraction: onInteraction,
          );

        case ChatWidgetType.quickActions:
          return QuickActionsChatWidget(
            widgetResponse: widgetResponse,
            onInteraction: onInteraction,
          );

        case ChatWidgetType.bookingConfirmation:
          return BookingConfirmationChatWidget(
            widgetResponse: widgetResponse,
            onInteraction: onInteraction,
          );

        case ChatWidgetType.paymentResult:
          return PaymentResultChatWidget(
            widgetResponse: widgetResponse,
            onInteraction: onInteraction,
          );

        case ChatWidgetType.text:
        default:
          return TextChatWidget(
            widgetResponse: widgetResponse,
            onInteraction: onInteraction,
          );
      }
    } catch (e) {
      // Return fallback text widget on error
      return TextChatWidget(
        widgetResponse: ChatWidgetResponse.textOnly(
          widgetResponse.fallbackText ?? 'Unable to display content',
        ),
        onInteraction: onInteraction,
      );
    }
  }

  /// Checks if a widget type is supported
  static bool isWidgetTypeSupported(ChatWidgetType widgetType) {
    switch (widgetType) {
      case ChatWidgetType.roomList:
      case ChatWidgetType.quickActions:
      case ChatWidgetType.bookingConfirmation:
      case ChatWidgetType.paymentResult:
      case ChatWidgetType.text:
        return true;
      
      default:
        return false;
    }
  }

  /// Gets a list of all supported widget types
  static List<ChatWidgetType> getSupportedWidgetTypes() {
    return ChatWidgetType.values
        .where((type) => isWidgetTypeSupported(type))
        .toList();
  }
}