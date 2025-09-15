import 'package:equatable/equatable.dart';

enum ChatRoomType {
  aiSupport,
  humanSupport,
  group,
  direct
}

class ChatRoom extends Equatable {
  final String id;
  final String title;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String> participantTypes; // 'user', 'ai', 'admin'
  final String lastMessage;
  final DateTime lastMessageTime;
  final DateTime createdAt;
  final Map<String, int> unreadCount; // userId -> count
  final bool isActive;
  final ChatRoomType roomType;
  final Map<String, dynamic>? context; // Additional room-specific data

  const ChatRoom({
    required this.id,
    required this.title,
    required this.participantIds,
    required this.participantNames,
    required this.participantTypes,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.createdAt,
    required this.unreadCount,
    required this.isActive,
    this.roomType = ChatRoomType.aiSupport,
    this.context,
  });

  bool hasUnreadMessages(String userId) {
    return (unreadCount[userId] ?? 0) > 0;
  }

  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }

  bool isParticipant(String userId) {
    return participantIds.contains(userId);
  }

  String getParticipantName(String userId) {
    return participantNames[userId] ?? 'Unknown User';
  }

  String getParticipantType(String userId) {
    return participantTypes[userId] ?? 'user';
  }

  bool get isAIRoom => roomType == ChatRoomType.aiSupport;
  
  bool get isHumanSupportRoom => roomType == ChatRoomType.humanSupport;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  ChatRoom copyWith({
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
    return ChatRoom(
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

  @override
  List<Object?> get props => [
        id,
        title,
        participantIds,
        participantNames,
        participantTypes,
        lastMessage,
        lastMessageTime,
        createdAt,
        unreadCount,
        isActive,
        roomType,
        context,
      ];
}