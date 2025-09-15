import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/widget_response.dart';
import 'widget_response_model.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.senderType,
    required super.content,
    required super.messageType,
    required super.timestamp,
    required super.readBy,
    super.imageUrl,
    super.documentUrl,
    super.replyToId,
    super.functionCallData,
    super.functionCallResult,
    super.isAiProcessing,
    super.widgetData,
    super.widgetInteractionHistory,
  });

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderType: SenderType.values.firstWhere(
        (e) => e.name == data['senderType'],
        orElse: () => SenderType.user,
      ),
      content: data['content'] ?? '',
      messageType: MessageType.values.firstWhere(
        (e) => e.name == data['messageType'],
        orElse: () => MessageType.text,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      readBy: List<String>.from(data['readBy'] ?? []),
      imageUrl: data['imageUrl'],
      documentUrl: data['documentUrl'],
      replyToId: data['replyToId'],
      functionCallData: data['functionCallData'] as Map<String, dynamic>?,
      functionCallResult: data['functionCallResult'],
      isAiProcessing: data['isAiProcessing'] ?? false,
      widgetInteractionHistory:
          data['widgetInteractionHistory'] as Map<String, dynamic>?,
    );
  }

  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      id: entity.id,
      senderId: entity.senderId,
      senderName: entity.senderName,
      senderType: entity.senderType,
      content: entity.content,
      messageType: entity.messageType,
      timestamp: entity.timestamp,
      readBy: entity.readBy,
      imageUrl: entity.imageUrl,
      documentUrl: entity.documentUrl,
      replyToId: entity.replyToId,
      functionCallData: entity.functionCallData,
      functionCallResult: entity.functionCallResult,
      isAiProcessing: entity.isAiProcessing,
      widgetInteractionHistory: entity.widgetInteractionHistory,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType.name,
      'content': content,
      'messageType': messageType.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'readBy': readBy,
      'imageUrl': imageUrl,
      'documentUrl': documentUrl,
      'replyToId': replyToId,
      'functionCallData': functionCallData,
      'functionCallResult': functionCallResult,
      'isAiProcessing': isAiProcessing,
      'widgetData': widgetData != null && widgetData is ChatWidgetResponseModel
          ? (widgetData as ChatWidgetResponseModel).toJson()
          : null,
      'widgetInteractionHistory': widgetInteractionHistory,
    };
  }

  @override
  ChatMessageModel copyWith({
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
    return ChatMessageModel(
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
      widgetInteractionHistory:
          widgetInteractionHistory ?? this.widgetInteractionHistory,
    );
  }
}
