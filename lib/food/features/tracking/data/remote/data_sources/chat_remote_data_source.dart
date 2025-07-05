import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/chat_entity.dart';
import '../../../domain/entities/message_entity.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatEntity>> getUserChats(String userId);
  Future<ChatEntity> getChatById(String chatId);
  Future<ChatEntity> createOrGetChat({
    required String userId,
    required String otherUserId,
    required String orderId,
  });
  Future<void> updateLastMessage({
    required String chatId,
    required String lastMessage,
    required DateTime timestamp,
  });
  Future<List<MessageEntity>> getChatMessages(String chatId);
  Future<MessageEntity> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
  });
  Future<void> markMessageAsRead(String messageId);
  Future<void> deleteMessage(String messageId);
  Stream<List<ChatEntity>> watchUserChats(String userId);
  Stream<List<MessageEntity>> watchChatMessages(String chatId);
  Stream<MessageEntity> watchNewMessages(String chatId);
}

class FirebaseChatRemoteDataSource implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<List<ChatEntity>> getUserChats(String userId) async {
    final snapshot = await _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .get();

    return snapshot.docs.map((doc) => _chatFromFirestore(doc)).toList();
  }

  @override
  Future<ChatEntity> getChatById(String chatId) async {
    final doc = await _firestore.collection('chats').doc(chatId).get();
    
    if (!doc.exists) {
      throw Exception('Chat not found');
    }

    return _chatFromFirestore(doc);
  }

  @override
  Future<ChatEntity> createOrGetChat({
    required String userId,
    required String otherUserId,
    required String orderId,
  }) async {
    // Check if chat already exists for this order
    final existingChatQuery = await _firestore
        .collection('chats')
        .where('orderId', isEqualTo: orderId)
        .where('participants', arrayContains: userId)
        .get();

    if (existingChatQuery.docs.isNotEmpty) {
      return _chatFromFirestore(existingChatQuery.docs.first);
    }

    // Get user details for the other user
    final otherUserDoc = await _firestore
        .collection('users')
        .doc(otherUserId)
        .get();
    
    final otherUserData = otherUserDoc.data() ?? {};
    final otherUserName = '${otherUserData['firstName'] ?? ''} ${otherUserData['lastName'] ?? ''}'.trim();
    final otherUserImage = otherUserData['profileImageUrl'] ?? '';

    // Create new chat
    final chatData = {
      'participants': [userId, otherUserId],
      'orderId': orderId,
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'participantDetails': {
        userId: {
          'id': userId,
          'name': _auth.currentUser?.displayName ?? 'User',
          'imageUrl': _auth.currentUser?.photoURL ?? '',
        },
        otherUserId: {
          'id': otherUserId,
          'name': otherUserName,
          'imageUrl': otherUserImage,
        },
      },
    };

    final docRef = await _firestore.collection('chats').add(chatData);
    final newDoc = await docRef.get();
    
    return _chatFromFirestore(newDoc);
  }

  @override
  Future<void> updateLastMessage({
    required String chatId,
    required String lastMessage,
    required DateTime timestamp,
  }) async {
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(timestamp),
    });
  }

  @override
  Future<List<MessageEntity>> getChatMessages(String chatId) async {
    final snapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .get();

    return snapshot.docs.map((doc) => _messageFromFirestore(doc)).toList();
  }

  @override
  Future<MessageEntity> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    final messageData = {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    final docRef = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // Update last message in chat
    await updateLastMessage(
      chatId: chatId,
      lastMessage: content,
      timestamp: DateTime.now(),
    );

    final newDoc = await docRef.get();
    return _messageFromFirestore(newDoc);
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    // Find the message across all chats (in production, you'd track chatId)
    // For now, this is simplified
    // In production, you'd pass both chatId and messageId
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    // Similar to markMessageAsRead, needs chatId in production
  }

  @override
  Stream<List<ChatEntity>> watchUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _chatFromFirestore(doc)).toList());
  }

  @override
  Stream<List<MessageEntity>> watchChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _messageFromFirestore(doc)).toList());
  }

  @override
  Stream<MessageEntity> watchNewMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) => _messageFromFirestore(snapshot.docs.first));
  }

  ChatEntity _chatFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final currentUserId = _auth.currentUser?.uid ?? '';
    
    // Get the other participant's details
    final participants = List<String>.from(data['participants'] ?? []);
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    
    final participantDetails = data['participantDetails'] as Map<String, dynamic>? ?? {};
    final otherUserDetails = participantDetails[otherUserId] as Map<String, dynamic>? ?? {};

    return ChatEntity(
      id: doc.id,
      senderID: currentUserId,
      receiverID: otherUserId,
      name: otherUserDetails['name'] ?? 'Unknown',
      lastMessage: data['lastMessage'] ?? '',
      imageUrl: otherUserDetails['imageUrl'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  MessageEntity _messageFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return MessageEntity(
      id: doc.id,
      content: data['content'] ?? '',
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}