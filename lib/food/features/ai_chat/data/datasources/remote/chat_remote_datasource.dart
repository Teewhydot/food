import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/error/exceptions.dart';
import '../../models/chat_message_model.dart';
import '../../models/chat_room_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatMessageModel>> getMessages(String roomId);
  Future<void> sendMessage(String roomId, ChatMessageModel message);
  Future<List<ChatRoomModel>> getUserChatRooms(String userId);
  Future<ChatRoomModel> getChatRoom(String roomId);
  Future<void> createChatRoom(ChatRoomModel chatRoom);
  Future<void> updateChatRoom(ChatRoomModel chatRoom);
  Future<void> updateMessage(String roomId, ChatMessageModel message);
  Future<void> markMessagesAsRead(String roomId, String userId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  ChatRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Stream<List<ChatMessageModel>> getMessages(String roomId) {
    try {
      return firestore
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ChatMessageModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw ServerException('Failed to get messages: $e', 500);
    }
  }

  @override
  Future<void> sendMessage(String roomId, ChatMessageModel message) async {
    try {
      final messageData = message.toFirestore();
      await firestore
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .add(messageData);

      // Update last message in chat room
      await firestore.collection('chat_rooms').doc(roomId).update({
        'lastMessage': message.content,
        'lastMessageTime': Timestamp.fromDate(message.timestamp),
      });
    } catch (e) {
      throw ServerException('Failed to send message: $e', 500);
    }
  }

  @override
  Future<List<ChatRoomModel>> getUserChatRooms(String userId) async {
    try {
      final snapshot = await firestore
          .collection('chat_rooms')
          .where('participantIds', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ChatRoomModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get user chat rooms: $e', 500);
    }
  }

  @override
  Future<ChatRoomModel> getChatRoom(String roomId) async {
    try {
      final doc = await firestore.collection('chat_rooms').doc(roomId).get();
      if (!doc.exists) {
        throw ServerException('Chat room not found', 404);
      }
      return ChatRoomModel.fromFirestore(doc);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to get chat room: $e', 500);
    }
  }

  @override
  Future<void> createChatRoom(ChatRoomModel chatRoom) async {
    try {
      await firestore
          .collection('chat_rooms')
          .doc(chatRoom.id)
          .set(chatRoom.toFirestore());
    } catch (e) {
      throw ServerException('Failed to create chat room: $e', 500);
    }
  }

  @override
  Future<void> updateChatRoom(ChatRoomModel chatRoom) async {
    try {
      await firestore
          .collection('chat_rooms')
          .doc(chatRoom.id)
          .update(chatRoom.toFirestore());
    } catch (e) {
      throw ServerException('Failed to update chat room: $e', 500);
    }
  }

  @override
  Future<void> updateMessage(String roomId, ChatMessageModel message) async {
    try {
      await firestore
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .doc(message.id)
          .update(message.toFirestore());
    } catch (e) {
      throw ServerException('Failed to update message: $e', 500);
    }
  }

  @override
  Future<void> markMessagesAsRead(String roomId, String userId) async {
    try {
      final messagesSnapshot = await firestore
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .where('readBy', whereNotIn: [userId])
          .get();

      final batch = firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        final readBy = List<String>.from(doc.data()['readBy'] ?? []);
        readBy.add(userId);
        batch.update(doc.reference, {'readBy': readBy});
      }
      
      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to mark messages as read: $e', 500);
    }
  }
}