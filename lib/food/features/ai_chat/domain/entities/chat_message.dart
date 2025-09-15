import 'package:equatable/equatable.dart';
import 'widget_response.dart';

enum MessageType {
  text,
  image,
  document,
  video,
  widget // New message type for widget responses
}

enum SenderType {
  user,
  admin,
  ai
}

class ChatMessage extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final SenderType senderType;
  final String content;
  final MessageType messageType;
  final DateTime timestamp;
  final List<String> readBy;
  final String? imageUrl;
  final String? documentUrl;
  final String? replyToId;
  final Map<String, dynamic>? functionCallData;
  final String? functionCallResult;
  final bool isAiProcessing;
  final ChatWidgetResponse? widgetData;
  final Map<String, dynamic>? widgetInteractionHistory;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.content,
    required this.messageType,
    required this.timestamp,
    required this.readBy,
    this.imageUrl,
    this.documentUrl,
    this.replyToId,
    this.functionCallData,
    this.functionCallResult,
    this.isAiProcessing = false,
    this.widgetData,
    this.widgetInteractionHistory,
  });

  bool isReadByUser(String userId) => readBy.contains(userId);
  
  bool get isFromAi => senderType == SenderType.ai;
  
  bool get hasFunctionCall => functionCallData != null;
  
  bool get requiresUserConfirmation => hasFunctionCall && functionCallResult == null;
  
  bool get hasWidget => widgetData != null;
  
  bool get isWidgetMessage => messageType == MessageType.widget;
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    SenderType? senderType,
    String? content,
    MessageType? messageType,
    DateTime? timestamp,
    List<String>? readBy,
    String? imageUrl,
    String? documentUrl,
    String? replyToId,
    Map<String, dynamic>? functionCallData,
    String? functionCallResult,
    bool? isAiProcessing,
    ChatWidgetResponse? widgetData,
    Map<String, dynamic>? widgetInteractionHistory,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderType: senderType ?? this.senderType,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      timestamp: timestamp ?? this.timestamp,
      readBy: readBy ?? this.readBy,
      imageUrl: imageUrl ?? this.imageUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      replyToId: replyToId ?? this.replyToId,
      functionCallData: functionCallData ?? this.functionCallData,
      functionCallResult: functionCallResult ?? this.functionCallResult,
      isAiProcessing: isAiProcessing ?? this.isAiProcessing,
      widgetData: widgetData ?? this.widgetData,
      widgetInteractionHistory: widgetInteractionHistory ?? this.widgetInteractionHistory,
    );
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        senderName,
        senderType,
        content,
        messageType,
        timestamp,
        readBy,
        imageUrl,
        documentUrl,
        replyToId,
        functionCallData,
        functionCallResult,
        isAiProcessing,
        widgetData,
        widgetInteractionHistory,
      ];
}