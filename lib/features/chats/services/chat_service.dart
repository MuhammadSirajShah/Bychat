
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:bychat/features/chats/models/chat_message_model.dart';

class ChatService {
  ChatService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _messagesCollection(
      String chatId,
      ) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages');
  }

  Stream<List<ChatMessageModel>> watchMessages(String chatId) {
    return _messagesCollection(chatId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        return ChatMessageModel.fromMap(
          document.data(),
          id: document.id,
        );
      }).toList();
    });
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final messageText = text.trim();

    if (chatId.trim().isEmpty) {
      throw ArgumentError('Chat ID cannot be empty.');
    }

    if (senderId.trim().isEmpty || receiverId.trim().isEmpty) {
      throw ArgumentError('Sender ID and receiver ID are required.');
    }

    if (messageText.isEmpty) {
      throw ArgumentError('Message cannot be empty.');
    }

    final document = _messagesCollection(chatId).doc();

    final message = ChatMessageModel(
      id: document.id,
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      text: messageText,
      createdAt: DateTime.now(),
    );

    await document.set(message.toMap());
  }

  Future<void> markMessageAsRead({
    required String chatId,
    required String messageId,
  }) async {
    if (chatId.trim().isEmpty || messageId.trim().isEmpty) {
      throw ArgumentError('Chat ID and message ID are required.');
    }

    await _messagesCollection(chatId)
        .doc(messageId)
        .update({'isRead': true});
  }
}
