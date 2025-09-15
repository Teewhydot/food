import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_room.dart';

class ChatRoomModel extends ChatRoom {
  const ChatRoomModel({
    required super.id,
    required super.title,
    required super.participantIds,
    required super.participantNames,
    required super.participantTypes,
    required super.lastMessage,
    required super.lastMessageTime,
    required super.createdAt,
    required super.unreadCount,
    required super.isActive,
    super.roomType = ChatRoomType.aiSupport,
    super.context,
  });

  factory ChatRoomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoomModel(
      id: doc.id,
      title: data['title'] ?? '',
      participantIds: List<String>.from(data['participantIds'] ?? []),
      participantNames: Map<String, String>.from(data['participantNames'] ?? {}),
      participantTypes: Map<String, String>.from(data['participantTypes'] ?? {}),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
      isActive: data['isActive'] ?? true,
      roomType: ChatRoomType.values.firstWhere(
        (type) => type.name == data['roomType'],
        orElse: () => ChatRoomType.aiSupport,
      ),
      context: data['context'] as Map<String, dynamic>?,
    );
  }

  factory ChatRoomModel.fromEntity(ChatRoom entity) {
    return ChatRoomModel(
      id: entity.id,
      title: entity.title,
      participantIds: entity.participantIds,
      participantNames: entity.participantNames,
      participantTypes: entity.participantTypes,
      lastMessage: entity.lastMessage,
      lastMessageTime: entity.lastMessageTime,
      createdAt: entity.createdAt,
      unreadCount: entity.unreadCount,
      isActive: entity.isActive,
      roomType: entity.roomType,
      context: entity.context,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantTypes': participantTypes,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'createdAt': Timestamp.fromDate(createdAt),
      'unreadCount': unreadCount,
      'isActive': isActive,
      'roomType': roomType.name,
      'context': context,
    };
  }

  @override
  ChatRoomModel copyWith({
    String? id,
    String? title,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    Map<String, String>? participantTypes,
    String? lastMessage,
    DateTime? lastMessageTime,
    DateTime? createdAt,
    Map<String, int>? unreadCount,
    bool? isActive,
    ChatRoomType? roomType,
    Map<String, dynamic>? context,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      title: title ?? this.title,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      participantTypes: participantTypes ?? this.participantTypes,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      createdAt: createdAt ?? this.createdAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
      roomType: roomType ?? this.roomType,
      context: context ?? this.context,
    );
  }
}